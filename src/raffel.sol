//SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

/**
 * Contact --> amankumaropensource@gmail.com  
 * @title Lottery
 * @author Aman Kumar aka hoBabu
 */
import {VRFCoordinatorV2Interface} from "lib/chainlink-brownie-contracts/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import {VRFConsumerBaseV2} from "lib/chainlink-brownie-contracts/contracts/src/v0.8/vrf/VRFConsumerBaseV2.sol";

contract Raffel is VRFConsumerBaseV2 {
    error Raffel_Not_Enough_Eth_Sent();
    error Raffel_TransferedFailed();
    error Raffel_Raffel_Not_Open();
    error Raffel__upKeepNotNeeded(
        uint256 currentBlance,
        uint256 currentPlayers,
        uint256 raffleState
    );

    // Player cannot enter while calculating winners
    enum RaffelState {
        Open,
        Calculating
    }

    uint16 private constant REQUESTCONFIRMATIONS = 3;
    uint32 private constant NUMWORDS = 1;

    uint256 private immutable i_enteranceFee;
    uint256 private immutable i_interval;
    VRFCoordinatorV2Interface private immutable i_vrfCordinator;
    bytes32 private immutable i_gasLane;
    uint64 private immutable i_subscriptionId;
    uint32 private immutable i_callbackGasLimit;

    address payable[] private s_players;
    uint256 private s_lastTime;
    address private s_recentWinner;
    RaffelState private s_raffelState;
    /**
     * for learning purpose
     * Indexed is also called topics
     * There can be maximum 3 topics
     * Indexed is easy to search
     * Non indexed get encrypted with ABI and its difficult to decode
     */
    event enteredRaffel(address indexed player);
    event winnerPicked(address indexed winner);
    event requestedRaffelWinner(uint256 indexed requestId);

    constructor(
        uint256 enteranceFee,
        uint256 interval,
        uint64 subscriptionId,
        address _vrfCordinator,
        bytes32 gasLane,
        uint32 callbackGasLimit
    ) VRFConsumerBaseV2(_vrfCordinator) {
        i_enteranceFee = enteranceFee;
        i_interval = interval;
        s_lastTime = block.timestamp;
        i_subscriptionId = subscriptionId;
        i_vrfCordinator = VRFCoordinatorV2Interface(_vrfCordinator);
        i_gasLane = gasLane;
        i_callbackGasLimit = callbackGasLimit;
        s_raffelState = RaffelState.Open;
    }

    /*
     * function to enter Raffel
     */
    function enterRaffel() external payable {
        if (msg.value != i_enteranceFee) {
            revert Raffel_Not_Enough_Eth_Sent();
        }
        if (s_raffelState != RaffelState.Open) {
            revert Raffel_Raffel_Not_Open();
        }
        s_players.push(payable(msg.sender));
        emit enteredRaffel(msg.sender);
    }

    /**
     *
     * This is the function that chainlink will automatically call to see if its time to perform checkupkeep
     * Time --> time must be passed
     * minimum number of players
     * balance
     * raffel shpoukld be open
     */

    function checkUpkeep(
        bytes memory /* checkData */
    ) public view returns (bool upkeepNeeded, bytes memory /* performData */) {
        bool timeHasPassed = (block.timestamp - s_lastTime > i_interval);
        bool isOpen = RaffelState.Open == s_raffelState;
        bool hasBlance = address(this).balance > 0;
        bool hasPlayers = s_players.length > 0;
        upkeepNeeded = (timeHasPassed && isOpen && hasBlance && hasPlayers);
        return (upkeepNeeded, "0x0");
    }

    function performUpkeep(bytes calldata /* performData */) external {
        bytes memory data = new bytes(0);
        (bool upKeepNeeded, ) = checkUpkeep(data);
        if (!upKeepNeeded) {
            revert Raffel__upKeepNotNeeded(
                address(this).balance,
                s_players.length,
                uint256(s_raffelState)
            );
        }
        s_raffelState = RaffelState.Calculating;
        uint256 requestId = i_vrfCordinator.requestRandomWords(
            i_gasLane,
            i_subscriptionId,
            REQUESTCONFIRMATIONS,
            i_callbackGasLimit,
            NUMWORDS
        );
        emit requestedRaffelWinner(requestId);
    }

    function fulfillRandomWords(
        uint256 /*_requestId*/,
        uint256[] memory _randomWords
    ) internal override {
        // Getting index of winner
        uint256 indexOfWinner = _randomWords[0] % s_players.length;
        address winner = s_players[indexOfWinner];
        s_recentWinner = winner;
        // Updating raffel State
        s_raffelState = RaffelState.Open;
         
        (bool callSuccess, ) = payable(s_recentWinner).call{
            value: address(this).balance
        }("");
        if (!callSuccess) {
            revert Raffel_TransferedFailed();
        }
        
        /* Reset Array bcz a new slot will start  */
        s_players = new address payable[](0);

        /* Updating Time */
        s_lastTime = block.timestamp;

        /* Emit winner , So that it will be easily identified by Frontend  */
        emit winnerPicked(winner);
    }

    /**********************************Getter function**********************************/

    /* Get Enterance Fee*/
    function getEnteranceFee() external view returns (uint256) {
        return i_enteranceFee;
    }

    /* Get RaffelState */
    function getRaffelState() external view returns (RaffelState) {
        return s_raffelState;
    }

    /* Get player at 0th index  */
    function getPlayers() external view returns (address payable[] memory) {
        return s_players;
    }

    // function to get recent Winner 
    function getRecentWinner() external view returns(address) {
        return s_recentWinner;
    }
    
    /* Function returns length of a player array  */
    function getlengthOfPlayers() external view returns(uint256){
        return s_players.length;
    }

    /* Function returns LastTime  */
    function getLastTimeStamp() external view returns(uint256)
    {
        return s_lastTime;
    }
}
