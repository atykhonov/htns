const axios = require("axios");

exports.handler = async function(event) {

  let postData = {
    "events": [{
      "email": "atykhonov+test1@gmail.com",
      "action": "Logged in",
      "properties": {
        "affiliate_code": "XYZ"
      },
      "occurred_at": "2021-02-18T03:41:00Z"
    }]
  };

  const headers = {
    auth: {
      username: process.env.DRIP_API_TOKEN,
      password: "",
    },
    "Content-Type": "Content-Type: application/json",
  };

  try {
    const baseUrl = "https://api.getdrip.com";
    const path = "/v2/" + process.env.DRIP_ACCOUNT_ID + "/events";
    await axios.post(baseUrl + path, postData, headers);
  } catch (error) {
    console.log(error);
  };

  return {
    statusCode: 200,
    body: JSON.stringify({}),
  };
}
