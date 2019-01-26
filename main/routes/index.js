let express = require('express');
let router = express.Router();
const exec = require("child_process").exec

/* GET home page. */
router.get('/', function(req, res, next) {
  res.render('index', { title: 'Express' });
});

router.get('/tapish', function(req, res, next) {
  let data = {
    "name" : "tapishg",
    "age" : "19"
  };
  res.render('tapish', data);
});


router.get('/reload_app', function(req, res, next) {

  exec("ls", (error, stdout, stderr) => {
    console.log(`stdout: ${stdout}`);
    console.log(`stderr: ${stderr}`);
  });
  res.render('index', { title: 'Express' });
});

module.exports = router;
