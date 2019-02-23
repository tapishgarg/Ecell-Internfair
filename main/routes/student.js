let express = require('express');
let router = express.Router();


router.get('/profile', function (req, res, next) {
    res.render('student/profile/index');
});

router.get('/internship/list', function (req, res, next) {
    res.render('student/internship/index');
});


module.exports = router;