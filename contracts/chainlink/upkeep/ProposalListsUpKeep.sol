// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
import "./upkeepAutomation/AutomationCompatible.sol";
import "../../interfaces/ISortedList.sol";
import "../../interfaces/IGovernorContract.sol";
contract ProposalListsUpKeep is AutomationCompatibleInterface {
    
    /// Immutable
    ISortedList public immutable SORTED_PROPOSAL_LIST;
    
    /// Event 
    event QueueFromUpkeep(uint256 proposalId);
    event RemoveProposalInTheListFromUpkeep(uint256 proposalId);

    constructor(address _sorted_proposal_list_address) {
        SORTED_PROPOSAL_LIST = ISortedList(_sorted_proposal_list_address); 
    }

    function getSizeOfSortedProposalList() external view returns (uint256) {
        return SORTED_PROPOSAL_LIST.listSize();
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
        if(SORTED_PROPOSAL_LIST.listSize() > 0) {
        (uint256 earliestBlockOfProposal, ) = SORTED_PROPOSAL_LIST.getEarlistEndOfDate();
        upkeepNeeded = earliestBlockOfProposal < block.number; 
        }else{
            upkeepNeeded = false;
        }
    }

    function performUpkeep(bytes calldata /* performData */) external override {
         (uint256 earliestBlockOfProposal, uint256 earliestDateOfproposalId) = SORTED_PROPOSAL_LIST.getEarlistEndOfDate();
         if (earliestBlockOfProposal < block.number) {
            (address currentDaoAddress, address[] memory targetAddress, uint256[] memory values, bytes[] memory calldatas, string memory description) = SORTED_PROPOSAL_LIST.getProposals(earliestDateOfproposalId);
            uint256 currentState = uint256(IGovernorContract(currentDaoAddress).state(earliestDateOfproposalId));
            /// currentState == 4 (ProposalState.Succeeded)
            if(currentState == 4) {
                IGovernorContract(currentDaoAddress).queue(targetAddress, values, calldatas, keccak256(bytes(description)));
                emit QueueFromUpkeep(earliestDateOfproposalId);
            } else {
                IGovernorContract(currentDaoAddress).removeProposalInTheList(earliestDateOfproposalId);
                emit RemoveProposalInTheListFromUpkeep(earliestDateOfproposalId);
            }
        }
    }

}
