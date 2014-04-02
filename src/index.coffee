express = require 'express'
metaserve = require 'metaserve'

setup_app = (config) ->

    # Initialize express
    app = config.app || express()
    if config.app
        app = config.app

    # Use view directory and engine defined in config
    # Default directory is ./views with Jade templates
    app.set 'views', config.view_dir || './views'
    app.set 'view engine', config.view_engine || 'jade'

    # Logging middleware
    app.use (req, res, next) ->
        console.log "[#{ req.method }] #{ req.url }"
        next()

    # Use express's cookie and form parsers
    app.use express.cookieParser()
    app.use express.bodyParser()

    # Use sessions if desired
    if config.use_sessions?
        RedisStore = require('connect-redis')(express)
        app.use express.session
            store: new RedisStore
                host: config.redis?.host || 'localhost'
            secret: config.session_secret

    # Hook in user provided middleware
    if config.middleware?
        for middleware in config.middleware
            app.use middleware

    # Use routes defined by app.get etc.
    app.use app.router

    # Fall back to metaserve for static files
    app.use metaserve(config.static_dir || './static')

    app.start = ->
        app.listen config.port, ->
            console.log "Listening on :#{ config.port }"

    return app

# Export
module.exports =
    setup_app: setup_app

