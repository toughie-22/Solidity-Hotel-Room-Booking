// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26; // Specify the Solidity version used for the contract

// Define the main contract for the hotel room booking system
contract HotelRoom { 
    // Enum to represent the possible status of the room (Vacant or Occupied)
    enum Statuses { Vacant, Occupied }
    // The current status of the room, publicly visible
    Statuses public currentStatus;

    // Event declaration to log when a room is occupied
    event Occupy(address _occupant, uint _value);

    // Address variable to store the owner's address, marked as payable to allow fund transfers
    address payable public owner;
    
    // Constructor function that sets the initial owner (the deployer's address)
    constructor() {
        owner = payable(msg.sender); // Set the owner to the address that deployed the contract
        currentStatus = Statuses.Vacant; // Initially, the room is vacant
    }

    // Modifier to ensure the room is vacant before allowing the booking
    modifier onlyWhileVacant() {
        require(currentStatus == Statuses.Vacant, "Currently occupied."); // Revert if the room is occupied
        _; // Proceed to the next function call if the room is vacant
    }
    
    // Modifier to ensure the caller sends enough ether for the booking
    modifier costs(uint _amount) {
        require(msg.value >= _amount, "Not enough ether provided."); // Revert if insufficient ether is provided
        _; // Proceed to the next function call if the correct ether amount is sent
    }

    // Function to book the room by sending ether, ensures room is vacant and sufficient ether is sent
    function book() public payable onlyWhileVacant costs(2 ether) {
        currentStatus = Statuses.Occupied; // Update the room status to "Occupied" after booking

        // Attempt to send the ether to the owner using a low-level call
        (bool sent, ) = owner.call{value: msg.value}(""); 
        require(sent, "Failed to send Ether"); // Revert if the ether transfer fails

        // Emit an event to log the room occupation with the occupant's address and the ether value
        emit Occupy(msg.sender, msg.value);
    }
}
