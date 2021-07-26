//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol';
import '@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol';
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC721/IERC721.sol';
import 'hardhat/console.sol';

/**
 * @title Base contract for different pool types.
 */
contract MenthaPoolBase is 
    ERC20Upgradeable, 
    OwnableUpgradeable, 
    ReentrancyGuardUpgradeable, 
    PausableUpgradeable {

    // Structs
    struct NFT {
        address addr;
        uint index;
        address payable creator;
    }

    // Constants
    string public constant TOKEN_NAME_SUFFIX = "LP Mentha Token";
    string public constant TOKEN_SYMBOL_PREFIX = "mth";

    // Variables
    mapping(address => uint) internal tickets;
    address[] internal players;
    uint public numberOfTickets;
    NFT[] public nfts;
    uint private nextNftToBeTransferred;

    // Events
    event NFTAdded(uint nftId, address indexed nftAddress, uint nftIndex, address indexed creator);

    /**
     * @notice Contract initializer method.
     * @param _symbol - LP token symbol without prefix.
     */
    function initialize(string memory _symbol) public initializer {
        __Ownable_init();
        __ReentrancyGuard_init();
        __Pausable_init();
        __ERC20_init(
            string(abi.encodePacked(TOKEN_SYMBOL_PREFIX, _symbol, ' ', TOKEN_NAME_SUFFIX)),
            string(abi.encodePacked(TOKEN_SYMBOL_PREFIX, _symbol))
        );
    }

    // Public methods

    /**
     * @notice Adding a new NFT to the contract in order to be transferred as a pool prize.
     * @param _nftAddress - NFT contract's address.
     * @param _nftIndex - NFT index parameter.
     */
    function appendNFT(address _nftAddress, uint _nftIndex) external {
        require(_nftAddress != address(0), 'A valid address is required');
        require(IERC721(_nftAddress).getApproved(_nftIndex) == address(this), 'Contract is not approved to transfer NFT');

        // Adding NFT to collection
        NFT memory nft = NFT({
            addr: _nftAddress, 
            index: _nftIndex, 
            creator: payable(msg.sender)
        });
        nfts.push(nft);

        // Emiting event
        emit NFTAdded(nfts.length - 1, _nftAddress, _nftIndex, msg.sender);
    }

    /**
     * Transfering NFT prize to winner.
     */
    function transferNFT() external onlyOwner {
        address winner = _calculateWinner();

        NFT memory nft = nfts[nextNftToBeTransferred];
        nextNftToBeTransferred += 1;

        // Transfering NFT prize to winner        
        IERC721(nft.addr).transferFrom(nft.creator, winner, nft.index);
    }

    /**
     * Getting number of pending NFTs to be transferred.
     */
    function numberOfNFT() public view returns(uint) {
        return nfts.length - nextNftToBeTransferred;
    }

    /**
     * @notice Returns number of tickets for an address.
     * @param _addr - Player address.
     * @return Number of tickets bought for an address.
     */
    function ticketsOf(address _addr) public view returns (uint) {
        return tickets[_addr];
    }

    // Private methods

    /**
     * @notice Calculating lottery pool winner.
     * @return Winner address.
     */ 
    function _calculateWinner() internal view returns (address) {        
        uint index = uint(keccak256(abi.encodePacked(block.timestamp, block.difficulty))) % players.length;
        return players[index];
    }

}