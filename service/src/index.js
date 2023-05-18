const http = require("http");

const PORT = process.env.PORT || 8080;
const server = http.createServer(async (req, res) => {
  if (req.url === "/api" && req.method === "GET") {
    console.log("Received API call");
    res.writeHead(200, { "Content-Type": "application/json" });
    res.end(JSON.stringify(getResponseBody()));
  } else {
    res.writeHead(404, { "Content-Type": "application/json" });
    res.end(JSON.stringify({ message: "Route not found" }));
  }
});

const getResponseBody = () => {
  return {
    message: "Automate all the things!",
    timestamp: 1529729125,
  };
};

module.exports = {
  getResponseBody,
};

if (require.main === module) {
  server.listen(PORT, () => {
    console.log(`server started on port: ${PORT}`);
  });
}
