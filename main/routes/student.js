let express = require('express');
let router = express.Router();


router.get('/profile', function (req, res, next) {
    res.render('student/profile/index');
});

router.get('/internship/list', function (req, res, next) {
    res.render('student/internship/list/index');
});

router.get('/internship/detail/:id', function (req, res, next) {
    res.render('student/internship/detail/index', {internship_id: req.params.id});
});


module.exports = router;