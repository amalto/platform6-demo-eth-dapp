const uuidv4 = require('uuid/v4');
const uuidToHex = require('uuid-to-hex');
const RequestForQuotations = embark.require('Embark/contracts/RequestForQuotations');

const revertErrorMessage = "VM Exception while processing transaction: revert";

const RFQStatus = {Received: '0', Declined: '1', QuoteProvided: '2'};
const QuoteStatus = {Offer: '0', Decline: '1'};

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
contract("RequestForQuotations", function () {

    it("Submit a new RFQ", async function () {
        let resultNbrOfRFQs = await RequestForQuotations.methods.nbrOfRFQs().call();
        assert.strictEqual(parseInt(resultNbrOfRFQs, 10), 0);

        const id = uuidToHex(uuidv4(), true);
        const issuedAt = new Date().getTime();
        const ubl = '<RequestForQuotation xmlns=... </RequestForQuotation>';

        await RequestForQuotations.methods.submitRFQ(id, issuedAt, ubl).send();

        resultNbrOfRFQs = await RequestForQuotations.methods.nbrOfRFQs().call();
        assert.strictEqual(parseInt(resultNbrOfRFQs, 10), 1);

        let result = await RequestForQuotations.methods.getRFQ(id).call();
        assert.strictEqual(parseInt(result.issuedAt, 10), issuedAt);
        assert.strictEqual(result.ubl, ubl);
        assert.strictEqual(result.status, RFQStatus.Received);

        // Add another RFQ
        const id2 = uuidToHex(uuidv4(), true);
        const issuedAt2 = new Date().getTime();
        const ubl2 = '<RequestForQuotation xmlns=lol... </RequestForQuotation>';

        await RequestForQuotations.methods.submitRFQ(id2, issuedAt2, ubl2).send();

        resultNbrOfRFQs = await RequestForQuotations.methods.nbrOfRFQs().call();
        assert.strictEqual(parseInt(resultNbrOfRFQs, 10), 2);

        const result2 = await RequestForQuotations.methods.getRFQ(id2).call();
        assert.strictEqual(parseInt(result2.issuedAt, 10), issuedAt2);
        assert.strictEqual(result2.ubl, ubl2);
        assert.strictEqual(result.status, RFQStatus.Received);

        // It should not be possible to submit the same RFQ twice and accidentally modify an existing one
        try {
            await RequestForQuotations.methods.submitRFQ(id, issuedAt, ubl2).send();
        } catch (err) {
            assert.strictEqual(err.message, revertErrorMessage);
        }

        resultNbrOfRFQs = await RequestForQuotations.methods.nbrOfRFQs().call();
        assert.strictEqual(parseInt(resultNbrOfRFQs, 10), 2);

        result = await RequestForQuotations.methods.getRFQ(id).call();
        assert.strictEqual(result.ubl, ubl);
    });

    it("Revert when trying to fetch a non-existent RFQ", async function () {
        let resultNbrOfRFQs = await RequestForQuotations.methods.nbrOfRFQs().call();
        assert.strictEqual(parseInt(resultNbrOfRFQs, 10), 2);

        const id = uuidToHex(uuidv4(), true);
        // FIXME factor this code
        try {
            await RequestForQuotations.methods.getRFQ(id).call();
        } catch (err) {
            assert.strictEqual(err.message, revertErrorMessage);
        }
    });
});
