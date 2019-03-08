var config = {
    env: process.env.NODE_ENV || 'development'
}

console.log("env: " + config.env)

var envConfig = require(`./${config.env}`)
module.exports = Object.assign(config, envConfig || {})