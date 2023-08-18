pragma solidity ^0.8.13;

interface IProxy {
    event GovernorshipTransferred(address indexed previousGovernor, address indexed newGovernor);
    event PendingGovernorshipTransfer(address indexed previousGovernor, address indexed newGovernor);
    event Upgraded(address indexed implementation);

    function admin() external view returns (address);
    function claimGovernance() external;
    function governor() external view returns (address);
    function implementation() external view returns (address);
    function initialize(address _logic, address _initGovernor, bytes memory _data) external payable;
    function isGovernor() external view returns (bool);
    function transferGovernance(address _newGovernor) external;
    function upgradeTo(address newImplementation) external;
    function upgradeToAndCall(address newImplementation, bytes memory data) external payable;
}
