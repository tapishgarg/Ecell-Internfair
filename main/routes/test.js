let request = require('request');

let headers = {'X-Api-Key': 'test_bc5d0ff7ab93913d48c141db000', 'X-Auth-Token': 'test_084bd7acbd7183f58bfe6c2e54e'};
let payload = {
    purpose: 'Intern Fair IITM',
    amount: '250',
    phone: '9999999999',
    buyer_name: 'John Doe',
    redirect_url: 'http://accomox.in/',
    send_email: true,
    send_sms: true,
    email: 'foo@example.com',
    allow_repeated_payments: false
};

request.post('https://www.instamojo.com/api/1.1/payment-requests/', {
    form: payload,
    headers: headers
}, function (error, response, body) {
    console.log(response);
    if (!error && response.statusCode == 201) {
        console.log(body);
    }
});