let express = require('express');
let router = express.Router();

/* GET home page. */
router.get('/', function (req, res, next) {
    res.render('home/index', {title: 'Express'});
});

router.get('/about', function (req, res, next) {
    res.render('home/about');
});

router.get('/policy', function (req, res, next) {
    res.render('home/policy');
});

router.get('/whyintern', function (req, res, next) {
    res.render('home/whyintern');
});

router.get('/employer_manage', function (req, res, next) {
    res.render('home/employer_manage');
});

router.get('/employer_resume', function (req, res, next) {
    res.render('home/employer_resume');
});

router.get('/employer_post', function (req, res, next) {
    res.render('home/employer_post');
});

router.get('/job_list', function (req, res, next) {
    res.render('home/job_list');
});

router.get('/job_single', function (req, res, next) {
    res.render('home/job_single');
});

router.get('/single/tapish', function (req, res, next) {
    let data = {
        "name": "tapishg",
        "age": "19"
    };
    res.render('tapish', data);
});


module.exports = router;
