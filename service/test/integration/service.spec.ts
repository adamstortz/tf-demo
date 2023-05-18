import * as supertest from "supertest";
import { expect } from "chai";
import * as process from "process";

const apiEndpoint = process.env.LB_HOST_NAME ? `http://${process.env.LB_HOST_NAME}` : "http://localhost:8080";
let request = supertest(apiEndpoint);

describe("GET /", function () {
  
  it("Return json body with message ", async function () {
    const response = await request.get("/api");

    expect(response.status).to.eql(200);
    expect(response.body.message).to.eql('Automate all the things!');
    expect(response.body.timestamp).to.be.a('number');
    expect(response.body.timestamp).to.be.within(1600000000000, 2000000000000);
  });
});
