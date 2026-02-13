// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

interface IComplianceModule {

    /* ========= EVENTS ========= */

    event AllowlistUpdated(address indexed user, bool status);
    event JurisdictionUpdated(address indexed user, uint8 code);
    event InvestorTypeUpdated(address indexed user, uint8 investorType);
    event AddressFrozen(address indexed user, bool frozen);
    event GlobalPauseUpdated(bool paused);

    /* ========= VIEW ========= */

    function isAllowlisted(address user) external view returns (bool);
    function isFrozen(address user) external view returns (bool);
    function isPaused() external view returns (bool);

    /* ========= VALIDATION ========= */

    function validateTransfer(
        address from,
        address to,
        uint256 amount
    ) external view returns (bool);

    /* ========= ADMIN ========= */

    function setAllowlist(address user, bool status) external;
    function setJurisdiction(address user, uint8 code) external;
    function setInvestorType(address user, uint8 investorType) external;
    function freezeAddress(address user, bool frozen) external;
    function setGlobalPause(bool paused) external;
}
