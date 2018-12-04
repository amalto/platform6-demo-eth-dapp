pragma solidity ^0.5.1;


contract RequestForQuotations {

  /* ------------- RFQ Model ------------- */

  enum RFQStatus { Received, Declined, QuoteProvided }

  struct RequestForQuotation {
    string id;
    uint issuedAt;
    string ubl;
    RFQStatus status;
    uint[] quoteIds;
  }

  // A string field cannot be indexed in a event, this is why a confirmationId of type uint was introduced.
  // As an added benefit, it also allows to count the number of submitted RFQs.
  event RFQReceived(uint indexed index, string id);

  /* ------------- Quote Model ------------- */

  enum QuoteStatus { Offer, Decline }

  struct Quote {
    string id;
    uint issuedAt;
    string ubl;
    QuoteStatus status;
    uint rfqIndex;
    address supplier; // TODO add to event index
  }

  event QuoteReceived(uint indexed index, string id);

  /* ------------- RFQ State ------------- */

  RequestForQuotation[] rfqs;

  // Maps the id to the RFQ index
  mapping(string => uint) rfqIdToIndexMap;

  /* ------------- Quote State ------------- */

  Quote[] quotes;

  // Maps the id to the quote index
  mapping(string => uint) quoteIdToIndexMap;

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

  function getRFQIndex(string memory id) public view returns (uint rfqId) {
    return rfqIdToIndexMap[id];
  }

  function getRFQUBL(string memory id) public view returns (string memory ubl) {
    uint index = rfqIdToIndexMap[id];
    if (rfqs.length <= index) {
      return "";
    } else {
      return rfqs[index].ubl;
    }
  }

  function submitRFQ(string memory id, uint issuedAt, string memory ubl) public onlyBuyer returns (uint index)  {
    index = rfqs.length++;
    rfqIdToIndexMap[id] = index;

    rfqs[index].id = id;
    rfqs[index].issuedAt = issuedAt;
    rfqs[index].ubl = ubl;
    rfqs[index].status = RFQStatus.Received;

    emit RFQReceived(index, id);
    return index;
  }
}
