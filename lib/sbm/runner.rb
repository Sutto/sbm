module SBM
  class Runner

    USAGES = {
      'status'         => '',
      'wait-for'       => 'batch-name worker-count',
      'start-batch'    => 'batch-name',
      'complete-batch' => 'batch-name'
    }

    attr_reader :command, :args, :coordinator, :worker, :output, :error

    def initialize(args, output = STDOUT, error = STDERR)
      @command = args.first
      @args    = args.drop(1)
      @output = output
      @error = error
      @coordinator, @worker = SBM::Coordinator.defaults
    end

    def validate_command!
      if command.nil? or !USAGES.has_key?(command)
        usage true
      end
    end

    def run
      validate_command!
      send command.tr('-', '_').to_sym
    end

    def status
      output.puts "Known Workers: #{coordinator.workers.map(&:name).sort.join(", ")}"
      output.puts "Known Batches: #{coordinator.batches.map(&:name).sort.join(", ")}"
      output.puts ""
      output.puts ""
      coordinator.batches.each do |batch|
        started   = coordinator.started_workers_for_batch batch
        completed = coordinator.started_workers_for_batch completed
        output.puts "Batch: #{batch}"
        output.puts "Number Started:   #{started.size}"
        output.puts "Number Completed: #{completed.size}"
        output.puts "Number Pending:   #{started.size - completed.size}"
        output.puts "---"
        output.puts "Started:   #{started.map(&:name).sort.join(", ")}"
        output.puts "Completed: #{completed.map(&:name).sort.join(", ")}"
        output.puts ""
      end
    end

    def wait_for
      batch = extract_batch!
      worker_count = args.shift.to_i
      if worker_count.zero?
        error.puts "You must provide a non-zero worker count"
        usage
      end
      coordinator.wait_for batch, worker_count
    end

    def start_batch
      batch = extract_batch!
      coordinator.start batch, worker
    end

    def complete_batch
      batch = extract_batch!
      coordinator.complete batch, worker
    end

    def usage(invalid_command = false)
      if invalid_command
        error.puts "Invalid / unknown command - must be one of #{USAGES.keys.join(", ")}"
        error.puts "Usage: #$0 #{USAGES.keys.join("|")} [arguments]"
        exit 1
      else
        error.puts "Usage: #$0 #{command} #{USAGES[command]}".strip
        exit 1
      end
    end

    def extract_batch!
      batch_name = args.shift
      if batch_name.to_s.strip.empty?
        error.puts "You must provide a batch name."
        usage
      end
      Coordinator::Batch.new(batch_name)
    end

  end
end
