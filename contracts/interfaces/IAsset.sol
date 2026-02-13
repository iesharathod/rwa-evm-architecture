// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

interface IAssetToken {

    /* ========= EVENTS ========= */

    event Minted(address indexed to, uint256 amount);
    event Burned(address indexed from, uint256 amount);
    event SnapshotCreated(uint256 snapshotId);
    event ComplianceModuleUpdated(address newModule);

    /* ========= VIEW FUNCTIONS ========= */

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function totalSupply() external view returns (uint256);
    function cap() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);

    /* ========= CORE FUNCTIONS ========= */

    function mint(address to, uint256 amount) external;
    function burn(uint256 amount) external;
    function snapshot() external returns (uint256);

    /* ========= COMPLIANCE ========= */

    function setComplianceModule(address module) external;
}
