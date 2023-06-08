// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../../node_modules/erc721a/contracts/ERC721A.sol";
import "./VotesC.sol";


abstract contract ERC721AVotes is ERC721A, VotesC {
    
    function _afterTokenTransfers(
        address from,
        address to,
        uint256 firstTokenId,
        uint256 batchSize
    ) internal virtual override(ERC721A) {
       
        _transferVotingUnits(from, to, batchSize);
        super._afterTokenTransfers(from, to, firstTokenId, batchSize);
    }


    function _getVotingUnits(address account) internal view virtual override returns (uint256) {
        return balanceOf(account);
    }


}
