polar
=====

Boilerplate for a basic [Express](http://github.com/visionmedia/express) setup.

* Simple request logging
* Cookie and form parsing
* Jade templating
* Static file serving
* Static file preprocessing (with [Metaserve](http://github.com/prontotype-us/metaserve))

## Usage

Create an app instance just as you would with Express, passing options to `polar`. Start the app with `app.start()`.

```coffee
polar = require 'polar'

app = polar
    port: 8583

app.get '/', (req, res) ->
    res.render 'hi',
        date: new Date()

app.start()
```

### Options

* `port` **REQUIRED** &mdash; Port for your app to listen on
* `middleware` &mdash; Array of middleware functions
* `metaserve` &mdash; Metaserve options object, default uses [metaserve-css-styl](https://github.com/prontotype-us/metaserve-css-styl/) and [metaserve-js-coffee-reactify](https://github.com/prontotype-us/metaserve-js-coffee-reactify)
* `view_dir` &mdash; Directory to look for view templates in, default is `/views`
* `view_engine` &mdash; Templating engine, default is [Jade](https://github.com/jadejs/jade)
* `use_sessions` &mdash; Use connect-redis to store session data
* `session_secret` &mdash; Secret key for connect-redis sessions
* `no_cookie_parser` &mdash; Do not use `express.cookieParser`
* `no_body_parser` &mdash; Do not use `express.bodyParser`
