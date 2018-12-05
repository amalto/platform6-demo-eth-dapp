pragma solidity ^0.5.1;


contract RequestForQuotations {

    /* ------------- RFQ Model ------------- */

    enum RFQStatus {Received, Declined, QuoteProvided}

    struct RequestForQuotation {
        bytes32 id; // Useful for presence verification
        uint issuedAt;
        string ubl;
        RFQStatus status;
        uint[] quoteIds;
    }

    // A bytes32 field cannot be indexed in a event, this is why an index of type uint was introduced.
    // As an added benefit, it also allows to count the number of submitted RFQs.
    event RFQReceived(uint indexed index, bytes32 id);

    /* ------------- Quote Model ------------- */

    enum QuoteStatus {Offer, Decline}

    struct Quote {
        bytes32 id; // Useful for presence verification
        uint issuedAt;
        string ubl;
        QuoteStatus status;
        uint rfqIndex;
        address supplier;
    }

    // A bytes32 field cannot be indexed in a event, this is why an index of type uint was introduced.
    // As an added benefit, it also allows to count the number of submitted quotes.
    event QuoteReceived(uint indexed index, uint indexed rfqIndex, address indexed supplier, bytes32 id);

    /* ------------- RFQ State ------------- */

    RequestForQuotation[] rfqs;

    // Maps the id to the RFQ index
    mapping(bytes32 => uint) rfqIdToIndexMap;

    /* ------------- Quote State ------------- */

    Quote[] quotes;

    // Maps the id to the quote index
    mapping(bytes32 => uint) quoteIdToIndexMap;

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

    function nbrRFQs() public view returns (uint number) {
        return rfqs.length;
    }

    function getRFQUBL(bytes32 id) public view returns (string memory ubl) {
        uint index = rfqIdToIndexMap[id];
        if (rfqs.length > index && rfqs[index].id == id) {
            return rfqs[index].ubl;
        } else {
            return "";
        }
    }

    function submitRFQ(bytes32 id, uint issuedAt, string memory ubl) public onlyBuyer returns (uint index)  {
        index = rfqs.length++;
        rfqIdToIndexMap[id] = index;

        rfqs[index].id = id;
        rfqs[index].issuedAt = issuedAt;
        rfqs[index].ubl = ubl;
        rfqs[index].status = RFQStatus.Received;

        emit RFQReceived(index, id);
        return index;
    }

    /* ------------- Quote logic ------------- */

    function nbrQuotes() public view returns (uint number) {
        return quotes.length;
    }

    function getQuoteUBL(bytes32 id) public view returns (string memory ubl) {
        uint index = quoteIdToIndexMap[id];
        if (quotes.length > index && quotes[index].id == id) {
            return quotes[index].ubl;
        } else {
            return "";
        }
    }

    function submitQuote(bytes32 id, bytes32 rfqId, uint issuedAt, string memory ubl) public returns (uint index)  {
        // Make sure the RFQ exists
        uint rfqIndex = rfqIdToIndexMap[rfqId];
        require(rfqs.length > rfqIndex && rfqs[rfqIndex].id == rfqId);

        index = quotes.length;
        quoteIdToIndexMap[id] = index;
        address supplier = msg.sender;

        quotes.push(Quote(id, issuedAt, ubl, QuoteStatus.Offer, rfqIndex, supplier));

        emit QuoteReceived(index, rfqIndex, supplier, id);
        return index;
    }
}
