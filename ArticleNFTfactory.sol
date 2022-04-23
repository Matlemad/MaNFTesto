// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract ArticleNFTs is ERC721, ERC721URIStorage, ERC721Burnable, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    ERC721 memberNFTAddress; //  POAP / gating token contract address of the community
    uint256 memberTokenId; //  POAPs / gating token Collection Id of the community
    address public articleDestroyer;

    modifier isMember {
        require(msg.sender == memberNFTAddress.ownerOf(memberTokenId), "you need 1 membership NFT at least");
        _;
    }

    modifier onlyDestroyer {
        require(msg.sender == articleDestroyer);
        _;
    }


    constructor(string memory _ArticleNFTname, string memory _ArticleNFTticker, ERC721 _membershipTokenAddr,uint256 _membershipTokenID, address _Destroyer) ERC721(_ArticleNFTname, _ArticleNFTticker) {
        memberNFTAddress = _membershipTokenAddr;
        memberTokenId = _membershipTokenID;
        articleDestroyer = _Destroyer;
    }

    function _baseURI() internal pure override returns (string memory) {
        return "link";
    }

    function mintArticle(address to, string memory metadataUrl) public isMember {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, metadataUrl);
    }

    // The following functions are overrides required by Solidity.

    function _burn(uint256 tokenId) internal onlyDestroyer override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }
}
