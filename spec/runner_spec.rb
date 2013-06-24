require 'spec_helper'

describe SBM::Runner do

  before do
    ENV['SBM_WORKER'] = 'xyz'
  end

  context 'initialization' do

    it 'should setup the default worker' do
      instance = described_class.new([])
      worker = instance.worker
      worker.should be_a SBM::Coordinator::Worker
      worker.name.should == SBM::Coordinator.defaults[1].name
    end

    it 'should setup the default coordinator' do
      instance = described_class.new([])
      coordinator = instance.coordinator
      coordinator.should be_a SBM::Coordinator
      coordinator.name.should == SBM::Coordinator.defaults[0].name
    end

    it 'should setup output / error' do
      instance = described_class.new([])
      instance.output.should == STDOUT
      instance.error.should == STDERR
    end

    it 'should allow overriding the output and error' do
      out = StringIO.new
      err = StringIO.new
      instance = described_class.new([], out, err)
      instance.output.should == out
      instance.error.should == err
    end

    it 'should extract the command and args' do
      instance = described_class.new ['x', 'y', 'z']
      instance.command.should == 'x'
      instance.args.should == ['y', 'z']
    end

  end

  context 'setting up runner stuff' do

    let(:output) { StringIO.new }
    let(:error)  { StringIO.new }

    let(:args) { [] }

    subject do
      instance = described_class.new args, output, error
      stub(instance).exit.with_any_args
      instance
    end

    context 'with a runner' do

      it 'should let you validate the command' do
        ['status', 'start-batch', 'complete-batch', 'wait-for'].each do |command|
          instance = described_class.new [command], output, error
          dont_allow(instance).exit.with_any_args
          instance.validate_command!
        end
      end

      it 'should exit with a bad command' do
        ['dfsdf', 'startbatch', 'complete', nil].each do |command|
          instance = described_class.new [command], output, error
          mock(instance).exit 1
          instance.validate_command!
        end
      end

      it 'should run the command' do
        args.replace %w(status)
        mock(subject).status
        subject.run
      end

      it 'should work with non-standard commands' do
        args.replace %w(start-batch)
        mock(subject).start_batch
        subject.run
      end

      it 'should validate on run' do
        args.replace %w(status)
        mock(subject).validate_command!
        subject.run
      end

    end

    context 'starting batches' do

      it 'should be an error without a batch name' do
        subject.args.should == []
        mock(subject).exit 1
        subject.start_batch
      end

      it 'should work with the coordinator' do
        subject.args.replace %w(xyz)
        mock(subject.coordinator).start subject.worker, SBM::Coordinator::Batch.new('xyz')
        dont_allow(subject).exit
        subject.start_batch
      end

    end

    context 'completing batches' do

      it 'should be an error without a batch name' do
        subject.args.should == []
        mock(subject).exit 1
        subject.complete_batch
      end

      it 'should work with the coordinator' do
        subject.args.replace %w(xyz)
        mock(subject.coordinator).complete subject.worker, SBM::Coordinator::Batch.new('xyz')
        dont_allow(subject).exit
        subject.complete_batch
      end

    end

    context 'waiting for batches' do

      it 'should be an error without a batch name' do
        subject.args.replace []
        mock(subject).exit 1
        subject.wait_for
      end

      it 'should be an error without an instance count' do
        subject.args.replace ['test-batch']
        mock(subject).exit 1
        subject.wait_for
      end

      it 'should be an error with a bad instance count' do
        subject.args.replace ['test-batch', '0']
        mock(subject).exit 1
        subject.wait_for
      end

      it 'should work with the coordinator' do
        subject.args.replace %w(xyz 3)
        mock(subject.coordinator).wait_for SBM::Coordinator::Batch.new('xyz'), 3
        dont_allow(subject).exit
        subject.wait_for
      end

    end

  end

end
