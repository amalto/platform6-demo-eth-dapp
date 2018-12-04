const SimpleStorage = embark.require('Embark/contracts/SimpleStorage');


let accounts;

config({
    contracts: {
        "SimpleStorage": {
            args: [100]
            //, onDeploy: ["SimpleStorage.methods.setRegistar(web3.eth.defaultAccount).send()"] // example
        }
    }
}, (err, theAccounts) => {
    accounts = theAccounts;
});


contract("SimpleStorage", function () {

    it("should set constructor value", async function () {
        let result = await SimpleStorage.methods.storedData().call();
        assert.strictEqual(parseInt(result, 10), 100);
    });

    it("set storage value", async function () {
        const newValue = 150;
        await SimpleStorage.methods.set(newValue).send();
        let result = await SimpleStorage.methods.get().call();
        assert.strictEqual(parseInt(result, 10), newValue);
    });
});
