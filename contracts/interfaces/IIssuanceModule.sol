// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

interface IIssuanceModule {

    /* ========= EVENTS ========= */

    event SubscriptionCreated(
        uint256 indexed subscriptionId,
        address indexed investor,
        uint256 amount
    );

    event SubscriptionApproved(uint256 indexed subscriptionId);
    event TokensMinted(uint256 indexed subscriptionId, address indexed investor);

    /* ========= FUNCTIONS ========= */

    function createSubscription(uint256 amount) external returns (uint256);

    function approveSubscription(uint256 subscriptionId) external;

    function mintForSubscription(uint256 subscriptionId) external;
}
