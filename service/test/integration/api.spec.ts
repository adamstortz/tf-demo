import * as supertest from "supertest";
import { expect } from "chai";
import * as process from "process";

const apiEndpoint = process.env.API_ENDPOINT || "http://localhost:8000";
let request: supertest.SuperTest<supertest.Test>;

describe("GET /", function () {
  beforeEach(() => {
    request = supertest(apiEndpoint);
    // require('dotenv').config()
  });
  it("returns all airports, limited to 30 per page", async function () {
    const response = await request.get("/");

    expect(response.status).to.eql(200);
  });
});
