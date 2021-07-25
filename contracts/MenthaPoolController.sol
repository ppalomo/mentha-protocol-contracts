//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "./interfaces/IMenthaPool.sol";
import "./utils/CloneFactory.sol";
import "hardhat/console.sol";

contract MenthaPoolController is CloneFactory, OwnableUpgradeable, ReentrancyGuardUpgradeable, PausableUpgradeable {

    // Variables
    address payable public wallet;
    mapping(uint => address) private masterPools;
    mapping(uint => bytes32) private poolTypes;
    IMenthaPool[] public pools;

    // Events
    event PoolCreated(uint poolId, address indexed creator, address poolAddress, uint ticketPrice, uint poolType, string symbol);

    // Public methods

    /**
     * @notice Contract initializer.
     */
    function initialize() public initializer {
        __Ownable_init();
        __ReentrancyGuard_init();
        __Pausable_init();

        // Initializing variables        
        wallet = payable(owner());
    }

    /**
     * @notice Creates a new pool.
     * @param _poolType - Pool type to be created.
     * @param _symbol - Collateral ERC20 token symbol.
     * @param _collateral - Collateral ERC20 token address.
     * @param _ticketPrice - Single ticket price.
     */
    function createPool(
        uint _poolType, 
        string memory _symbol, 
        address _collateral, 
        uint _ticketPrice) external onlyOwner {
        
        // for (uint i=0; i<_tokens.length; i++) {
        //     console.log(_tokens[i]);
        // }

        require(_collateral != address(0), 'A valid address is required');
        require(_ticketPrice > 0, 'A valid ticket price is required');

        // Getting master contract address
        address masterPoolAddress = masterPools[_poolType];
        require(masterPoolAddress != address(0), 'Master pool contract not deployed');

        // Cloning and deploying a new pool
        IMenthaPool pool = IMenthaPool(createClone(masterPoolAddress));
        pool.initialize(_symbol, _collateral, _ticketPrice);
        pools.push(pool);

        // Emiting event
        emit PoolCreated(pools.length - 1, msg.sender, address(pool), _ticketPrice, _poolType, _symbol);
    }

    /**
     * @notice Adds a new master lottery pool.
     * @param _poolTypeId - Pool type identifier.
     * @param _poolTypeName - Pool type name.
     * @param _masterPoolAddress - Master pool deployed address.
     */
    function addMasterPool(
        uint _poolTypeId, 
        bytes32 _poolTypeName, 
        address _masterPoolAddress
        ) external onlyOwner {

        poolTypes[_poolTypeId] = _poolTypeName;
        masterPools[_poolTypeId] = _masterPoolAddress;
    }

    /**
     * Method used to return number of created pools.
     */
    function numberOfPools() external view returns(uint) {
        return pools.length;
    }

}