# Devproxy [![Build Status](https://travis-ci.org/boz/devproxy.png?branch=master)](https://travis-ci.org/boz/devproxy)

[devproxy.io](https://devproxy.io) client used for tunneling
connections from a public domain (`https://example.devproxy.io`) to your
local machine.

## Installation

Add this line to your application's Gemfile:

    gem 'devproxy'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install devproxy --source https://github.com/boz/devproxy.git

## Usage

Create an account on [devproxy.io](https://devproxy.io) and upload
your ssh public key.

To tunnel connections for `example.devproxy.io` to port 3000 on your local machine, run:

    $ devproxy example

You can specify the local port with `-p`:

    $ devproxy example -p 3000

If the host that you want to tunnel is not the same as your [devproxy.io](https://devproxy.io)
username, specify the hostname as the second argument:

    $ devproxy example test

### Rails

Start up your tunnel in a separate terminal or use a [foreman](https://github.com/ddollar/foreman) Procfile:

```
devproxy: bundle exec devproxy example -p 3000
web:      bundle exec rails s -p 3000
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
