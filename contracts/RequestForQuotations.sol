pragma solidity ^0.5.1;


contract RequestForQuotations {

    /* ------------- RFQ Model ------------- */

    enum RFQStatus { Received, Declined, QuoteProvided }

    struct RequestForQuotation {
        bytes32 id; // Useful for presence verification
        uint issuedAt;
        string ubl;
        RFQStatus status;
    }

    event RFQReceived(bytes32 id, uint issuedAt, string ubl);


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

    event QuoteReceived(address indexed supplier, bytes32 rfqId, bytes32 quoteId, uint issuedAt, string ubl);
    event RFQDeclined(address indexed supplier, bytes32 rfqId, bytes32 quoteId, uint issuedAt);


    /* ------------- RFQ State ------------- */

    uint public nbrOfRFQs;

    // Maps the id to the RFQ
    mapping(bytes32 => RequestForQuotation) rfqs;


    /* ------------- Quote State ------------- */

    uint public nbrOfQuotes;

    // Maps the id to the quote
    mapping(bytes32 => Quote) quotes;


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

    function getRFQ(bytes32 id) public view returns (
        uint issuedAt,
        string memory ubl,
        RFQStatus status
    ) {
        // Make sure the RFQ exists
        require(rfqs[id].id == id);

        issuedAt = rfqs[id].issuedAt;
        ubl = rfqs[id].ubl;
        status = rfqs[id].status;
    }

    function submitRFQ(bytes32 id, uint issuedAt, string memory ubl) public onlyBuyer  {
        // Make sure the RFQ is submitted only once
        require(rfqs[id].id == 0x0);

        rfqs[id].id = id;
        rfqs[id].issuedAt = issuedAt;
        rfqs[id].ubl = ubl;
        rfqs[id].status = RFQStatus.Received;

        nbrOfRFQs++;
        emit RFQReceived(id, issuedAt, ubl);
    }


    /* ------------- Quote logic ------------- */

    function getQuote(bytes32 id) public view returns (
        uint issuedAt,
        string memory ubl,
        QuoteStatus status,
        bytes32 rfqId,
        address supplier
    ) {
        // Make sure the quote exists
        require(quotes[id].id == id);

        issuedAt = quotes[id].issuedAt;
        ubl = quotes[id].ubl;
        status = quotes[id].status;
        rfqId = quotes[id].rfqId;
        supplier = quotes[id].supplier;
    }

    function submitQuote(bytes32 id, bytes32 rfqId, uint issuedAt, string memory ubl) public  {
        // Make sure the RFQ exists
        require(rfqs[rfqId].id == rfqId);

        // Make sure the quote is submitted only once
        require(quotes[id].id == 0x0);

        // Create the quote and store it
        address supplier = msg.sender;
        quotes[id] = Quote(id, issuedAt, ubl, QuoteStatus.Offer, rfqId, supplier);

        // Update the corresponding RFQ
        rfqs[rfqId].status = RFQStatus.QuoteProvided;

        nbrOfQuotes++;
        emit QuoteReceived(supplier, rfqId, id, issuedAt, ubl);
    }

    function declineRFQ(bytes32 id, bytes32 rfqId, uint issuedAt) public  {
        // Make sure the RFQ exists
        require(rfqs[rfqId].id == rfqId);

        // Make sure the quote is submitted only once
        require(quotes[id].id == 0x0);

        // Create the quote and store it
        address supplier = msg.sender;
        quotes[id] = Quote(id, issuedAt, "", QuoteStatus.Decline, rfqId, supplier);

        // Update the corresponding RFQ
        if (rfqs[rfqId].status == RFQStatus.Received) {
            rfqs[rfqId].status = RFQStatus.Declined;
        }

        nbrOfQuotes++;
        emit RFQDeclined(supplier, rfqId, id, issuedAt);
    }
}
