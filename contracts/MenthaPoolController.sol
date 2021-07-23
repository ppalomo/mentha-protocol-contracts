//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

// import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "./interfaces/IMenthaPool.sol";
// import "./interfaces/IStakingAdapter.sol";
import "./utils/CloneFactory.sol";
import "hardhat/console.sol";

contract MenthaPoolController is CloneFactory, OwnableUpgradeable, ReentrancyGuardUpgradeable, PausableUpgradeable {

    // Variables
    address payable public wallet;
    mapping(uint => address) private masterPools;
    mapping(uint => bytes32) private poolTypes;
    IMenthaPool[] public pools;

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
     * @param _poolType - ???.
     * @param _collateral - ????.
     * @param _ticketPrice - Ticket price.
     */
    function createPool(uint _poolType, address _collateral, uint _ticketPrice) external onlyOwner {
        
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
        pool.init(_collateral, _ticketPrice);
        pools.push(pool);

        // Emiting event
        // emit PoolCreated(lotteries.length - 1, msg.sender, address(lottery), _nftAddress, _nftIndex, _ticketPrice, created, _lotteryPoolType, _minProfit, stakingAdapter, stakingAdapterName);
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

}