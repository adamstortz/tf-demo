import { expect } from "chai";
const service = require("../../src");

describe("Service unit tests", () => {
  it("Should have message 'Automate all the things!'", () => {
    const result = service.getResponseBody();

    expect(result.message).to.eql('Automate all the things!');
    expect(result.timestamp).to.be.a('number');
    expect(result.timestamp).to.be.within(1529729126, 1700000000);
  });
});
