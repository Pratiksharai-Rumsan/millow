//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

interface IERC721 {
    function transferFrom(address _from, address _to, uint256 _id) external;
}

contract Escrow {
    address public nftAddress;

    address public lender;
    address public inspector;
    address payable public seller;

    modifier onlyBuyer(uint256 _nftId) {
        require(
            msg.sender == buyer[_nftId],
            "only buyer can call this function"
        );
        _;
    }
    modifier onlySeller() {
        require(msg.sender == seller, "only seller can call this function");
        _;
    }
    modifier onlyInspector() {
        require(
            msg.sender == inspector,
            "only inspector can call this function"
        );
        _;
    }
    mapping(uint256 => bool) public isListed;
    mapping(uint256 => uint256) public purchasePrice;
    mapping(uint256 => uint256) public escrowAmount;
    mapping(uint256 => address) public buyer;
    mapping(uint256 => bool) public inspectionPassed;
    mapping(uint256 => mapping(address => bool)) public approval;

    constructor(
        address _nftAddress,
        address payable _seller,
        address _inspector,
        address _lender
    ) {
        nftAddress = _nftAddress;
        seller = _seller;
        inspector = _inspector;
        lender = _lender;
    }
    function list(
        uint256 _nftId,
        address _buyer,
        uint256 _purchasePrice,
        uint256 _escrowAmount
    ) public payable onlySeller {
        //transfer nft from seller to the contract
        IERC721(nftAddress).transferFrom(msg.sender, address(this), _nftId);
        isListed[_nftId] = true;
        purchasePrice[_nftId] = _purchasePrice;
        escrowAmount[_nftId] = _escrowAmount;
        buyer[_nftId] = _buyer;
    }
    //put under contract (only buyer - payable escrow amoutn)
    function depositEarnest(uint256 _nftId) public payable onlyBuyer(_nftId) {
        require(msg.value >= escrowAmount[_nftId]);
    }
    //update inspection status
    function updateInspectionStatus(
        uint256 _nftId,
        bool _passed
    ) public onlyInspector {
        inspectionPassed[_nftId] = _passed;
    }

    //approve the sell

    function approveSell(uint256 _nftId) public {
        approval[_nftId][msg.sender] = true;
    }
    //finalize sale
    //require inspection passed, lender, inspector and buyer approved
    //require sale to be authorized
    // require buyer to have deposited earnest
    //transfer nft to buyer
    //transfer funds to sellar

    function finalizeSale(uint256 _nftId) public {
        require(inspectionPassed[_nftId]);
        require(approval[_nftId][lender]);
        require(approval[_nftId][seller]);

        require(approval[_nftId][buyer[_nftId]]);
        require(address(this).balance >= purchasePrice[_nftId]);
        isListed[_nftId] = false;

        (bool success, ) = payable(seller).call{value: address(this).balance}(
            ""
        );
        require(success);
        IERC721(nftAddress).transferFrom(address(this), buyer[_nftId], _nftId);
    }

    //cansel sael (handle eanest deposit)
    //if inspection status is not approved, then refund , otherwise send to seller
    function cancelSale(uint256 _nftId) public {
        if (inspectionPassed[_nftId]) {
            payable(buyer[_nftId]).transfer(address(this).balance);
        } else {
            payable(seller).transfer(address(this).balance);
        }
    }
    receive() external payable {}
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
