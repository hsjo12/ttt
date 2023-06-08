// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (governance/extensions/GovernorVotes.sol)

pragma solidity ^0.8.0;

import "../GovernorC.sol";
import "../../../../node_modules/@openzeppelin/contracts/governance/utils/IVotes.sol";

/**
 * @dev Extension of {Governor} for voting weight extraction from an {ERC20Votes} token, or since v4.5 an {ERC721Votes} token.
 *
 * _Available since v4.3._
 */
abstract contract GovernorVotesC is GovernorC {
  
    
    /// Variable
    bool private isInitialized;

    /// Note: To use minimal proxy factory, keword immutable has to be deleted in the variable token
    IVotes public token;

    constructor(IVotes tokenAddress) {
        token = tokenAddress;
    }

    /// @dev Initailize token address used as votes
    function initGovernorVotes(IVotes _tokenAddress) internal {
        if(isInitialized) revert AlreadyInitialized();
        isInitialized = true;
        token = _tokenAddress;
    }

    /**
     * Read the voting weight from the token's built in snapshot mechanism (see {Governor-_getVotes}).
     */
    function _getVotes(
        address account,
        uint256 blockNumber,
        bytes memory /*params*/
    ) internal view virtual override returns (uint256) {
        return token.getPastVotes(account, blockNumber);
    }
}
