const execSync = require('child_process').execSync
const pkg = require('../package.json')

if (!pkg.envDependencies) {
  return process.exit(0)
}

let env = Object.assign({}, process.env)

if (typeof pkg.envDependencies.localJSON === 'string') {
  try {
    Object.assign(env, require(pkg.envDependencies.localJSON))
  } catch (err) {
    console.log(`Could not read or parse pkg.envDependencies.localJSON. Processing with env only.`)
  }
}

if (typeof pkg.envDependencies.urls === 'undefined') {
  console.log(`pkg.envDependencies.urls not found or empty. Passing.`)
  process.exit(0)
}

if (
  !Array.isArray(pkg.envDependencies.urls) ||
  !(pkg.envDependencies.urls.every(url => typeof url === 'string'))
) {
  throw new Error(`pkg.envDependencies.urls should have a signature of String[]`)
}

const parsed = pkg.envDependencies.urls
  .map(url => url.replace(/\${([0-9a-zA-Z_]*)}/g, (_, varName) => {
    if (typeof env[varName] === 'string') {
      return env[varName]
    } else {
      throw new Error(`Could not read env variable ${varName} in url ${url}`)
    }
  }))
  .join(' ')

try {
  execSync('npm install --no-save ' + parsed, {stdio: [0, 1, 2]})
  process.exit(0)
} catch (err) {
  throw new Error('Could not install pkg.envDependencies. Are you sure the remote URLs all have a package.json?')
}
