//SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../../node_modules/@openzeppelin/contracts/access/AccessControl.sol";
import "../interfaces/ISortedList.sol";

contract SortedQueueAndExecutionList is AccessControl, ISortedList {
  /// Constants
  bytes32 public constant BRAND_MANAGER_ROLE = keccak256("BRAND_MANAGER_ROLE");
  uint256 constant GUARD = 1;

  /// Error
  error OnlyRegisterProposalIdOnce();
  
  /// Variable
  uint256 public listSize;
  mapping(uint256 => address) public daoByProposalId;
  mapping(uint256 => uint256) public proposalIds;
  mapping(uint256 => uint256) private _secondEarliestProposalId;
  mapping(uint256 => proposalInfo) private proposals;
  
  constructor() {
    _secondEarliestProposalId[GUARD] = GUARD;
    _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    _setupRole(BRAND_MANAGER_ROLE, msg.sender);
  }

  function getProposals(uint256 id) 
    external 
    view 
    returns (
      address, 
      address[] memory, 
      uint256[] memory, 
      bytes[] memory, 
      string memory
    ) 
  {
    return (daoByProposalId[id], proposals[id].targetAddress, proposals[id].values, proposals[id].calldatas, proposals[id].description);
  }

  function addProposalId(
    address currentDao,
    address[] calldata _targetAddress, 
    uint256[] calldata _values,
    bytes[] calldata _calldatas,
    string calldata _description,
    uint256 _epochTime
  ) 
    external 
    onlyRole(BRAND_MANAGER_ROLE)  
  {
    uint256 _proposalId = uint256(keccak256(abi.encode(_targetAddress, _values, _calldatas, keccak256(bytes(_description)))));
    if(_secondEarliestProposalId[_proposalId] != uint256(0)){
      revert OnlyRegisterProposalIdOnce();
    }
    proposals[_proposalId] = proposalInfo(_targetAddress, _values, _calldatas, _description);
    uint256 index = _findIndex(_epochTime);
    proposalIds[_proposalId] = _epochTime;
    _secondEarliestProposalId[_proposalId] = _secondEarliestProposalId[index];
    _secondEarliestProposalId[index] = _proposalId;
    daoByProposalId[_proposalId] = currentDao;
    listSize++;
  }

  function removeProposalId(uint256 _proposalId) external onlyRole(BRAND_MANAGER_ROLE) {
    uint256 preOrderVault = _getPrevOrderProposalId(_proposalId);
    _secondEarliestProposalId[preOrderVault] = _secondEarliestProposalId[_proposalId];
    _secondEarliestProposalId[_proposalId] = uint256(0);
    proposalIds[_proposalId] = 0;
    listSize--;
    delete proposals[_proposalId];
    delete daoByProposalId[_proposalId];
  }

  function getList(uint256 _size) external view returns(uint256[] memory) {
    require(_size <= listSize);
    uint256[] memory proposalIdList = new uint256[](_size);
    uint256 currentProposalId = _secondEarliestProposalId[GUARD];
    for(uint256 i = 0; i < _size; ++i) {
      proposalIdList[i] = currentProposalId;
      currentProposalId = _secondEarliestProposalId[currentProposalId];
    }
    return proposalIdList;
  }

  function getEarlistEndOfDate() 
    external 
    view 
    returns(
      uint256 _time, 
      uint256 _proposalId
    ) 
  {
    _time = proposalIds[_secondEarliestProposalId[GUARD]];
    _proposalId = _secondEarliestProposalId[GUARD];
  }

  function _verifyIndex(uint256 _prevHash, uint256 _epochTime, uint256 _nextHash)
    internal
    view
    returns(bool)
  {
    return (_prevHash == GUARD || proposalIds[_prevHash] <= _epochTime) && 
           (_nextHash == GUARD || _epochTime < proposalIds[_nextHash]);
  }

  function _findIndex(uint256 _epochTime) internal view returns(uint256) {
    uint256 candidateProposalId = GUARD;
    while(true) {
      if(_verifyIndex(candidateProposalId, _epochTime, _secondEarliestProposalId[candidateProposalId]))
        return candidateProposalId;
      candidateProposalId = _secondEarliestProposalId[candidateProposalId];
    }
    return 0;
  }

  function _isPrevOrderProposalId(
    uint256 _proposalId, 
    uint256 _preOrderProposalId
  ) 
    internal 
    view 
    returns(bool) 
  {
    return _secondEarliestProposalId[_preOrderProposalId] == _proposalId;
  }

  function _getPrevOrderProposalId(uint256 _proposalId) internal view returns(uint256) {
    uint256 currentProposalId = GUARD;
    while(_secondEarliestProposalId[currentProposalId] != GUARD) {
      if(_isPrevOrderProposalId(_proposalId, currentProposalId))
        return currentProposalId;
      currentProposalId = _secondEarliestProposalId[currentProposalId];
    }
    return 0;
  }
}