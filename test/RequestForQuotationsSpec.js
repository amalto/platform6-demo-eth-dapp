const uuidv4 = require('uuid/v4');
const uuidToHex = require('uuid-to-hex');
const RequestForQuotations = embark.require('Embark/contracts/RequestForQuotations');

const revertErrorMessage = "VM Exception while processing transaction: revert";

const RFQStatus = {Received: '0', Declined: '1', QuoteProvided: '2'};
const QuoteStatus = {Offer: '0', Decline: '1'};
const rfqId = uuidToHex(uuidv4(), true);

let accounts;

config({
    contracts: {
        "RequestForQuotations": {
            // args: [100]
        }
    }
}, (err, theAccounts) => {
    accounts = theAccounts;
});


// FIXME add web3js call to fetch events and make sure they are generated correctly
// TODO add how to listen to events in Embark doc and how to test a reverted transaction
contract("RequestForQuotations", function () {

    it("Submit a new RFQ", async function () {
        await checkNumberOfRFQsIs(0);

        const issuedAt = new Date().getTime();
        const ubl = '<RequestForQuotation xmlns=... </RequestForQuotation>';

        await RequestForQuotations.methods.submitRFQ(rfqId, issuedAt, ubl).send();

        await checkNumberOfRFQsIs(1);

        let result = await RequestForQuotations.methods.getRFQ(rfqId).call();
        assert.strictEqual(parseInt(result.issuedAt, 10), issuedAt);
        assert.strictEqual(result.ubl, ubl);
        assert.strictEqual(result.status, RFQStatus.Received);

        // Add another RFQ
        const id2 = uuidToHex(uuidv4(), true);
        const issuedAt2 = new Date().getTime();
        const ubl2 = '<RequestForQuotation xmlns=lol... </RequestForQuotation>';

        await RequestForQuotations.methods.submitRFQ(id2, issuedAt2, ubl2).send();

        await checkNumberOfRFQsIs(2);

        const result2 = await RequestForQuotations.methods.getRFQ(id2).call();
        assert.strictEqual(parseInt(result2.issuedAt, 10), issuedAt2);
        assert.strictEqual(result2.ubl, ubl2);
        assert.strictEqual(result.status, RFQStatus.Received);

        // It should not be possible to submit the same RFQ twice and accidentally modify an existing one
        await assertTransactionReverted(function () {
            return RequestForQuotations.methods.submitRFQ(rfqId, issuedAt, ubl2).send();
        });

        await checkNumberOfRFQsIs(2);

        result = await RequestForQuotations.methods.getRFQ(rfqId).call();
        assert.strictEqual(result.ubl, ubl);
    });

    it("Revert when trying to fetch a non-existent RFQ", async function () {
        await checkNumberOfRFQsIs(2);

        const id = uuidToHex(uuidv4(), true);

        await assertTransactionReverted(function () {
            return RequestForQuotations.methods.getRFQ(id).call();
        });
    });

    it("Decline a RFQ", async function () {
        await checkNumberOfQuotesIs(0);
        await checkStatusOfRFQIs(rfqId, RFQStatus.Received);

        const declineId = uuidToHex(uuidv4(), true);
        const issuedAt = new Date().getTime();
        await RequestForQuotations.methods.declineRFQ(declineId, rfqId, issuedAt).send();

        await checkNumberOfQuotesIs(1);
        await checkStatusOfRFQIs(rfqId, RFQStatus.Declined);

        const result = await RequestForQuotations.methods.getQuote(declineId).call();
        assert.strictEqual(parseInt(result.issuedAt, 10), issuedAt);
        assert.strictEqual(result.ubl, "");
        assert.strictEqual(result.status, QuoteStatus.Decline);
        assert.strictEqual(result.rfqId, rfqId);

        // Revert when trying to decline twice with the same id
        await assertTransactionReverted(function () {
            return RequestForQuotations.methods.declineRFQ(declineId, rfqId, issuedAt).send();
        });
        await checkNumberOfQuotesIs(1);
    });

    it("Submit a quote for an existing RFQ", async function () {
        await checkNumberOfQuotesIs(1);
        await checkStatusOfRFQIs(rfqId, RFQStatus.Declined);

        const offerId = uuidToHex(uuidv4(), true);
        const issuedAt = new Date().getTime();
        const quoteUBL = "quote UBL";

        // Make sure to revert when submitting a quote for a non existent RFQ
        const nonExistentRFQId = uuidToHex(uuidv4(), true);
        await assertTransactionReverted(function () {
            return RequestForQuotations.methods.submitQuote(offerId, nonExistentRFQId, issuedAt, quoteUBL).send();
        });
        await checkNumberOfQuotesIs(1);

        // Test submitting a quote for an existent RFQ
        await RequestForQuotations.methods.submitQuote(offerId, rfqId, issuedAt, quoteUBL).send();

        await checkNumberOfQuotesIs(2);
        await checkStatusOfRFQIs(rfqId, RFQStatus.QuoteProvided);

        const result = await RequestForQuotations.methods.getQuote(offerId).call();
        assert.strictEqual(parseInt(result.issuedAt, 10), issuedAt);
        assert.strictEqual(result.ubl, quoteUBL);
        assert.strictEqual(result.status, QuoteStatus.Offer);
        assert.strictEqual(result.rfqId, rfqId);

        // Revert when trying to submit twice with the same id
        await assertTransactionReverted(function () {
            return RequestForQuotations.methods.submitQuote(offerId, rfqId, issuedAt, quoteUBL).send();
        });
        await checkNumberOfQuotesIs(2);

        // Declining now should no longer affect the state of the RFQ
        const declineId = uuidToHex(uuidv4(), true);
        await RequestForQuotations.methods.declineRFQ(declineId, rfqId, issuedAt).send();

        await checkNumberOfQuotesIs(3);
        await checkStatusOfRFQIs(rfqId, RFQStatus.QuoteProvided);
    });

    it("Revert when trying to fetch a non-existent quote", async function () {
        await checkNumberOfQuotesIs(3);

        const id = uuidToHex(uuidv4(), true);

        await assertTransactionReverted(function () {
            return RequestForQuotations.methods.getQuote(id).call();
        });
    });
});

async function checkNumberOfRFQsIs(expectedNumber) {
    let resultNbrOfRFQs = await RequestForQuotations.methods.nbrOfRFQs().call();
    assert.strictEqual(parseInt(resultNbrOfRFQs, 10), expectedNumber);
}

async function checkNumberOfQuotesIs(expectedNumber) {
    let resultNbrOfQuotes = await RequestForQuotations.methods.nbrOfQuotes().call();
    assert.strictEqual(parseInt(resultNbrOfQuotes, 10), expectedNumber);
}

async function checkStatusOfRFQIs(rfqId, expectedStatus) {
    let result = await RequestForQuotations.methods.getRFQ(rfqId).call();
    assert.strictEqual(result.status, expectedStatus);
}

async function assertTransactionReverted(action) {
    try {
        await action();
    } catch (err) {
        assert.strictEqual(err.message, revertErrorMessage);
    }
}
