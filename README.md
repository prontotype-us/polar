polar
=====

Boilerplate for a basic [Express](http://github.com/visionmedia/express) setup.

* Simple request logging
* Cookie and form parsing
* Jade templating
* Static file serving
* Static file preprocessing (with [Metaserve](http://github.com/prontotype-us/metaserve))

## Usage

```coffee
polar = require 'polar'

app = polar.setup_app
    port: 8583

app.get '/', (req, res) ->
    res.render 'hi',
        date: new Date()

app.start()
```

