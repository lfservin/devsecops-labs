var exec = require('child_process').exec;
exec('node -v', function(error, stdout, stderr) {
   console.log('stdout: ' + stdout);
});