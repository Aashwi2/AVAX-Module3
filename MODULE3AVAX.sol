// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract CharityToken is ERC20 {

    struct Charity {
        uint charityId;
        address charityAddress;
        string name;
        uint tokenReceived;
    }

    struct Donor {
        uint donorId;
        address donorAddress;
        uint totalDonated;
    }

    uint private charityCount;
    uint private donorCount;
    mapping(address => uint) charityIndex;
    mapping(address => uint) donorIndex;
    address private owner;

    modifier onlyOwner {
        require(msg.sender == owner, "Only owner can execute this");
        _;
    }

    Charity[] public charities;
    Donor[] public donors;

    constructor() ERC20("CharityToken", "CHRT") {
        owner = msg.sender;
        _mint(msg.sender, 10000000000); // Mint initial supply to the owner
    }

    function mintTokens(uint _amount) external onlyOwner {
        _mint(msg.sender, _amount);
    }

    function registerCharity(address _address, string memory _name) external onlyOwner {
        Charity memory newCharity = Charity(charityCount, _address, _name, 0);
        charities.push(newCharity);
        charityIndex[_address] = charityCount;
        charityCount++;
    }

    function registerDonor(address _address) external {
        require(donorIndex[_address] == 0, "Donor is already registered");
        Donor memory newDonor = Donor(donorCount, _address, 0);
        donors.push(newDonor);
        donorIndex[_address] = donorCount;
        donorCount++;
    }

    function donateToCharity(address _charityAddress, uint _amount) external {
        require(balanceOf(msg.sender) >= _amount, "Insufficient token balance");
        require(charityIndex[_charityAddress] != 0, "Charity not registered");

        _transfer(msg.sender, _charityAddress, _amount);
        charities[charityIndex[_charityAddress]].tokenReceived += _amount;
        donors[donorIndex[msg.sender]].totalDonated += _amount;
    }

    function viewCharities() external view returns(Charity[] memory) {
        return charities;
    }

    function viewDonors() external view returns(Donor[] memory) {
        return donors;
    }

    function burnTokens(uint _amount) external {
        _burn(msg.sender, _amount);
    }

    function transferTokens(address _to, uint _amount) external {
    require(balanceOf(msg.sender) >= _amount, "Insufficient token balance");
    require(_to != address(0), "Cannot transfer to zero address");

    // Define a burn ratio or amount that needs to be burnt after transfer.
    uint burnAmount = _amount; 
    uint transferAmount = _amount - burnAmount;

    _transfer(msg.sender, _to, transferAmount);
    
    _burn(msg.sender, burnAmount);
}

}
