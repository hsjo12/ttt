// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/** 
 * @title IDaoFactory
 * @notice The IDaoFactory has a struct for clonning Dao. 
 */

interface IDaoFactory {
    /**
     * @notice This is the type for initial values to clone Dao.
     * @param daoName is the name of dao.
     * @param owner is the address of owner.
     * @param voteMaximumSupply is the maximum supply of a NFT used as votes.
     * @param votePrice is the price of a NFT used as votes.
     * @param voteName is the name of a NFT used as votes.
     * @param voteSymbol is the symbol of a NFT used as votes.
     * @param voteURI is the URI of a NFT used as votes.
     * @param timelockMinDelay is the minimum delay for execution an approved proposal.
     * @param governanceVotingDelay is the delay since proposal is created until voting starts.
     * @param governanceQuorumPercentage is the minmum percentange to pass a proposal. 
     */
    struct createParams {
        string daoName;
        address owner;
        uint256 voteMaximumSupply;
        uint256 votePrice;
        string voteName;
        string voteSymbol;
        string voteURI;
        uint256 timelockMinDelay;
        uint256 governanceVotingDelay;
        uint256 governanceVotingPeriod;
        uint256 governanceQuorumPercentage;
    }


}