let express = require('express');
let router = express.Router();


router.get('/manage', function (req, res, next) {
    res.render('startup/manage/index');
});

router.get('/post_internship', function (req, res, next) {
    res.render('startup/post_internship/index');
});

router.get('/edit_internship/:id', function (req, res, next) {
    res.render('startup/edit_internship/index', {internship_id: req.params.id});
});

router.get('/internship_detail/:id', function (req, res, next) {
    res.render('startup/internship_detail/index', {internship_id: req.params.id});
});

router.get('/internship_applied/:id', function (req, res, next) {
    res.render('startup/internship_applied/index', {internship_id: req.params.id});
});

module.exports = router;