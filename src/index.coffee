express = require 'express'
express_busboy = require 'express-busboy'
express_session = require 'express-session'
# cookieParser = require 'polar-cookieParser'
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
    # Default directory is same as static dir
    app.set 'views', config.view_dir or config.static_dir or '.'
    app.set 'view engine', config.view_engine or 'pug'

    # Logging middleware
    # TODO: Apache log format
    app.use config.logger or (req, res, next) ->
        console.log "[#{new Date().toISOString()}] #{req.method} #{req.url}"
        next()

    # Use express's cookie and form parsers
    app.use express.json(config.json)
    # app.use cookieParser(null, config.session?.cookie) unless config.no_cookie_parser

    # Use express-busboy for file uploads
    express_busboy.extend app, Object.assign (config.busboy or {}), {
        upload: true
    }

    # Use sessions if desired
    if config.session?
        RedisStore = require('connect-redis')(express_session)
        app.use express_session utils.merge_objs
            key: "sid:" + (config.session.cookie?.domain or "*"),
            store: new RedisStore
                host: config.redis?.host or 'localhost'
            cookie: maxAge: 1000 * 60 * 60 * 24 * 30 * 3 # 3 months
        , config.session

    # Hook in user provided middleware
    if config.middleware?
        for middleware in config.middleware
            app.use middleware

    # Use metaserve to compile static files
    app.useMetaserve = ->
        metaserve = require 'metaserve'
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

    # Start the app and listen on config.port
    app.start = ->
        app.listen config.port, ->
            console.info "Listening on :#{config.port}"

    return app

# Export
module.exports = setup

