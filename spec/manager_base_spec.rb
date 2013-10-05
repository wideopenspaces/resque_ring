require 'spec_helper'

describe Resque::Plugins::Resqued::Manager do
	context 'a new instance' do
		context 'with no options specified' do
			subject { Resque::Plugins::Resqued::Manager.new }

			it 'responds to #run!' do
				subject.must_respond_to(:run!)
			end

			it 'sets an accessor for options that defaults to an empty hash' do
				subject.options.must_be_instance_of(Hash)
			end
		end

		context 'with config file given' do
			let(:config) { './spec/support/config_with_delay.yml' }
			subject { Resque::Plugins::Resqued::Manager.new(config: config) }

			it 'sets the delay option specified' do
				subject.delay.must_equal(60)
			end

			it 'appropriately sets the worker_groups collection' do
				subject.worker_groups.keys.must_include('indexing')
			end

			context 'with a worker group called indexing' do
				let(:mgr) { Resque::Plugins::Resqued::Manager.new(config: config) }
				subject { mgr.worker_groups }

				it 'contains a worker group called indexing' do
					subject['indexing'].wont_be_nil
				end

				context 'the worker group' do
					subject { mgr.worker_groups['indexing'] }

					it 'has a wait time of 120' do
						subject['wait_time'].must_equal 120
					end

					it 'has a queue threshold of 100' do
						subject['threshold'].must_equal 100
					end

					it 'has a spawn rate of 1' do
						subject['spawn_rate'].must_equal 1
					end

					it 'watches three queues' do
						subject['queues'].size.must_equal 3
					end

					it 'has the correct queues' do
						subject['queues'].must_equal(%w(queue_the_first queue_tee_pie queue_the_music))
					end

					it 'has pool settings' do
						subject['pool'].wont_be_empty
					end

					it 'has a min pool size of 2' do
						subject['pool']['min'].must_equal 2
					end

					it 'has a max pool size of 5' do
						subject['pool']['max'].must_equal 5
					end

					it 'will launch the first at 1 item in queue' do
						subject['pool']['first_at'].must_equal 1
					end
				end
			end
		end
	end
end