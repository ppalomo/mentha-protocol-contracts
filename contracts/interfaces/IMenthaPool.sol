//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

/** 
 * @title Mentha pool interface.
 */
interface IMenthaPool {

    /**
     * @notice Contract initializer method.
     * @param _symbol - Collateral ERC20 token symbol.
     * @param _collateral - Collateral ERC20 token address.
     * @param _ticketPrice - Single ticket price.
     */
    function initialize(
        string memory _symbol,
        address _collateral,
        uint _ticketPrice
        ) external;
    
}