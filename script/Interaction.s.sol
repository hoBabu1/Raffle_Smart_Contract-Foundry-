//SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

import {Script, console} from "forge-std/Script.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {VRFCoordinatorV2Mock} from "../lib/chainlink-brownie-contracts/contracts/src/v0.8/mocks/VRFCoordinatorV2Mock.sol";
import {LinkToken} from "test/UnitTest/mock/LinkToekn.sol";
import {Raffel} from "src/Raffel.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";

contract createSubscription is Script {
    function createSubcsriptionUsingConfig() public returns (uint64) {
        HelperConfig helperconfig = new HelperConfig();
        (
            ,
            ,
            ,
            address _vrfCordinator,
            ,
            ,
            ,
            uint256 deployerKey
        ) = helperconfig
            .activeNetworkConfig();
        return createsubscription(_vrfCordinator,deployerKey);
    }

    function createsubscription(address vrfCordinator,uint256 deployerKey) public returns (uint64) {
        vm.startBroadcast(deployerKey);
        uint64 subId = VRFCoordinatorV2Mock(vrfCordinator).createSubscription();
        vm.stopBroadcast();
        return subId;
    }

    function run() external returns (uint64) {
        return createSubcsriptionUsingConfig();
    }
}

contract FundScript is Script {
    uint96 public constant FUND_AMOUNT = 3 ether;

    function fundsubscriptionUsingNetworkConfig() public {
        HelperConfig helperconfig = new HelperConfig();
        (
            ,
            ,
            uint64 subscriptionId,
            address _vrfCordinator,
            ,
            ,
            address link,
            uint256 deployerKey
            
        ) = helperconfig.activeNetworkConfig();
        fundssSubscription(_vrfCordinator, subscriptionId, link,deployerKey);
    }

    function fundssSubscription(
        address _vrfCordinator,
        uint64 subId,
        address link,
        uint256 deployerKey
    ) public {
        if (block.chainid == 31337) {
            vm.startBroadcast(deployerKey);
            VRFCoordinatorV2Mock(_vrfCordinator).fundSubscription(
                subId,
                FUND_AMOUNT
            );
            vm.stopBroadcast();
        } else {
            LinkToken(link).transferAndCall(
                _vrfCordinator,
                FUND_AMOUNT,
                abi.encode(subId)
            );
        }
    }

    function run() external {
        fundsubscriptionUsingNetworkConfig();
    }
}

contract AddConsumer is Script {
    function run() external {
        address raffel = DevOpsTools.get_most_recent_deployment(
            "Raffel",
            block.chainid
        );

        addConsumerUsingConfig(raffel);
    }

    function addConsumerUsingConfig(address raffel) public {
        HelperConfig helperconfig = new HelperConfig();
        (
            ,
            ,
            uint64 subscriptionId,
            address _vrfCordinator,
            ,
            ,
            ,
            uint256 deployerKey
        ) = helperconfig.activeNetworkConfig();
        addConsumer(subscriptionId, raffel, _vrfCordinator, deployerKey);
    }

    function addConsumer(
        uint64 _subscriptionId,
        address raffel,
        address _vrfCordinator,
        uint256 deployerKey
    ) public {
        vm.startBroadcast(deployerKey);
        VRFCoordinatorV2Mock(_vrfCordinator).addConsumer(
            _subscriptionId,
            raffel
        );
        vm.stopBroadcast();
    }
}
