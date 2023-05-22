import { expect } from "chai";
const service = require("../../src");

describe("Service unit tests", () => {
  it("Should have expected payload", () => {
    const result = service.getResponseBody();
    console.log(result)
    expect(result.message).to.eql('Automate all the things!');
    expect(result.timestamp).to.be.a('number');
    expect(result.timestamp).to.be.within(1600000000000, 2000000000000);
  });
});
