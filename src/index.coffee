express = require 'express'
metaserve = require 'metaserve'

merge_objs = (objs) ->
    o = {}
    for obj in objs
        for k, v of obj
            o[k] = v
    o

setup = (configs...) ->
    config = merge_objs configs

    # Initialize express
    app = config.app || express()
    if config.app
        app = config.app
        delete config.app
    app.config = config

    # Use view directory and engine defined in config
    # Default directory is ./views with Jade templates
    app.set 'views', config.view_dir || './views'
    app.set 'view engine', config.view_engine || 'jade'

    # Logging middleware
    # TODO: Apache log format
    app.use (req, res, next) ->
        console.log "[#{new Date().toISOString()}] #{ req.method } #{ req.url }"
        next()

    # Use express's cookie and form parsers
    app.use express.cookieParser() unless config.no_cookie_parser
    app.use express.bodyParser() unless config.no_body_parser

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

    # Use metaserve for static files
    app.use metaserve config.metaserve || config.static_dir ||
        compilers:
            css: [
                require('metaserve-bouncer')(ext: 'bounced.css') if !config.debug
                require('metaserve-css-styl')()
            ]
            js: [
                require('metaserve-bouncer')(ext: 'bounced.js') if !config.debug
                require('metaserve-js-coffee-reactify')(ext: 'coffee', uglify: !config.debug)
            ]

    app.use config.fallback || (req, res, next) ->
        res.send 404, "Could not find page."

    # Start the app and listen on config.port
    app.start = ->
        app.listen config.port, ->
            console.log "Listening on :#{ config.port }"

    return app

# Export
module.exports = setup

