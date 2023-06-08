// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/** 
 * @title ISortedList 
 */
interface ISortedList {
  
  struct proposalInfo {
      address[] targetAddress;
      uint256[] values;
      bytes[] calldatas;
      string description;
  }

  function listSize() external view returns (uint256);
  function removeProposalId(uint256 _proposalId) external;
  function addProposalId(
      address currentDao,
      address[] calldata targetAddress, 
      uint256[] calldata values,
      bytes[] calldata calldatas,
      string calldata description,
      uint256 _epochTime
    ) 
      external; 

  function getEarlistEndOfDate() 
  external 
  view 
  returns (
    uint256 _time, 
    uint256 _proposalId
  ); 

  function getProposals(uint256 id) 
      external 
      view 
      returns (
          address,
          address[] memory, 
          uint256[] memory, 
          bytes[] memory, 
          string memory
      );

}