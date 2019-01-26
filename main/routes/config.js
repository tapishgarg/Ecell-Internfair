let graphql_host = process.env.GRAPHQL_ENGINE_DATABASE_HOST || "localhost";

let config = {
    google_clientId: "180078941323-o7658rcf79usd1tu4u4fu1guijgmjfo5.apps.googleusercontent.com",
    // client secret  vTZrUEF7duYtGpXRKudpbkWp
    cloudinary_api_id: {
        cloud_name: 'joeydash',
        api_key: '571664355428984',
        api_secret: 'Br8_bTtFahHJkytcibUAxvrsyjk'
    },
    graphql_engine: {
        graphql_host: graphql_host,
        graphql_port: "8080",
        graphql_url: "http://" + graphql_host + ":" + "8080" + "/v1alpha1/graphql"
    },
    sendGridKey: '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'
};

module.exports = config;