// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "./ArticleNFTs.sol"; 

/** MaNFTesto is a erc721 factory that creates "manifesto" NFTs, empty containers
that keep track of a Leaderboard of ArticleNFTs, voted by a token-gated community.

*/

contract MaNFTesto is ERC721, ERC721Burnable, ERC721URIStorage, Ownable { //the playlist can be transferred, sold
    
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;
    

    struct Manifesto { // we need a Manifesto struct for new manifestos
        string name;
        uint256 manifestoID;
        string manifestoMetadata; // might point to a Cover CID or at a ENS where the proposalNFT tokens metadata are listed by token id
        Article[] articles;
        mapping(address => uint256) voters; // keep track of the voters so the vote can be discarded.
        uint256 topScore;
        ERC721 memberNFTAddress; //  POAP / gating token contract address of the community
        uint256 memberTokenId; //  POAPs / gating token Collection Id of the community
        ERC721 articleNFTAddress; // the Article NFT factory address
        address manifestoDestroyer;
    }

    struct Article {
        address tokenAddress;
        uint tokenId;
        uint score;
    }    

    mapping (uint => Manifesto) public manifestos;    

    modifier hasRepToken(uint i) {
        Manifesto storage m = manifestos[i];
        require(msg.sender == m.memberNFTAddress.ownerOf(m.memberTokenId), "you need 1 membership NFT at least");
        _;
    }

    modifier onlyDestroyer(uint i) {
        Manifesto storage m = manifestos[i];
        require(msg.sender == m.manifestoDestroyer);
        _;
    }
    
    constructor() ERC721("MaNFTestoFactory", "MNFT") {}

    function safeMint(
        address to, 
        string memory _nameOfManifesto, 
        string memory _manifestoMetadata, 
        ERC721 _memberNFTAddr, 
        uint256 _tokenId,ERC721 _articleFactoryAddr, address _destroyer) public {

        uint256 tokenId = _tokenIdCounter.current();        
        manifestos[tokenId].name = _nameOfManifesto;
        manifestos[tokenId].manifestoID = tokenId;
        manifestos[tokenId].manifestoMetadata = _manifestoMetadata;
        manifestos[tokenId].memberNFTAddress = _memberNFTAddr;
        manifestos[tokenId].memberTokenId = _tokenId;
        manifestos[tokenId].articleNFTAddress = _articleFactoryAddr;
        manifestos[tokenId].manifestoDestroyer = _destroyer;
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);        
    }

    
    // The following functions are overrides required by Solidity.

    function _burn(uint256 tokenId) internal onlyDestroyer(tokenId) override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }
    
    // create a new Article struct out of an articleNFT
    function addArticle(uint256 _manifestoID, ERC721 _NFTcontract, uint256 _tokenId) external hasRepToken(_manifestoID) {
        Manifesto storage m = manifestos[_manifestoID];
        require(m.articleNFTAddress == _NFTcontract, "Invalid NFT contract address"); // make sure the songNFT belongs to the collection we declared
        Article memory newArticle;
        newArticle.tokenAddress = address(_NFTcontract);
        newArticle.tokenId = _tokenId;
        newArticle.score = 0;
        m.articles.push(newArticle);
    }

    function upvoteArticle (uint256 _manifestoID, uint256 index) external hasRepToken(_manifestoID) {
        Manifesto storage manifesto = manifestos[_manifestoID];
        Article storage currentArticle = manifesto.articles[index];

        currentArticle.score++;
              
        // keep track of the voter so he/she can discard the vote.
        manifesto.voters[msg.sender] = index + 1; // 0 means, it's not a voter
        

        if (currentArticle.score > manifesto.topScore) { // update TopScore if it is the highest
            manifesto.topScore = currentArticle.score;
        }
    }

    function downVote (uint256 _manifestoID, uint256 index) external hasRepToken(_manifestoID) {
        // get the playlist.
        Manifesto storage manifesto = manifestos[_manifestoID];
        // sender should already have voted in this leaderboard    
        require(manifesto.voters[msg.sender] > 0, "sender should be a voter");
        // reinitialize msg.sender as non-voter and continue.
        manifesto.voters[msg.sender] = 0;
        // get the article.   
        Article storage currentArticle = manifesto.articles[index];
        currentArticle.score--;
    } 

    function getManifesto(uint _manifestoID) public view returns(Article[] memory) {
        Manifesto storage manifesto = manifestos[_manifestoID];
        return manifesto.articles;
    }
}
