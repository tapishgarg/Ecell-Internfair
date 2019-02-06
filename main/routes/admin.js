let express = require('express');
let router = express.Router();


router.get('/startups', function (req, res, next) {
    res.render('admin/startups/index');
});



module.exports = router;