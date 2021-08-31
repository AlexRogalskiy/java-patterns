const {exec} = require('child_process');

exec(`husky install `, (err, stdout, stderr) => {
    console.log(`stdout: ${stdout}`);
    console.log(`stderr: ${stderr}`);
});
