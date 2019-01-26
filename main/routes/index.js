let express = require('express');
let router = express.Router();

/* GET home page. */
router.get('/', function (req, res, next) {
    res.render('home/index', {title: 'Express'});
});

router.get('/single/tapish', function (req, res, next) {
    let data = {
        "name": "tapishg",
        "age": "19"
    };
    res.render('tapish', data);
});


module.exports = router;
