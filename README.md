ResqueRing
==========

[![Version](http://allthebadges.io/wideopenspaces/resque_ring/badge_fury.png)](http://allthebadges.io/wideopenspaces/resque_ring/badge_fury)
[![Dependencies](http://allthebadges.io/wideopenspaces/resque_ring/gemnasium.png)](http://allthebadges.io/wideopenspaces/resque_ring/gemnasium)
[![Build Status](http://allthebadges.io/wideopenspaces/resque_ring/travis.png)](http://allthebadges.io/wideopenspaces/resque_ring/travis)
[![Coverage](http://allthebadges.io/wideopenspaces/resque_ring/coveralls.png)](http://allthebadges.io/wideopenspaces/resque_ring/coveralls)
[![Code Climate](http://allthebadges.io/wideopenspaces/resque_ring/code_climate.png)](http://allthebadges.io/wideopenspaces/resque_ring/code_climate)

# An auto-scaling pool manager for resque workers.

ResqueRing provides cluster-friendly, auto-scaling, lightweight
management services for Resque workers. It can manage multiple
worker groups, each watching multiple queues, and scale workers
based on available work.

# Features

- Multiple worker groups, each supporting multiple queues
- Scale easily from MIN to MAX workers based on queue sizes
- Scale down to MIN workers when idle (even 0!)
- Configurable spawn throttling
- Contractor Mode: start 1st worker automatically when items enter its queues.
- Automatically manages and keeps track of workers it spawns
- Track jobs processed, age & other data for each worker
  - Number of jobs processed
  - Age of worker
  - Memory usage
  - Time to process
- All communication happens through Redis for easy clustering
- Manage worker pool sizes locally (1 server) and globally (across servers)

Installation
------------

The simplest way to install ResqueRing is to use [Bundler](http://gembundler.com/).

Add ResqueRing to a `Gemfile` in your project’s root:

```ruby
gem 'resque_ring'
```

then install it by running Bundler:

```bash
$ bundle
```

Usage
-----

ResqueRing is run from the command line (or a process monitor like monit).
Please open your terminal and go to your project's directory.

Running `resque_ring` with no arguments prints this:

```sh
Commands:
  resque_ring help [COMMAND]             # Describe available commands or one specific command
  resque_ring start -c, --config=CONFIG  # start a resque_ring
  resque_ring version                    # print version
```

### Help

You can always get help on the available tasks with the `help` task:

```bash
$ bundle exec resque_ring help
```

To get help for a specific command, append it to
the end of the previous example, e.g.,

```bash
$ bundle exec resque_ring help start
```

When started on multiple servers using the same configuration
and Redis server, each ResqueRing will coordinate efforts
with the others.

### Start

ResqueRing is controlled primarily through a configuration file,
so starting a new instance is simple:

```sh
bundle exec resque_ring start -c my_config.yml
```

#### `-c`/`--config` option

Sets the location of the ResqueRing config file. If this is not
specified, ResqueRing will look for a `resque_ring.yml` file in your current
directory.

### Version

Prints the current version of ResqueRing.

```sh
bundle exec resque_ring version
```

### Signals

You can control ResqueRing with POSIX signals.

#### Quit

Quit ResqueRing after cleaning up.

```bash
$ kill -INT <resque_ring_pid>
```

`TERM` and `QUIT` also work splendidly.

#### Downsize

Quit all workers cleanly, but leave everything running.
Workers will respawn automatically.

```bash
$ kill -USR1 <resque_ring_pid>
```

#### Reload

Quit all workers cleanly, reload config, and start fresh.

```bash
$ kill -HUP <resque_ring_pid>
```

#### Pause

Quit all workers and prevent them from respawning.

```bash
$ kill -STOP <resque_ring_pid>
```

#### Continue

Allow a paused ResqueRing process to go back to work.

```bash
$ kill -CONT <resque_ring_pid>
```

Configuration
-------------

The configuration file has three main groups: global settings,
redis settings, and worker definitions.

### Global settings

Global settings are at the root of the yml file. All global
settings are optional, but ResqueRing will use its own
defaults if not set.

```yml
delay: 60 # seconds to wait before checking again
```

### Redis settings

Redis settings, if included, should include the host & port
of your Redis server. If not included, ResqueRing will use
the default Redis host and port: `localhost:6379`.

```yml
redis:
  host: localhost
  port: 6379
```

### Worker settings

The **workers** group can contain any number of subsections,
identified by your desired name for each group of workers.

This is useful if you need to manage different sets of Resque
workers for different tasks.

Each group of workers has a number of options:

| Option           | Note                                                           |
|------------------|----------------------------------------------------------------|
| wait_time        | how long to wait before starting another worker.               |
| threshold        | how many items in queue before starting more than min workers. |
| spawn_rate       | when spawning new workers, how many to start at a time.        |
| remove_when_idle | start removing workers when queue is empty (default: true)     |
| spawner          | options describing how to start an actual worker task.         |
| queues           | a list of queues this worker group should watch.               |
| pool             | options for the pool of workers.                               |

#### Spawner options

`command` is the specific command used to start the worker.  
`dir` tells ResqueRing to cwd to this directory before running the command.  
`env` provides a list of environment variables set before running the worker.

> **Note**: ResqueRing resets all existing environment variables
> prior to setting the environment variables specified here.

```yml
spawner:
  command: bundle exec rake resque:work
  dir: /this/is/my/work/dir
  env:
    rails_env: development
```

#### queues

A list of queues this worker group is expected to watch.

```yml
queues:
  - queue_the_first
  - queue_tee_pie
  - queue_the_music
```

#### Pool options

Pool options configure the management of a pool of workers.

`min` sets the number of workers to start immediately.  
`max` sets the maximum number of workers to spawn on this server.  
`global_max` sets the maximum number of workers to run across all servers.  
`first_at` (see note)

> **Note**: first_at, when used with `min_workers: 0` allows a ResqueRing pool
> to "idle" with no workers when there are no jobs to process. This is
> **Contractor mode**.
>
> In normal operation, when min_workers is greater than zero, ResqueRing
> will start `min_workers` number of workers initially, but will not
> start more until `threshold` is reached.
>
> In **Contractor mode**, a worker is started immediately as soon as
> `first_at` number of items enter the queue, and no more workers will
> start until `threshold` is reached.
>
> Combined with `remove_when_idle`, this allows ResqueRing to spin up
> and down as needed, rather than maintain an always-active pool of
> workers.

```yml
pool:
  min: 1         # How many to start initially, 0 means no workers until queue; defaults to 1
  max: 5         # The most we'll ever start; defaults to 5
  global_max: 15 # Max workers across all servers; default 0 (no limit)
  first_at: 1    # Use with min_workers 0; fewer than fire_at jobs in queue will not start any workers. Defaults to 1, and is only checked if min_workers is 0
```

### All together now

A complete configuration file looks something like this:

```yml
delay: 60 # seconds to wait before checking again
redis:
  host: localhost
  port: 6379
workers:
  indexing: # What you name, you love.
    wait_time: 120         # don't start another worker more often than this (seconds); will only ever start one worker per configured queue within time set above in delay
    threshold: 100         # If queue gets bigger than this, start another worker until max workers reached
    spawn_rate: 1          # How many workers to spawn at a time, defaults to 1
    remove_when_idle: true # start removing workers when queue is idle (defaults to true)
    spawner:
      command: bundle exec rake resque:work
      dir: /this/is/my/work/dir
      env:
        rails_env: development
    queues:                # list of queues this worker listens for
      - queue_the_first
      - queue_tee_pie
      - queue_the_music
    pool:
      min: 1         # How many to start initially, 0 means no workers until queue; defaults to 1
      max: 5         # The most we'll ever start; defaults to 5
      global_max: 15 # Max workers across all servers; default 0 (no limit)
      first_at: 1    # Use with min_workers 0; fewer than fire_at jobs in queue will not start any workers. Defaults to 1, and is only checked if min_workers is 0
```

Planned features
----------------

- [ ] Ability to kill & respawn workers based on metrics above
- [ ] Wildcard queues?

Contributing
-------------

Fixing a bug? Adding an awesome new feature? Your pull requests are welcome!
* Please create a feature branch each separate change
* Write tests for your changes! All specs and code quality checks
  must pass on [Travis CI](https://travis-ci.org/wideopenspaces/resque_ring).
* Update the documentation.
* Update the [README](https://github.com/wideopenspaces/wideopenspaces/blob/master/README.md).
* Please **do not change** the version number.

License
-------
Released under the MIT License.  See the [LICENSE][] file for further details.

[license]: LICENSE.md
