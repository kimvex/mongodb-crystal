# mongodb-crystal

This repository is a fork of [datanoise/mongo.cr](https://github.com/datanoise/mongo.cr) to keep the Mongo db connection library up-to-date

This library provides binding for MongoDB C Driver. The goal is to provide a driver to access MongoDB.

# Status

_Beta_

# Requirements

- Crystal language version 0.20 and higher.
- libmongoc version 1.1.0
- libbson verion 1.1.0

On Mac OSX use `homebrew` to install the required libraries:

```
$ brew install mongo-c
```

On Linux you need to install `libmongoc-1.1-0` and `libbson-1.1-0` from your package manager or from source:

[http://mongoc.org/libmongoc/current/installing.html](http://mongoc.org/libmongoc/current/installing.html)

On Linux/Ubuntu

```
  sudo apt install libmongoc-dev libmongoc-1.0-0 libmongoclient-dev
```

## Installation

Add this to your application's `shard.yml`:

```yaml
mongo:
  github: kimvex/mongodb-crystal
  branch: master
```

# Usage

```crystal
require "mongo"

client = Mongo::Client.new "mongodb://<user>:<password>@<host>:<port>/<db_name>"
db = client["db_name"]

collection = db["collection_name"]
collection.insert({ "name" => "James Bond", "age" => 37 })

collection.find({ "age" => { "$gt" => 30 } }) do |doc|
  puts typeof(doc)    # => BSON
  puts doc
end
```

# License

MIT clause - see LICENSE for more details.
