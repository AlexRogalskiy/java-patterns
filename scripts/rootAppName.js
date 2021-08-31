const packageJson = require('../package.json');

const moduleName = `${/[^/]*$/.exec(packageJson.name)[0]}_${packageJson.version.replace(/\./g, '_')}`;
const packageName = process.env.npm_package_name;

console.log(`>>> Module name: ${moduleName}`);
console.log(`>>> Package name: ${packageName}`)

module.exports = {
    moduleName,
    packageName
};
