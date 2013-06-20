module SBM
  class Runner

    USAGES = {
      'status'         => ''
      'wait-for'       => 'batch-name worker-count'
      'start-batch'    => 'batch-name'
      'complete-batch' => 'batch-name'
    }

    attr_reader :command, :args, :coordinator, :worker

    def initialize(args)
      @command = args.shift
      usage true if command.nil? or !USAGE.has_key?(command)
      @args    = args
      @coordinator, @worker = SBM::Cordinator.defaults
    end

    def run
      send command.tr('-', '_').to_sym
    end

    def status
    end

    def wait_for
      batch_name = args.first
      worker_count = args[1].to_i
      if batch_name.to_s.strip.empty?
        warn "You must provide a batch name :("
        usage
      elsif  worker_count.zero?
        warn "You must provide a non-zero worker count"
        usage
      end
      batch = Coordination::Batch.new(batch_name)
      coordinator.wait_for batch, worker_count
    end

    def start_batch
      batch_name = args.first
      if batch_name.to_s.strip.empty?
        warn "You must provide a batch name :("
        usage
      end
      batch = Coordination::Batch.new(batch_name)
      coordinator.start batch, worker
    end

    def complete_batch
      batch_name = args.first
      if batch_name.to_s.strip.empty?
        warn "You must provide a batch name :("
        usage
      end
      batch = Coordination::Batch.new(batch_name)
      coordinator.complete batch, worker
    end

    def usage(invalid_command = false)
      if invalid_command
        STDERR.puts "Invalid / unknown command - must be one of #{USAGES.keys.join(", ")}"
        STDERR.puts "Usage: #$0 #{USAGES.keys.join("|")} [arguments]"
        exit 1
      else
        STDERR.puts "Usage: #$0 #{command} #{USAGES[command]}".strip
        exit 1
      end
    end

  end
end
