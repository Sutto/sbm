# Handles the base of coordinating works in sets between
# X nodes, with each item having a node identifier.

require 'redis'

module SBM
  class Coordinator

    def self.defaults
      worker_name      = (ENV['NODE_NAME']        || raise "Please ensure NODE_NAME is set")
      coordinator_name = (ENV['COORDINATOR_NAME'] || "worker-coordinator")
      return new(coordinator_name), Worker.new(worker_name)
    end

    attr_reader :coordinator_name, :redis

    def initialize(name)
      @coordinator_name = name.to_s
      @redis = Redis.current
    end

    class Batch < Struct.new(:name)

      def to_s; name; end

    end

    class Worker < Struct.new(:name)

      def to_s; name; end

    end

    def batches

      redis.smembers(key(:batches)).map { |w| Worker.new(w) }

    end

    def workers
      redis.smembers(key(:workers)).map { |w| Worker.new(w) }
    end

    def register_worker(worker)
      redis.sadd key(:workers), worker.to_s
    end

    def register_batch(batch)
      redis.sadd key(:batches), worker.to_s
    end

    def started_workers_for_batch(batch)
      key(:batches, batch, :started).map { |w| Worker.new(w) }
    end

    def completed_workers_for_batch(batch)
      key(:batches, batch, :completed).map { |w| Worker.new(w) }
    end

    def start(batch, worker)
      redis.sadd key(:batches, batch, :started), worker.to_s
    end

    def complete(worker, batch)
      redis.sadd key(:batches, batch, :completed), worker.to_s
    end

    # Waits on batch to reach a count, waiting for 15 seconds at a time.
    def wait_for(batch, worker_count, wait_time = 15)
      while redis.scard(key(:batches, batch, :completed)) < worker_count
        sleep wait_time
        yield if block_given?
      end
    end

    private

    def key(*args)
      [coordinator_name, *args].join(":")
    end

  end
end
