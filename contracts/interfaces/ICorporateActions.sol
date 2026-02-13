// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

interface ICorporateActions {

    /* ========= EVENTS ========= */

    event DividendFunded(uint256 indexed snapshotId, uint256 totalAmount);
    event DividendClaimed(address indexed investor, uint256 amount);
    event RedemptionRequested(address indexed investor, uint256 amount);
    event RedemptionProcessed(address indexed investor, uint256 amount);

    /* ========= DIVIDENDS ========= */

    function fundDividend(uint256 snapshotId, uint256 amount) external;

    function claimDividend(uint256 snapshotId) external;

    /* ========= REDEMPTION ========= */

    function requestRedemption(uint256 amount) external;

    function processRedemption(address investor) external;
}
