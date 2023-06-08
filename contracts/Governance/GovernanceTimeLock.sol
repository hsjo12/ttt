// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../../node_modules/@openzeppelin/contracts/governance/TimelockController.sol";
/** 
 * @title GovernanceTimeLock
 * @notice The GovernanceTimeLock is a timelock controller that makes a specific schedule for owners to execute an approved proposal. 
 */
contract GovernanceTimeLock is TimelockController {
    
    /// Error
    error AlreadyInitialized();
    
    /// Variable
    bool private isInitialized;

    constructor(
        uint256 minDelay,
        address[] memory proposers,
        address[] memory executors,
        address owner
    ) TimelockController(minDelay, proposers, executors, owner) {}

    /**
     * @notice The init function is to set up values in the constructor of GovernanceTimeLock.
     * @dev It is only executed only once right after clonning GovernanceTimeLock. 
     * @param minDelay is minimum delay for execution an approved proposal.
     * @param proposers is the list of proposers' and cancellers' accounts.
     * @param executors is the list of executors' accounts.
     * @param owner is an owner account.
     */
    function init(
        uint256 minDelay, 
        address[] memory proposers, 
        address[] memory executors, 
        address owner
    ) external 
    {
        if(isInitialized) revert AlreadyInitialized();
        isInitialized = true;
        _setRoleAdmin(TIMELOCK_ADMIN_ROLE, TIMELOCK_ADMIN_ROLE);
        _setRoleAdmin(PROPOSER_ROLE, TIMELOCK_ADMIN_ROLE);
        _setRoleAdmin(EXECUTOR_ROLE, TIMELOCK_ADMIN_ROLE);
        _setRoleAdmin(CANCELLER_ROLE, TIMELOCK_ADMIN_ROLE);

        _setupRole(TIMELOCK_ADMIN_ROLE, address(this));

        if (owner != address(0)) {
            _setupRole(TIMELOCK_ADMIN_ROLE, owner);
        }

        for (uint256 i = 0; i < proposers.length; ++i) {
            _setupRole(PROPOSER_ROLE, proposers[i]);
            _setupRole(CANCELLER_ROLE, proposers[i]);
        }

        for (uint256 i = 0; i < executors.length; ++i) {
            _setupRole(EXECUTOR_ROLE, executors[i]);
        }

        this.updateDelay(minDelay);
    }
}