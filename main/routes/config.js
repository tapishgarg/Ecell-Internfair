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
    sendGridKey: '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',
    instamojo_keys: {
        test: {
            api_key: "test_bc5d0ff7ab93913d48c141db000",
            auth_key: "test_084bd7acbd7183f58bfe6c2e54e",
            salt_key: "7e92c8ff2f2f45cd884143f5b1984cca"
        },
        prod: {
            api_key: "74223f7bfeb2f7a1e59cb20a0d214ae6",
            auth_key: "264b9c30c8fd7c6131726c757a8822a5",
            salt_key: "bda67ebd30e6429fa0a35fe11f6cec92"
        }
    }
};

module.exports = config;