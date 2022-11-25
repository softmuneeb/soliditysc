// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";

pragma solidity ^0.8.17;

/// @author someone in metaverse
contract ClaimSpotSale is Ownable {
    uint256 public claimSpotsSold = 0;
    mapping(address => uint256) public claimSpotsBoughtBy;

    uint256 public claimSpotsToSell = 5000;
    uint256 public costPerClaim = 0.01 * 1e18;
    uint256 public maxMintClaimSpotAmount = 10;
    uint256 public claimSpotMintActiveTime = type(uint256).max;

    event PurchasedClaimSpot(address, uint256);

    /// @notice people can buy claim spots here when sale is open
    function purchaseClaimSpot(uint256 _mintAmount) external payable {
        require(_mintAmount > 0, "need to mint at least 1 spot");
        require(msg.value == costPerClaim * _mintAmount, "incorrect funds");
        require(
            block.timestamp > claimSpotMintActiveTime,
            "The Claim Spot Mint is paused"
        );
        require(
            claimSpotsBoughtBy[msg.sender] + _mintAmount <=
                maxMintClaimSpotAmount,
            "max mint amount per session exceeded"
        );
        require(
            claimSpotsSold + _mintAmount <= claimSpotsToSell,
            "max mint amount per session exceeded"
        );

        claimSpotsBoughtBy[msg.sender] += _mintAmount;
        claimSpotsSold += _mintAmount;

        emit PurchasedClaimSpot(msg.sender, _mintAmount);
    }

    /// @notice owner can withdraw funds from here
    function withdraw() public payable onlyOwner {
        (bool success, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(success);
    }

    /// @dev setters

    /// @notice owner can change the price of claim spots
    function setCostPerClaim(uint256 _costPerClaim) public onlyOwner {
        costPerClaim = _costPerClaim;
    }

    /// @notice owner can change the total number of claim spots to sell
    function setClaimSpotsToSell(uint256 _claimSpotsToSell) public onlyOwner {
        claimSpotsToSell = _claimSpotsToSell;
    }

    /// @notice owner can change the per wallet max mint claim spots
    function setMaxMintClaimSpotAmount(uint256 _maxMintClaimSpotAmount)
        public
        onlyOwner
    {
        maxMintClaimSpotAmount = _maxMintClaimSpotAmount;
    }

    /// @notice Owner can open or close the sale. To open put 0, to close put 99999999999999999999, to start at specific time get time value from here https://www.epochconverter.com/
    function setClaimSpotMintActiveTime(uint256 _claimSpotMintActiveTime)
        public
        onlyOwner
    {
        claimSpotMintActiveTime = _claimSpotMintActiveTime;
    }
}
