pragma solidity ^0.5.1;


contract RequestForQuotations {

    /* ------------- RFQ Model ------------- */

    enum RFQStatus { Received, Declined, QuoteProvided }

    struct RequestForQuotation {
        bytes32 id; // Useful for presence verification
        uint issuedAt;
        string ubl;
        RFQStatus status;
        bytes32[] quoteIds;
    }

    // TODO Maybe add ubl?
    event RFQReceived(bytes32 id, string ubl);


    /* ------------- Quote Model ------------- */

    enum QuoteStatus { Offer, Decline }

    struct Quote {
        bytes32 id; // Useful for presence verification
        uint issuedAt;
        string ubl;
        QuoteStatus status;
        bytes32 rfqId;
        address supplier;
    }

    event QuoteReceived(address indexed supplier, bytes32 rfqId, bytes32 quoteId);
    event RFQDeclined(address indexed supplier, bytes32 rfqId, bytes32 quoteId);


    /* ------------- RFQ State ------------- */

    uint public nbrOfRFQs;

    // Maps the id to the RFQ index
    mapping(bytes32 => RequestForQuotation) public rfqs;


    /* ------------- Quote State ------------- */

    uint public nbrOfQuotes;

    // Maps the id to the quote index
    mapping(bytes32 => Quote) public quotes;


    /* ------------- RFQ can only be submitted by a buyer ------------- */

    address private buyer;

    constructor() public {
        buyer = msg.sender;
    }

    function getBuyerAddress() public view returns (address) {
        return buyer;
    }

    modifier onlyBuyer() {
        require(msg.sender == buyer);
        _;
    }


    /* ------------- RFQ logic ------------- */

    function getRFQUBL(bytes32 id) public view returns (string memory ubl) {
        if (rfqs[id].id == id) {
            return rfqs[id].ubl;
        } else {
            return "";
        }
    }

    function submitRFQ(bytes32 id, uint issuedAt, string memory ubl) public onlyBuyer returns (bool success)  {
        rfqs[id].id = id;
        rfqs[id].issuedAt = issuedAt;
        rfqs[id].ubl = ubl;
        rfqs[id].status = RFQStatus.Received;

        nbrOfRFQs++;
        emit RFQReceived(id, ubl);
        return true;
    }


    /* ------------- Quote logic ------------- */

    function getQuoteUBL(bytes32 id) public view returns (string memory ubl) {
        if (quotes[id].id == id) {
            return quotes[id].ubl;
        } else {
            return "";
        }
    }

    function submitQuote(bytes32 id, bytes32 rfqId, uint issuedAt, string memory ubl) public returns (bool success)  {
        // Make sure the RFQ exists
        require(rfqs[rfqId].id == rfqId);

        // Create the quote and store it
        address supplier = msg.sender;
        quotes[id] = Quote(id, issuedAt, ubl, QuoteStatus.Offer, rfqId, supplier);

        // Update the corresponding RFQ
        rfqs[rfqId].status = RFQStatus.QuoteProvided;
        rfqs[rfqId].quoteIds.push(id);

        nbrOfQuotes++;
        emit QuoteReceived(supplier, rfqId, id);
        return true;
    }

    function declineRFQ(bytes32 id, bytes32 rfqId, uint issuedAt) public returns (bool success)  {
        // Make sure the RFQ exists
        require(rfqs[rfqId].id == rfqId);

        // Create the quote and store it
        address supplier = msg.sender;
        quotes[id] = Quote(id, issuedAt, "", QuoteStatus.Decline, rfqId, supplier);

        // Update the corresponding RFQ
        if (rfqs[rfqId].status == RFQStatus.Received) {
            rfqs[rfqId].status = RFQStatus.Declined;
        }
        rfqs[rfqId].quoteIds.push(id);

        nbrOfQuotes++;
        emit QuoteReceived(supplier, rfqId, id);
        return true;
    }
}
