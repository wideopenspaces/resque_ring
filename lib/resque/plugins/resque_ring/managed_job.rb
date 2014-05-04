$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__) + '/../lib'))
require 'benchmark'
require 'resque_ring/redis_registry'

module Resque
  module Plugins
    module ResqueRing
      module ManagedJob
        @@registry = ::ResqueRing::RedisRegistry.new(Resque.redis.redis)

        # around_perform: measure & store TTP & total ttp
        # avg ttp is total_ttp / jobs_processed
        def around_perform_measure_ttp(*args)
          ttp = Benchmark.realtime { yield }
          @@registry.hset key, 'ttp', ttp
          @@registry.hincrbyfloat key, 'total_ttp', ttp
        end

        # after_perform: increment jobs processed for this worker
        def after_perform_increment_jobs_processed(*args)
          @@registry.hincrby key, 'jobs_processed', 1
        end

        # after_perform: get & store memory usage
        def after_perform_get_rss(*args)
          @@registry.hset key, 'mem_usage', rss
        end

        private

        # See https://gist.github.com/pvdb/6240788
        # Only works on POSIX (OS X, Linux)
        def rss
          `ps -o rss= -p #{ppid}`.chomp.to_i
        end

        # Generates a ResqueRing-formatted key for queue access
        def key
          @@registry.send :_key, @worker_group, @@registry.localize(ppid)
        end

        # Need to get PPID because of the forking.
        def ppid
          Process.ppid
        end
      end
    end
  end
end

## USAGE
# class SearchIndexJob
#   extend ResqueRing::ManagedJob
# end
