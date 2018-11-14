express = require 'express'
express_busboy = require 'express-busboy'
metaserve = require 'metaserve'
cookieParser = require 'polar-cookieParser'
utils = require './utils'

setup = (configs...) ->
    config = utils.merge_all configs

    # Initialize express
    app = config.app or express()
    if config.app
        app = config.app
        delete config.app
    app.config = config

    # Use view directory and engine defined in config
    # Default directory is ./views with Jade templates
    app.set 'views', config.view_dir or './views'
    app.set 'view engine', config.view_engine or 'pug'

    # Logging middleware
    # TODO: Apache log format
    app.use config.logger or (req, res, next) ->
        console.log "[#{new Date().toISOString()}] #{req.method} #{req.url}"
        next()

    # Use express's cookie and form parsers
    app.use express.json(config.json)
    app.use cookieParser(null, config.session?.cookie) unless config.no_cookie_parser

    # Use express-busboy for file uploads
    express_busboy.extend app, Object.assign (config.busboy or {}), {
        upload: true
    }

    # Use sessions if desired
    if config.session?
        RedisStore = require('connect-redis')(express)
        app.use express.session utils.merge_objs
            key: "sid:" + (config.session.cookie?.domain or "*"),
            store: new RedisStore
                host: config.redis?.host or 'localhost'
            cookie: maxAge: 1000 * 60 * 60 * 24 * 30 * 3 # 3 months
        , config.session

    # Hook in user provided middleware
    if config.middleware?
        for middleware in config.middleware
            app.use middleware

    # Use metaserve for static files
    app.use metaserve config.metaserve?.config or config.static_dir, config.metaserve?.compilers or {
        css: [
            require('metaserve-bouncer') if !config.debug
            require('metaserve-css-postcss')
        ]
        js: [
            require('metaserve-bouncer') if !config.debug
            require('metaserve-js-coffee-reactify')
        ]
    }

    config.using?.map (using) -> app.use using

    app.use config.fallback or (req, res, next) ->
        res.status(404).send "Could not find page."

    # Start the app and listen on config.port
    app.start = ->
        app.listen config.port, ->
            console.info "Listening on :#{config.port}"

    return app

# Export
module.exports = setup

