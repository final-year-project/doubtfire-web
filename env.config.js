module.exports = {
  env: {
    options: {
      // Global Options
      VERSION: require('./package.json').version,
    },

    development: {
      API_URL: 'http://' + require('ip').address() + ':3000/api',
      ENV_NAME: 'development'
    },

    production: {
      API_URL: 'https://doubtfire.ict.swin.edu.au/api',
      ENV_NAME: 'production'
    },

    docker: {
      API_URL: 'http://' + process.env.DOUBTFIRE_DOCKER_MACHINE_IP + ':3000/api',
      ENV_NAME: 'docker'
    },

    demo: {
      API_URL: '/api',
      ENV_NAME: 'demo'
    }
  }
}
