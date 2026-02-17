// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title Brush Field Home Atelier (BFHA)
 * @notice Pixel Art NFT Contract with BPC Fee Mechanism
 * @dev Users mint NFTs by approving and burning BPC tokens
 */
contract BrushFieldHomeAtelier is ERC721 {
    /// @notice BPC fee required to mint one NFT (1000 BPC with 18 decimals)
    uint256 public constant BPC_FEE = 1000 * 10**18;
    
    /// @notice Address where BPC tokens are burned (0x...dEaD)
    address public constant BURN_ADDRESS = 0x000000000000000000000000000000000000dEaD;
    
    /// @notice BPC token contract address (immutable, set at deployment)
    IERC20 public immutable BPC;
    
    /// @notice Token ID counter for sequential minting
    uint256 private _tokenIdCounter;
    
    /// @notice Mapping from token ID to metadata URI
    mapping(uint256 => string) private _tokenURIs;
    
    /// @notice Error thrown when BPC allowance is insufficient
    error InsufficientBPCAllowance();
    
    /**
     * @notice Contract constructor
     * @param _bpc Address of the BPC (Brush Point Coin) token contract
     */
    constructor(address _bpc) ERC721("Brush Field Home Atelier", "BFHA") {
        BPC = IERC20(_bpc);
    }
    
    /**
     * @notice Mint a new NFT with pixel art metadata
     * @dev Requires user to have approved at least BPC_FEE tokens to this contract
     * @param tokenUri IPFS or HTTP URL pointing to the NFT metadata JSON
     */
    function mint(string memory tokenUri) external {
        // Check if user has approved enough BPC tokens
        if (BPC.allowance(msg.sender, address(this)) < BPC_FEE) {
            revert InsufficientBPCAllowance();
        }
        
        // Transfer (burn) BPC tokens from user to burn address
        BPC.transferFrom(msg.sender, BURN_ADDRESS, BPC_FEE);
        
        // Mint NFT to user
        uint256 tokenId = _tokenIdCounter++;
        _mint(msg.sender, tokenId);
        _tokenURIs[tokenId] = tokenUri;
    }
    
    /**
     * @notice Get metadata URI for a token
     * @param tokenId The token ID to query
     * @return The metadata URI string
     */
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        _requireOwned(tokenId);
        return _tokenURIs[tokenId];
    }
    
    /**
     * @notice Get total number of minted tokens
     * @return The total supply of NFTs
     */
    function totalSupply() public view returns (uint256) {
        return _tokenIdCounter;
    }
}
