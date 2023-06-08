// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/** 
 * @title IGovernanceTimeLock 
 */
interface IGovernanceTimeLock {
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
    ) 
        external;
}