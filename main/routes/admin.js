let express = require('express');
let router = express.Router();


router.get('/shortlisted_list', function (req, res, next) {
    res.render('single/shortlisted');
});


router.get('/pending_list', function (req, res, next) {
    res.render('single/pending');
});

router.get('/rejected_list', function (req, res, next) {
    res.render('single/rejected');
});

module.exports = router;