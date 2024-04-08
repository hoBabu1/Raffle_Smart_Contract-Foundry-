//SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;
import {Script} from "forge-std/Script.sol";
import {Raffel} from "src/raffel.sol";
import {HelperConfig} from "script/HelperConfig.s.sol";
import {createSubscription, FundScript, AddConsumer} from "script/Interaction.s.sol";

contract DeployRaffel is Script {
    function run() external returns (Raffel, HelperConfig) {
        HelperConfig helperconfig = new HelperConfig();
        (
            uint256 enteranceFee,
            uint256 interval,
            uint64 subscriptionId,
            address _vrfCordinator,
            bytes32 gasLane,
            uint32 callbackGasLimit,
            address link,
            uint256 deployerKey
        ) = helperconfig.activeNetworkConfig();
        if (subscriptionId == 0) {
            //create subscription id
            createSubscription createsub = new createSubscription();
            subscriptionId = createsub.createsubscription(_vrfCordinator,deployerKey);
            // fund it
            FundScript fundsubscriptionn = new FundScript();
            fundsubscriptionn.fundssSubscription(
                _vrfCordinator,
                subscriptionId,
                link,
                deployerKey
            );
        }
        vm.startBroadcast();
        Raffel raffel = new Raffel(
            enteranceFee,
            interval,
            subscriptionId,
            _vrfCordinator,
            gasLane,
            callbackGasLimit
        );
        vm.stopBroadcast();
        AddConsumer addconsumer = new AddConsumer();
        addconsumer.addConsumer(
            subscriptionId,
            address(raffel),
            _vrfCordinator,
            deployerKey
        );
        return (raffel, helperconfig);
    }
}
