let graphql_host = process.env.GRAPHQL_ENGINE_DATABASE_HOST || "localhost";

let config = {
    google_clientId: "869757478663-gnlmvb29d5mduo26mrq595svsojrgsus.apps.googleusercontent.com",
    // google client secret    qu1RMMJw4PAxItNoEGO6yDoQ
    cloudinary_api_id: {
        cloud_name: 'si-portal',
        api_key: '672939885848231',
        api_secret: 'f8CCK49ct9pivHJJ1d_lbq0GVDw'
    },
    graphql_engine: {
        graphql_host: graphql_host,
        graphql_port: "8080",
        graphql_url: "http://" + graphql_host + ":" + "8080" + "/v1alpha1/graphql"
    },
    sendGridKey: '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'
};

module.exports = config;