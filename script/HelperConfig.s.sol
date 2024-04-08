//SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;
import {Script} from "forge-std/Script.sol";
import {VRFCoordinatorV2Mock} from "lib/chainlink-brownie-contracts/contracts/src/v0.8/mocks/VRFCoordinatorV2Mock.sol";
import {LinkToken} from "test/UnitTest/mock/LinkToekn.sol";
contract HelperConfig is Script {
    struct NetworkConfig {
        uint256 enteranceFee;
        uint256 interval;
        uint64 subscriptionId;
        address _vrfCordinator;
        bytes32 gasLane;
        uint32 callbackGasLimit;
        address link;
        uint256 deployerKey;
    }
    NetworkConfig public activeNetworkConfig;
    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else {
            activeNetworkConfig = getAnvilEthConfig();
        }
    }
    function getSepoliaEthConfig() public view returns (NetworkConfig memory) {
        NetworkConfig memory sepolia =  NetworkConfig({
            enteranceFee:0.5 ether,
            interval:6000,
            subscriptionId:10799,
            _vrfCordinator:0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625,
            gasLane:0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c,
            callbackGasLimit:500000,
            link:0x779877A7B0D9E8603169DdbD7836e478b4624789,
            deployerKey:vm.envUint("PRIVATE_KEY")
        });
        return sepolia;
    }
    function getAnvilEthConfig() public returns (NetworkConfig memory) {
        uint96 _baseFee = 0.1 ether;
         uint96 _gasPriceLink = 1e9 ;
         vm.startBroadcast();
        VRFCoordinatorV2Mock mock = new VRFCoordinatorV2Mock(_baseFee ,_gasPriceLink );
        LinkToken link = new LinkToken();
        vm.stopBroadcast();
        return NetworkConfig({
            enteranceFee:0.5 ether,
            interval:6000,
            subscriptionId:0,
            _vrfCordinator:address(mock),
            gasLane:0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c,
            callbackGasLimit:500000,
            link:address(link),
            deployerKey:0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
        });
        

    }

}
