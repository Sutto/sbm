# Handles the base of coordinating works in sets between
# X nodes, with each item having a node identifier.

require 'redis'

module SBM
  class Coordinator

    def self.defaults
      worker_name      = (ENV['SBM_WORKER'] or raise "Please ensure SBM_WORKER is set")
      coordinator_name = (ENV['SBM_COORDINATOR'] || "worker-coordinator")
      return new(coordinator_name), Worker.new(worker_name)
    end

    attr_reader :name, :redis

    def initialize(name)
      @name = name.to_s
      @redis = Redis.current
    end

    class Batch < Struct.new(:name)

      def to_s; name; end

    end

    class Worker < Struct.new(:name)
      def to_s; name; end
    end

    def batches
      redis.smembers(key(:batches)).map { |w| Batch.new(w) }
    end

    def workers
      redis.smembers(key(:workers)).map { |w| Worker.new(w) }
    end

    def started_workers_for_batch(batch)
      redis.smembers(key(:batches, batch, :started)).map { |w| Worker.new(w) }
    end

    def completed_workers_for_batch(batch)
      redis.smembers(key(:batches, batch, :completed)).map { |w| Worker.new(w) }
    end

    def start(batch, worker)
      prepare worker, batch
      redis.sadd key(:batches, batch, :started),   worker.to_s
      redis.srem key(:batches, batch, :completed), worker.to_s
    end

    def complete(batch, worker)
      prepare worker, batch
      redis.sadd key(:batches, batch, :completed), worker.to_s
    end

    # Waits on batch to reach a count, waiting for 15 seconds at a time.
    def wait_for(batch, worker_count, wait_time = 15)
      while redis.scard(key(:batches, batch, :completed)) < worker_count
        sleep wait_time
        yield if block_given?
      end
    end

    def clear(batch)
      redis.srem key(:batches), batch.to_s
      redis.del key(:batches, batch, :completed)
      redis.del key(:batches, batch, :started)
    end

    def clear_batches
      batches.each { |b| clear b }
      redis.del key(:batches)
    end

    def clear_workers
      redis.del key(:workers)
    end

    private

    def prepare(worker, batch)
      register_worker worker
      register_batch  batch
    end

    def register_worker(worker)
      redis.sadd key(:workers), worker.to_s
    end

    def register_batch(batch)
      redis.sadd key(:batches), batch.to_s
    end

    def key(*args)
      [name, *args].join(":")
    end

  end
end
