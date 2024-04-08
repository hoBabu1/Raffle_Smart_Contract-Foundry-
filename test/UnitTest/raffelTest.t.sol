//SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;
import {Test, console} from "forge-std/Test.sol";
import {DeployRaffel} from "script/DeployRaffel.s.sol";
import {Raffel} from "src/raffel.sol";
import {HelperConfig} from "script/HelperConfig.s.sol";
import {Vm} from "forge-std/Vm.sol";
import {VRFCoordinatorV2Mock} from "lib/chainlink-brownie-contracts/contracts/src/v0.8/mocks/VRFCoordinatorV2Mock.sol";

contract RaffelTest is Test {
    /* Event */
    event enteredRaffel(address indexed player);
    event requestedRaffelWinner(uint256 indexed requestId);

    Raffel raffel;
    HelperConfig helperconfig;
    uint256 enteranceFee;
    uint256 interval;
    uint64 subscriptionId;
    address _vrfCordinator;
    bytes32 gasLane;
    uint32 callbackGasLimit;

    address public PLAYER = makeAddr("hoBabu");
    uint256 public constant STARTING_BALANCE = 10 ether;

    modifier skipFork{
        if(block.chainid != 31337)
        {
            return;
        }
        _;
    }

    function setUp() external {
        DeployRaffel deployer = new DeployRaffel();
        (raffel, helperconfig) = deployer.run();
        (
            enteranceFee,
            interval,
            subscriptionId,
            _vrfCordinator,
            gasLane,
            callbackGasLimit,
            ,

        ) = helperconfig.activeNetworkConfig();
        vm.deal(PLAYER, STARTING_BALANCE);
    }

    function testInializes_Open_state() public view {
        //  assert(uint256(raffel.getRaffelState())==0);
        assert(raffel.getRaffelState() == Raffel.RaffelState.Open);
    }

    /**************************   ENTER RAFFEL TEST  ***************************************/

    function testFunction_Reverts_When_Enough_Eth_NotSent() public {
        vm.prank(PLAYER);
        vm.expectRevert();
        raffel.enterRaffel();
    }

    /* Check wether players address are updated or not  */

    function testRaffel_Recoord_When_Player_Enter() public {
        vm.prank(PLAYER);
        raffel.enterRaffel{value: enteranceFee}();
        assert(raffel.getPlayers()[0] == PLAYER);
    }

    /* Testing an  Event Emit */
    function testEvent_Emit_EnteredRaffel() public {
        vm.prank(PLAYER);
        vm.expectEmit(true, false, false, false);
        emit Raffel.enteredRaffel(PLAYER);
        raffel.enterRaffel{value: enteranceFee}();
    }

    /* Testing Player Can't enter when raffel is calculating winner */
    function testPlayer_cannot_enter_when_raffel_isCalculating_Winner() public {
        vm.prank(PLAYER);
        raffel.enterRaffel{value: enteranceFee}();
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);
        raffel.performUpkeep("");
        vm.prank(PLAYER);
        vm.expectRevert();
        raffel.enterRaffel{value: enteranceFee}();
    }

    /****************************  checkUpKeep  *************************************** */

    /* Time Check  */

    function testcheckUpkeepReturnFalseifTimeHasNotPassed() public {
        vm.warp(block.timestamp + interval);
        vm.roll(block.chainid + 1);

        (bool upkeepNeeded, ) = raffel.checkUpkeep("");
        assert(!upkeepNeeded);
    }

    /* Return False When raffel is not Open */
    function testReturnsFalseWhenRaffelIsNotOpen() public {
        vm.prank(PLAYER);
        raffel.enterRaffel{value: enteranceFee}();
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);
        raffel.performUpkeep("");
        (bool upkeepNeeded, ) = raffel.checkUpkeep("");
        // assert
        assertEq(upkeepNeeded, false);
    }

    /* Returns False when enough time hasnot passed  */
    function testCheckUpKeepReturnsFalseIfEnoughTimeHasntPassed() public {
        vm.prank(PLAYER);
        raffel.enterRaffel{value: enteranceFee}();
        (bool upkeepNeeded, ) = raffel.checkUpkeep("");
        assert(upkeepNeeded == false);
    }

    /* Returns true when all paramenters are ture  */
    function testCheckUpKeepReturnsTrueWhenParameterAreGood() public {
        vm.prank(PLAYER);
        raffel.enterRaffel{value: enteranceFee}();
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);
        (bool upkeepNeeded, ) = raffel.checkUpkeep("");
        assert(upkeepNeeded == true);
    }

    /****************************************** Perform upKeep ******************************************************* */
    /* performUpkeep function can only run if Check Up returns true  */
    function testPerformUpKeepCanOnlyRunIfCheckUpKeepIsTrue() public  {
        vm.prank(PLAYER);
        raffel.enterRaffel{value: enteranceFee}();
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);
        raffel.performUpkeep("");
    }

    /* Perform UpKeep reverts if checkUp Keep is not true  */
    function testPerformUpKeepRevertsIfCheckUpkeepIsfFalse() public skipFork {
        uint256 raffelState = 0;
        uint256 currentBalance = 0;
        uint256 numberOfPlayers = 0;
        vm.expectRevert(
            abi.encodeWithSelector(
                Raffel.Raffel__upKeepNotNeeded.selector,
                raffelState,
                currentBalance,
                numberOfPlayers
            )
        );
        raffel.performUpkeep("");
    }

    /* Updateing the Raffel State when winner is being calculated  */
    function testPerformUpKeepUpdatesRaffelState() public {
        vm.prank(PLAYER);
        raffel.enterRaffel{value: enteranceFee}();
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);
        raffel.performUpkeep("");
        assert(raffel.getRaffelState() == Raffel.RaffelState.Calculating);
    }

    /* How to Test Event emitted which is not access to smart contract  */
    function testEmitsRequestId() public {
        vm.prank(PLAYER);
        raffel.enterRaffel{value: enteranceFee}();
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);
        vm.recordLogs();
        raffel.performUpkeep("");
        Vm.Log[] memory enteries = vm.getRecordedLogs();
        bytes32 requestId = enteries[1].topics[1];
        assert(uint256(requestId) > 0);
    }

    /************************************ FullFill RandomWords *************************************************************** */


    
    /* FullFill Random Words Can only be called after Perform Up Keep */
    function testFullFillRandowmwordsCanOnlyBeCalledAfterPerformUpKeep(uint)
        public skipFork
    {
        vm.expectRevert();
        VRFCoordinatorV2Mock(_vrfCordinator).fulfillRandomWords(
            0,
            address(raffel)
        );
    }
   /*   FullFill Random Words   */

    function testFullFillRandomWordsPicksWinnerResetAndSendMoney() public   skipFork
    {
        vm.prank(PLAYER);
        raffel.enterRaffel{value: enteranceFee}();
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);
        // arrange
        uint256 additionalEnteries = 5;
        uint256 startIndex = 1;
        for (uint256 i = 1; i < startIndex + additionalEnteries; i++) {
            address player = address(uint160(i));
           vm.prank(player);
           vm.deal(player, STARTING_BALANCE);
           raffel.enterRaffel{value: enteranceFee}();
        }
        uint256 prize = (additionalEnteries + 1) * enteranceFee;
        // act
        vm.recordLogs(); // tells the vm to start recording all the emitted events .
        raffel.performUpkeep("");
        Vm.Log[] memory allEnteries = vm.getRecordedLogs();
        bytes32 requestIdd = allEnteries[1].topics[1];
        uint256 previousTimeStamp = raffel.getLastTimeStamp();
        VRFCoordinatorV2Mock(_vrfCordinator).fulfillRandomWords(
            uint256(requestIdd),
            address(raffel)
        );

        // assert
        assert(raffel.getRaffelState() == Raffel.RaffelState.Open);
        assert(raffel.getRecentWinner() != address(0));
        assert(raffel.getPlayers().length == 0);
        assert(previousTimeStamp < raffel.getLastTimeStamp());
        assert(
            raffel.getRecentWinner().balance ==
                STARTING_BALANCE + prize - enteranceFee
        );
    }

}