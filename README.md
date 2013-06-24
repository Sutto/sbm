# SBM - Simple Batch Manager

Manages running / coordinating batch processes running across multiple hosts.

Uses redis as a simple coordinator to ensure split work runs across hosts evenly.

**Note:** SBM is still a hack. It's untested. Don't use this for production stuff. Please!

## Installation

Add this line to your application's Gemfile:

    gem 'sbm'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sbm

## Usage

SBM is composed of a set of simple scripts useful for running in shells. The only required
variable is `SBM_WORKER` as an environment variable - the name of the node the current job is
running on.`

```bash
#!/usr/bin/env bash -e

export SBM_WORKER="$(hostname)-$$"

# Used if you have a bunch of different batches with the same name:
# export SBM_COORDINATOR='your-groups'

sbm start-work my-test-batch
rake do:your:work
sbm complete-work my-test-batch && sbm wait-for my-test-batch 20 # There are 20 nodes running this process

sbm status

```

Wait for simply checks the number of items in the completed set have the correct length.

Please note that by default it uses redis for this, so to change your default redis use `REDIS_URI`.

### Commands

* `sbm status` - Show status of all batches.
* `sbm start-batch batch-name` - Current worker starts the specified batch.
* `sbm complete-batch batch-name` - Current worker starts the specified batch.
* `sbm wait-for batch-name count` - Wait until `count` workers have completed `batch-name`.
* `sbm clear-batch batch-name` - Clear information for the given batch.
* `sbm clear-batches` - Clear all batch info.
* `sbm clear-workers` - Clear all worker info.


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
