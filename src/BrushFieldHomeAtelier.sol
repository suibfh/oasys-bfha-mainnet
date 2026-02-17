// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title Brush Field Home Atelier (BFHA)
 * @notice Pixel Art NFT Contract - burns BPC to mint NFTs
 * @dev Users approve BPC, call mint(), which transfers BPC to 0x...dEaD then mints NFT
 *
 * Mint flow:
 *   1. User calls BPC.approve(this, BPC_FEE)
 *   2. User calls BFHA.mint(tokenUri)
 *   3. Contract checks allowance >= BPC_FEE
 *   4. Contract calls BPC.transferFrom(user, 0x...dEaD, BPC_FEE)
 *   5. On transfer success: NFT is minted to user
 *   6. On transfer failure: revert (NFT is NOT minted)
 */
contract BrushFieldHomeAtelier is ERC721, ReentrancyGuard {

    // =========================================================
    //  Constants
    // =========================================================

    /// @notice BPC fee required to mint one NFT (1000 BPC, 18 decimals)
    uint256 public constant BPC_FEE = 1000 * 10 ** 18;

    /// @notice Burn destination (tokens sent here are irretrievable)
    address public constant BURN_ADDRESS = 0x000000000000000000000000000000000000dEaD;

    // =========================================================
    //  Immutables
    // =========================================================

    /// @notice BPC token - set once at deploy, never changed
    IERC20 public immutable BPC;

    // =========================================================
    //  State
    // =========================================================

    /// @notice Monotonically increasing token ID counter
    uint256 private _tokenIdCounter;

    /// @notice tokenId => metadata URI
    mapping(uint256 => string) private _tokenURIs;

    // =========================================================
    //  Errors
    // =========================================================

    /// @notice Thrown when BPC.allowance(user, this) < BPC_FEE
    error InsufficientBPCAllowance(uint256 required, uint256 actual);

    /// @notice Thrown when BPC.transferFrom returns false
    error BPCTransferFailed();

    // =========================================================
    //  Events
    // =========================================================

    /// @notice Emitted on each successful mint
    event Minted(address indexed minter, uint256 indexed tokenId, string tokenUri);

    // =========================================================
    //  Constructor
    // =========================================================

    /**
     * @param _bpc BPC token address
     *             Testnet : 0x83854AA73B858D90DF8EaC8fA811eAae7D05aD40
     *             Mainnet : 0x9A340A0dE81B23eCd37ba9c4845dff5850A7e7a4
     */
    constructor(address _bpc) ERC721("Brush Field Home Atelier", "BFHA") {
        require(_bpc != address(0), "BPC address is zero");
        BPC = IERC20(_bpc);
    }

    // =========================================================
    //  External
    // =========================================================

    /**
     * @notice Mint one BFHA NFT by burning BPC_FEE BPC tokens
     *
     * Requirements:
     *   - msg.sender must have called BPC.approve(this, >= BPC_FEE) beforehand
     *   - BPC.transferFrom must succeed (returns true)
     *
     * @param tokenUri Metadata URI (e.g. https://example.com/meta-XXXXX.json)
     */
    function mint(string calldata tokenUri) external nonReentrant {
        // 1. Check allowance
        uint256 allowance = BPC.allowance(msg.sender, address(this));
        if (allowance < BPC_FEE) {
            revert InsufficientBPCAllowance(BPC_FEE, allowance);
        }

        // 2. Transfer BPC to burn address
        bool ok = BPC.transferFrom(msg.sender, BURN_ADDRESS, BPC_FEE);
        if (!ok) {
            revert BPCTransferFailed();
        }

        // 3. Mint NFT
        uint256 tokenId = _tokenIdCounter++;
        _mint(msg.sender, tokenId);
        _tokenURIs[tokenId] = tokenUri;

        emit Minted(msg.sender, tokenId, tokenUri);
    }

    // =========================================================
    //  Views
    // =========================================================

    /// @notice Total number of NFTs minted
    function totalSupply() external view returns (uint256) {
        return _tokenIdCounter;
    }

    /// @inheritdoc ERC721
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        _requireOwned(tokenId);
        return _tokenURIs[tokenId];
    }
}
