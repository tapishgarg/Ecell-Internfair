const express = require('express');
const router = express.Router();

const request = require('request');
const joeygql = require('joeygql');


const config = require('./config');

joeygql.setHasuraGraphqlUrl(config.graphql_engine.graphql_url);
joeygql.setHasuraAccessKey("joeydash");


router.post('/get_payment_link', function (req, res, next) {
    let headers = {
        'X-Api-Key': config.instamojo_keys.prod.api_key,
        'X-Auth-Token': config.instamojo_keys.prod.auth_key
    };
    let payload = {
        purpose: 'Intern Fair IITM',
        amount: '250',
        phone: req.body.phone,
        buyer_name: req.body.buyer_name,
        send_email: false,
        send_sms: false,
        email: req.body.email,
        allow_repeated_payments: false
    };

    request.post('https://www.instamojo.com/api/1.1/payment-requests/', {
        form: payload,
        headers: headers
    }, function (error, response, body) {
        if (!error && response.statusCode == 201) {
            res.json(body);
        }else {
            res.json(body);
            console.log(body);
        }
    });
});


module.exports = router;
