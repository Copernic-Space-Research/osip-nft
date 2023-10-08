// SPDX-License-Identifier: private
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract InstantListing {
    address public platformOperator;
    uint256 public operatorFee;

    event NewListing(
        address indexed seller,
        address indexed asset,
        uint256 indexed assetID,
        uint256 amount,
        uint256 price,
        address money,
        uint256 sellID
    );

    event Buy(address buyer, uint256 sellID);

    struct Listing {
        address asset;
        address seller;
        uint256 amount;
        uint256 minAmount;
        uint256 assetID;
        uint256 price;
        address money;
        uint256 sellID;
    }

    uint256 private numListings;
    mapping(uint256 => Listing) private listings;

    constructor(address _platformOperator, uint256 _operatorFee) {
        platformOperator = _platformOperator;
        operatorFee = _operatorFee;
    }

    function sell(
        address asset,
        uint256 assetID,
        uint256 amount,
        uint256 minAmount,
        uint256 price,
        address money
    ) public returns (uint256 sellID) {
        require(
            IERC1155(asset).balanceOf(msg.sender, assetID) >= amount,
            "Failed to create new sell, insuffucient balance"
        );
        require(
            IERC1155(asset).isApprovedForAll(msg.sender, address(this)) == true,
            "This contract has no approval to operate sellers assets"
        );

        sellID = numListings++;
        Listing storage listing = listings[sellID];
        listing.asset = asset;
        listing.seller = msg.sender;
        listing.amount = amount;
        listing.minAmount = minAmount;
        listing.assetID = assetID;
        listing.price = price;
        listing.money = money;
        listing.sellID = sellID;
        emit NewListing(
            msg.sender,
            asset,
            assetID,
            amount,
            price,
            money,
            sellID
        );
    }

    function getListing(
        uint256 id
    )
        public
        view
        returns (
            address seller,
            uint256 assetID,
            uint256 price,
            address money,
            uint256 sellID
        )
    {
        Listing memory offer = listings[id];
        return (
            offer.seller,
            offer.assetID,
            offer.price,
            offer.money,
            offer.sellID
        );
    }

    function buy(uint256 sellID, uint256 amount) public {
        Listing memory listing = listings[sellID];

        require(listing.amount >= amount, "Not enough asset balance on sale");
        require(
            amount >= listing.minAmount,
            "Can not buy less than min amount"
        );

        address buyer = msg.sender;
        uint256 amountPrice = listing.price * amount;
        require(
            IERC20(listing.money).allowance(buyer, address(this)) >=
                amountPrice,
            "Insufficient balance via allowance to purchase"
        );

        // sendRoyalties(); // @TODO reduce amountPrice by royalties after implemented
        IERC20(listing.money).transferFrom(buyer, listing.seller, amountPrice);

        listing.amount = listing.amount - amount;
        ERC1155(listing.asset).safeTransferFrom(
            listing.seller,
            buyer,
            listing.assetID,
            amount,
            ""
        );
        emit Buy(buyer, sellID);
    }

    function sendRoyalties(
        Listing memory offer,
        uint256 amountPrice,
        uint256 decimals,
        address assetCreator,
        address buyer
    ) internal returns (uint256, uint256) {
        // to be implemented ...
        // use Asset ERC2981 royalty standard for easy coms
    }
}
