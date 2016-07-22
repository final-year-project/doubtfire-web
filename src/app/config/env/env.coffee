angular.module("doubtfire.config.env", [])
#
# The environment running doubtfire
# It is set in env.config.js
#
.constant("dfEnv",     '/* @echo ENV_NAME */')
.constant("dfVersion", '/* @echo VERSION */')
.constant("dfApiUrl",  '/* @echo API_URL */')
