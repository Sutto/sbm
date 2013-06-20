# SBM - Simple Batch Manager

Manages running / coordinating batch processes running across multiple hosts.

Uses redis as a simple coordinator to ensure split work runs across hosts evenly.

## Installation

Add this line to your application's Gemfile:

    gem 'sbm'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sbm

## Usage

SBM is composed of a set of simple scripts useful for running in shells. The only required
variable is `NODE_NAME` as an environment variable - the name of the node the current job is
running on.

```bash
#!/usr/bin/env bash -e

export NODE_NAME="$(hostname)"

# Used if you have a bunch of different batches with the same name:
# export COORDINATOR_NAME='your-groups'

sbm-start-work my-test-batch
rake do:your:Work
sbm-complete-work my-test-batch && sbm-wait-for my-test-batch 20 # There are 20 nodes running this process

sbm-status

```

Wait for simply checks the number of items in the completed set have the correct length.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
