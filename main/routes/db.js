const express = require('express');
const router = express.Router();
const joeygql = require('joeygql');

const cloudinary = require('cloudinary');
const request = require('request');

const config = require('./config');

joeygql.setHasuraGraphqlUrl(config.graphql_engine.graphql_url);
joeygql.setGoogleApiClientId(config.google_clientId);
joeygql.setHasuraAccessKey("dashingjoey");

cloudinary.config(config.cloudinary_api_id);

router.get('/', function (req, res, next) {
    joeygql.checkRole("user", JSON.parse(req.cookies.auth_details).auth_token).then(data => console.log(data)).catch(err => console.log(err));
    res.json({RESPONSE_CODE: 108200});
});

router.post('/upload/image', function (req, res, next) {
    joeygql.checkRole("user", JSON.parse(req.cookies.auth_details).auth_token).then(data => {
        cloudinary.v2.uploader.upload(req.body.file,
            {folder: "dashboard"},
            function (error, result) {
                if (!error) {
                    let reqBody = 'mutation {\n' +
                        '  insert_cloudinary_image(objects: [{image_url: "' + result.secure_url + '", user_h_id: "' + JSON.parse(req.cookies.auth_details).h_id + '"}]) {\n' +
                        '    affected_rows\n' +
                        '  }\n' +
                        '}\n';

                    joeygql.requestDBWithRole('user', JSON.parse(req.cookies.auth_details).auth_token, reqBody).then(data => {
                        res.json({
                            RESPONSE_CODE: 108200,
                            secure_url: result.secure_url
                        });
                    }).catch(err => {
                        console.log(err);
                        res.status(400);
                        res.json({RESPONSE_CODE: 108400});
                    });
                } else {
                    console.log(error);
                    res.status(400);
                    res.json({RESPONSE_CODE: 108400});
                }
            });
    }).catch(err => console.log(err));
});

router.post('/sign_in', function (req, res, next) {
    joeygql.signInGoogle(req.body.id_token).then(data => res.json(data)).catch(e => res.json(e));
});

router.post('/anonymous', function (req, res, next) {
    console.log(req.body.query_string);
    joeygql.requestDBAnonymous(req.body.query_string).then(data => res.json(data)).catch(e => res.json(e));
});

router.post('/:role', function (req, res, next) {
    console.log(req.params.role);
    console.log(JSON.parse(req.cookies.auth_details).auth_token);
    console.log(req.body.query_string);
    joeygql.requestDBWithRole(req.params.role, JSON.parse(req.cookies.auth_details).auth_token, req.body.query_string).then(data => res.json(data)).catch(e => res.json(e));
});

module.exports = router;
