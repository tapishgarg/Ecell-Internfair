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

    res.render('startup/employer_manage/index');
});

router.get('/employer_resume', function (req, res, next) {
    res.render('home/employer_resume');
});

router.get('/employer_post', function (req, res, next) {
    res.render('startup/employer_post/index');
});

router.get('/job_list', function (req, res, next) {
    res.render('home/job_list');
});

router.get('/job_single', function (req, res, next) {
    res.render('home/job_single');
});

router.get('/candidates_applied_jobs', function (req, res, next) {
    res.render('home/candidates_applied_jobs');
});

router.get('/candidates_bookmarks', function (req, res, next) {
    res.render('home/candidates_bookmarks');
});

router.get('/candidates_profile', function (req, res, next) {
    res.render('home/candidates_profile');
});

router.get('/candidates_shortlist', function (req, res, next) {
    res.render('home/candidates_shortlist');
});

router.get('/schedule', function (req, res, next) {
    res.render('home/schedule');
});

router.get('/single/tapish', function (req, res, next) {
    let data = {
        "name": "tapishg",
        "age": "19"
    };
    res.render('tapish', data);
});


module.exports = router;
