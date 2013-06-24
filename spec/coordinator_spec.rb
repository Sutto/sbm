require 'spec_helper'

describe SBM::Coordinator do

  let(:worker_a) { described_class::Worker.new 'elephant' }
  let(:worker_b) { described_class::Worker.new 'pony'     }
  let(:worker_c) { described_class::Worker.new 'fish'     }

  let(:batch_a) { described_class::Batch.new 'fishing' }
  let(:batch_b) { described_class::Batch.new 'running' }
  let(:batch_c) { described_class::Batch.new 'rocking' }

  subject { described_class.new 'my-awesome-item' }

  it 'should register the batch and worker on starting' do
    subject.batches.should be_empty
    subject.workers.should be_empty
    subject.start batch_a, worker_a
    subject.batches.should == [batch_a]
    subject.workers.should == [worker_a]
    subject.start batch_a, worker_b
    subject.batches.should == [batch_a]
    subject.workers.should =~ [worker_a, worker_b]
    subject.start batch_b, worker_c
    subject.batches.should =~ [batch_a, batch_b]
    subject.workers.should =~ [worker_a, worker_b, worker_c]
  end

  it 'should register the batch and worker on completing' do
    subject.batches.should be_empty
    subject.workers.should be_empty
    subject.complete batch_a, worker_a
    subject.batches.should == [batch_a]
    subject.workers.should == [worker_a]
    subject.complete batch_a, worker_b
    subject.batches.should == [batch_a]
    subject.workers.should =~ [worker_a, worker_b]
    subject.complete batch_b, worker_c
    subject.batches.should =~ [batch_a, batch_b]
    subject.workers.should =~ [worker_a, worker_b, worker_c]
  end

  it 'should return a list of started workers' do
    subject.started_workers_for_batch(batch_a).should == []
    subject.started_workers_for_batch(batch_b).should == []
    subject.started_workers_for_batch(batch_c).should == []
    subject.start batch_a, worker_a
    subject.started_workers_for_batch(batch_a).should == [worker_a]
    subject.started_workers_for_batch(batch_b).should == []
    subject.started_workers_for_batch(batch_c).should == []
    subject.start batch_a, worker_b
    subject.started_workers_for_batch(batch_a).should =~ [worker_a, worker_b]
    subject.started_workers_for_batch(batch_b).should == []
    subject.started_workers_for_batch(batch_c).should == []
    subject.start batch_c, worker_c
    subject.started_workers_for_batch(batch_a).should =~ [worker_a, worker_b]
    subject.started_workers_for_batch(batch_b).should == []
    subject.started_workers_for_batch(batch_c).should == [worker_c]
  end

  it 'should return a list of completed workers' do
    subject.completed_workers_for_batch(batch_a).should == []
    subject.completed_workers_for_batch(batch_b).should == []
    subject.completed_workers_for_batch(batch_c).should == []
    subject.complete batch_a, worker_a
    subject.completed_workers_for_batch(batch_a).should == [worker_a]
    subject.completed_workers_for_batch(batch_b).should == []
    subject.completed_workers_for_batch(batch_c).should == []
    subject.complete batch_a, worker_b
    subject.completed_workers_for_batch(batch_a).should =~ [worker_a, worker_b]
    subject.completed_workers_for_batch(batch_b).should == []
    subject.completed_workers_for_batch(batch_c).should == []
    subject.complete batch_c, worker_c
    subject.completed_workers_for_batch(batch_a).should =~ [worker_a, worker_b]
    subject.completed_workers_for_batch(batch_b).should == []
    subject.completed_workers_for_batch(batch_c).should == [worker_c]
  end

  it 'should remove from completed on starting' do
    subject.started_workers_for_batch(batch_a).should == []
    subject.completed_workers_for_batch(batch_a).should == []
    subject.complete batch_a, worker_a
    subject.started_workers_for_batch(batch_a).should == []
    subject.completed_workers_for_batch(batch_a).should == [worker_a]
    subject.start batch_a, worker_a
    subject.started_workers_for_batch(batch_a).should == [worker_a]
    subject.completed_workers_for_batch(batch_a).should == []
  end

  it 'should work for the full flow' do
    subject.started_workers_for_batch(batch_a).should == []
    subject.completed_workers_for_batch(batch_a).should == []
    subject.start batch_a, worker_a
    subject.started_workers_for_batch(batch_a).should == [worker_a]
    subject.completed_workers_for_batch(batch_a).should == []
    subject.complete batch_a, worker_a
    subject.started_workers_for_batch(batch_a).should == [worker_a]
    subject.completed_workers_for_batch(batch_a).should == [worker_a]
  end

  it 'should let you wait for a given batch to finish' do
    encountered = 0
    mock(subject).sleep(anything).times(3) do
      encountered += 1
      if encountered == 2
        subject.completed_workers_for_batch(batch_a).should == [worker_c]
        subject.complete batch_a, worker_a
        subject.completed_workers_for_batch(batch_a).should =~ [worker_c, worker_a]
      elsif encountered == 3
        subject.completed_workers_for_batch(batch_a).should =~ [worker_c, worker_a]
        subject.complete batch_a, worker_b
        subject.completed_workers_for_batch(batch_a).should =~ [worker_c, worker_a, worker_b]
      end
    end
    subject.complete batch_a, worker_c
    subject.completed_workers_for_batch(batch_a).should == [worker_c]
    subject.wait_for batch_a, 3
  end

end
