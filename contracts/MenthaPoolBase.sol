//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol';
import '@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol';
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import 'hardhat/console.sol';

/**
 * @title Base contract for different pool types.
 */
contract MenthaPoolBase is ERC20Upgradeable, OwnableUpgradeable, ReentrancyGuardUpgradeable, PausableUpgradeable {

    // Constants
    string public constant TOKEN_NAME_SUFFIX = "LP Mentha Token";
    string public constant TOKEN_SYMBOL_PREFIX = "mth";

    // Variables
    mapping(address => uint) internal tickets;
    address[] internal players;
    uint public numberOfTickets;

    // /**
    //  * @notice Contract constructor method.
    //  * @param _symbol - LP token symbol without prefix.
    //  */
    // constructor(
    //     string memory _symbol
    //     ) ERC20(
    //         string(abi.encodePacked(TOKEN_SYMBOL_PREFIX, _symbol, ' ', TOKEN_NAME_SUFFIX)),
    //         string(abi.encodePacked(TOKEN_SYMBOL_PREFIX, _symbol))
    //         ) {
    // }

    // /**
    //  * @notice Contract constructor method.
    //  */
    // constructor() ERC20Upgradeable() {
    //     __Ownable_init();
    //     // __ReentrancyGuard_init();
    //     // __Pausable_init();
    // }

    /**
     * @notice Contract initializer method.
     * @param _symbol - LP token symbol without prefix.
     */
    function _init(string memory _symbol) internal {
        __ReentrancyGuard_init();
        __Ownable_init();
        __Pausable_init();
        __ERC20_init(
            string(abi.encodePacked(TOKEN_SYMBOL_PREFIX, _symbol, ' ', TOKEN_NAME_SUFFIX)),
            string(abi.encodePacked(TOKEN_SYMBOL_PREFIX, _symbol))
        );
    }

    // Public methods

    /**
     * @notice Returns number of tickets for an address.
     * @param _addr - Player address.
     * @return Number of tickets bought for an address.
     */
    function ticketsOf(address _addr) public view returns (uint) {
        return tickets[_addr];
    }

    // Modifiers

    modifier whenParentNotPaused {
        // require(!parent.paused(), 'Protocol has been paused by security');
        _;
    }

}