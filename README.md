resqued
==============

[![Build Status](https://travis-ci.org/wideopenspaces/resqued.png?branch=master)](https://travis-ci.org/wideopenspaces/resqued)
[![Code Climate](https://codeclimate.com/github/wideopenspaces/resqued.png)](https://codeclimate.com/github/wideopenspaces/resqued)

Autoscaling pool manager for resque workers.

## Planned features

### Initial release

- [x] Multiple worker groups, each supporting multiple queues
- [x] Scale easily from MIN to MAX workers based on queue sizes
- [x] Scale down to MIN workers when idle (even 0!)
- [x] Configurable spawn throttling
- [ ] Contractor Mode: start 1st worker automatically when items enter its queues.
- [ ] Automatically manages and keeps track of workers it spawns
- [ ] Track jobs processed, age & other data for each worker
- [ ] Communicates with workers through Resque/Redis
- [ ] Manages worker pool sizes locally (1 server) and globally (across servers)

### Later releases

* Ability to kill & respawn workers based on
  * Number of jobs processed
  * Age of worker
  * Memory usage
  * Time to process? (deviation from avg TTP?)


Example configuration:

```
resque: url to redis/resque installation
delay: 60 # seconds to wait before checking again
workers:
  indexing:
    spawner:
      command: bundle exec rake resque:work
      dir: /this/is/my/work/dir
      env:
        rails_env: development
    wait_time: 120 # don't start another worker more often than this (seconds); will only ever start one worker per configured queue within time set above in delay
    threshold: 100# If queue gets bigger than this, start another worker until max workers reached
    spawn_rate: 1 # How many workers to spawn at a time, defaults to 1
    remove_when_idle: true # start removing workers when queue is idle
    queues:  # list of queues this worker listens for
      - queue_the_first
      - queue_tee_pie
      - queue_the_music
    pool:
      global_max: 15 # Max workers across all servers; default 0 (no limit)
      min: 1 # How many to start initially, 0 means no workers until queue; defaults to 1
      max: 5 # The most we'll ever start; defaults to 5
      first_at: 1  # Use with min_workers 0; fewer than fire_at jobs in queue will not start any workers. Defaults to 1, and is only checked if min_workers is 0
```
