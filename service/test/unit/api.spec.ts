import { assert } from "chai";

const service = require("../../service");
//  TODO implement a real test
describe("Calculator Tests", () => {
  it("should return 5 when 2 is added to 3", () => {
    const result = service.getResponseBody();
    assert.equal(result, 5);
  });
});
