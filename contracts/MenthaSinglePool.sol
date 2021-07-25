//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import './MenthaPoolBase.sol';
import 'hardhat/console.sol';

/**
 * @title Single asset pool contract.
 */
contract MenthaSinglePool is MenthaPoolBase {

    // Variables
    IERC20 public collateral;
    uint public ticketPrice;
    uint public totalCollateral;

    // Events
    event TicketsBought(address indexed buyer, uint numberOfTickets, uint amount);
    event TicketsRedeemed(address indexed buyer, uint numberOfTickets, uint amount);

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
        ) public initializer {
        
        // Initializing base contract
        MenthaPoolBase.initialize(_symbol);

        collateral = IERC20(_collateral);
        ticketPrice = _ticketPrice;
    }

    /**
     * @notice Method used to buy a lottery ticket.
     * @param _numberOfTickets - Number of the tickets to buy.
     */
    function buyTickets(uint _numberOfTickets) public whenParentNotPaused {
        // require(status == LotteryPoolStatus.OPEN, 'The lottery pool is not open');
        uint amount = ticketPrice * _numberOfTickets;

        // Checking sender token balance
        require(collateral.balanceOf(msg.sender) >= amount, 'Not enough tokens');

        // Creating tickets
        tickets[msg.sender] += _numberOfTickets;
        for (uint i=0; i<_numberOfTickets; i++) {
            players.push(msg.sender);
        }
        numberOfTickets += _numberOfTickets;
        totalCollateral+= amount;

        // Transfering requester tokens to contract's balance
        require(collateral.allowance(msg.sender, address(this)) >= amount, "Contract is not allowed to transfer tokens");
        bool sent = collateral.transferFrom(msg.sender, address(this), amount);
        require(sent, "Token transfer failed");

        // Emiting event
        emit TicketsBought(msg.sender, _numberOfTickets, amount);
    }

    /**
     * @notice Method used to redeem bought tickets once the pool is closed.
     * @param _numberOfTickets - Number of the tickets to be redeemed.
     */
    function redeemTickets(uint _numberOfTickets) public nonReentrant {
        require(tickets[msg.sender] > 0 && tickets[msg.sender] >= _numberOfTickets, 'You do not have enough tickets');

        _redeemTickets(_numberOfTickets, msg.sender);
    }

    /**
     * @notice Contract balances.
     * @return Collateral locked in the contract.
     */
    function getBalance() external view returns(uint) {
        return collateral.balanceOf(address(this));
    }

    // Private methods

    /**
     * @notice Method used to redeem bought tickets once the pool is closed.
     * @param _numberOfTickets - Number of the tickets to be cancelled.
     */
    function _redeemTickets(uint _numberOfTickets, address sender) internal {
        // Calculating amount to redeem
        uint amount = ticketPrice * _numberOfTickets;
        require(totalCollateral >= amount, 'Not enough money in the balance');

        // Decreasing number of tickets
        tickets[msg.sender] -= _numberOfTickets;
        numberOfTickets -= _numberOfTickets;
        totalCollateral -= amount;

        // Delete items from players array
        uint deleted = 0;
        for (uint i=0; i<players.length; i++) {
            if( players[i] == sender && deleted < _numberOfTickets) {
                delete players[i];
                deleted += 1;
            }
        }

        // Transfering amount to sender
        bool sent = collateral.transfer(msg.sender, amount);
        require(sent, "Token transfer failed");

        // Emiting event
        emit TicketsRedeemed(msg.sender, _numberOfTickets, amount);
    }

}