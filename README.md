#ABSTRACT <br>
a MaNFTesto is a container NFT where other Article NFTs can be added, upVoted and downVoted by a given token community.


#CONTRACTS <br>
 - ArticleNFTs.sol _ modification of ERC721. This is a factory where a green-listed token community can mint Article NFTs. 
    Articles are NFTs with text-only JSON metadata

 - MaNFTesto.sol_ modification of ERC721. This is a factory where:
    anyone can mint new MaNFTestos
    define the green-listed community by token
    assign a specific ArticleNFT factory address to limit the MaNFTesto to
    add Article NFTs to the minted MaNFTesto
    UpVote and downVote each Article NFT in the MaNFTesto 
    
 - both contracts specify a Destroyer address (wallet, Multisig, DAO, contract) 
    who has burning permission for Article and MaNFTesto NFTs
