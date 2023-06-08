// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
import "./upkeepAutomation/AutomationCompatible.sol";
import "../../interfaces/ISortedList.sol";
import "../../interfaces/IGovernorContract.sol";
contract QueueAndExecutionListsUpKeep is AutomationCompatibleInterface {
   
    /// Immutable
    ISortedList public immutable SORTED_QUEUE_AND_EXECUTION_LIST;

    /// Event 
    event ExecutionFromUpkeep(uint256 proposalId);
    event RemoveProposalInTheListFromUpkeep(uint256 proposalId);

    /// Variable
    constructor(address _sorted_Queue_And_Execution_list_address) {
        SORTED_QUEUE_AND_EXECUTION_LIST = ISortedList(_sorted_Queue_And_Execution_list_address); 
    }

    function getSizeOfSortedQueueAndExecutionList() external view returns (uint256) {
        return SORTED_QUEUE_AND_EXECUTION_LIST.listSize();
    }

    function checkUpkeep(bytes calldata /* checkData */)
        external 
        view 
        override 
        returns (
            bool upkeepNeeded, 
            bytes memory /* performData */
        ) 
    {
        if(SORTED_QUEUE_AND_EXECUTION_LIST.listSize() > 0) {
        (uint256 earliestDateOfQueueProposal, ) = SORTED_QUEUE_AND_EXECUTION_LIST.getEarlistEndOfDate();
        upkeepNeeded = earliestDateOfQueueProposal < block.timestamp; 
        }else{
            upkeepNeeded = false;
        }
    }

    function performUpkeep(bytes calldata /* performData */) external override {
        (uint256 earliestDateOfQueueProposal, uint256 earliestDateOfQueueProposalId) = SORTED_QUEUE_AND_EXECUTION_LIST.getEarlistEndOfDate();
        if (earliestDateOfQueueProposal < block.timestamp) {
           (address currentDaoAddress, address[] memory targetAddress, uint256[] memory values, bytes[] memory calldatas, string memory description) = SORTED_QUEUE_AND_EXECUTION_LIST.getProposals(earliestDateOfQueueProposalId);
           uint256 currentState = uint256(IGovernorContract(currentDaoAddress).state(earliestDateOfQueueProposalId));
           /// currentState == 5 (ProposalState.Queued)
           if(currentState == 5) {
                IGovernorContract(currentDaoAddress).execute(targetAddress, values, calldatas, keccak256(bytes(description)));
                emit ExecutionFromUpkeep(earliestDateOfQueueProposalId);
           } else{
                IGovernorContract(currentDaoAddress).removeProposalInTheList(earliestDateOfQueueProposalId);
                emit RemoveProposalInTheListFromUpkeep(earliestDateOfQueueProposalId);
           }
       }
   }

}