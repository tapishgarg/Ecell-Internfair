let express = require('express');
let router = express.Router();


router.get('/profile', function (req, res, next) {
    res.render('student/profile/index');
});


module.exports = router;