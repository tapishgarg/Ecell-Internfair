let graphql_host = process.env.GRAPHQL_ENGINE_DATABASE_HOST || "localhost";

let config = {
    google_clientId: "869757478663-gnlmvb29d5mduo26mrq595svsojrgsus.apps.googleusercontent.com",
    // client secret    qu1RMMJw4PAxItNoEGO6yDoQ
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