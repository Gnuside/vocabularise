
require 'fileutils'
require 'test/unit'
require 'pp'

require 'rubygems'
require 'bundler/setup'
require 'rspec'
require 'json'

require 'data_mapper'
require 'dm-core'
require 'dm-sqlite-adapter'                                                     

require 'wikipedia'
require 'vocabularise/queue'

require 'spec/spec_helper'

describe 'Queue' do

	REQ_RELATED = "internal:related"
	REQ_EXPECTED = "internal:expected"
	REQ_AGGREGATING = "internal:aggregating"
	REQ_OTHER = "other:noop"

	before :all do
		@queue = {}
		@queue[:one] = ::VocabulariSe::Queue.new :one
		@queue[:two] = ::VocabulariSe::Queue.new :two
	end

	before :each do
		VocabulariSe::QueueEntry.all.destroy
	end

	def helper_make_samepriority name
		@queue[name].push "internal:related", 'love'
		@queue[name].push "internal:expected", 'death'
		@queue[name].push "internal:aggregating", 'love'
	end

	def helper_make_diffpriority name
		@queue[name].push REQ_RELATED, 'love', 
			VocabulariSe::Queue::PRIORITY_HIGH
		@queue[name].push REQ_EXPECTED, 'death', 
			VocabulariSe::Queue::PRIORITY_LOW
		@queue[name].push REQ_AGGREGATING, 'love', 
			VocabulariSe::Queue::PRIORITY_NORMAL
	end


	describe '#size' do
		it 'should be zero at start' do
			@queue[:one].size.should == 0
			@queue[:two].size.should == 0
		end

		it 'should be increased by each push' do
			(1..100).each do |x|
				@queue[:one].push REQ_RELATED, "item#{x}"
				@queue[:one].size.should == x
			end
			@queue[:two].size.should == 0
		end

		it 'should be minored by each pop/shift' do
			(1..100).each do |x|
				@queue[:one].push REQ_RELATED, "item#{x}"
				@queue[:one].size.should == x
			end
			@queue[:one].size.should == 100
			@queue[:two].size.should == 0
			(1..100).each do |x|
				@queue[:one].pop
			end
			@queue[:one].size.should == 0
			@queue[:two].size.should == 0
		end
	end

	describe '#empty!' do
		it 'should empty the queue' do
			pending("test not implemented")
		end

		it 'should return the queue object' do
			@queue[:one].empty!.should == @queue[:one]
		end

		it 'should separate queues with different names' do
			@queue[:one].size.should == 0
			@queue[:two].size.should == 0

			@queue[:one].push REQ_RELATED, 'love'
			@queue[:two].push REQ_RELATED, 'hate'

			@queue[:one].empty!

			@queue[:one].size.should == 0
			@queue[:two].size.should == 1
		end
	end


	#
	#
	#
	describe '#empty?' do
		it 'should respond true at start' do
			@queue[:one].should respond_to :empty?

			@queue[:one].empty?.should == true
		end


		#
		#
		#
		it 'should repond true at start (even with selector)' do
			@queue[:one].should respond_to :empty?

			@queue[:one].empty?.should == true
		end


		#
		#
		#
		it 'should remove pushed content' do
			@queue[:one].should respond_to :empty!

			helper_make_samepriority :one

			@queue[:one].size.should >= 0
			@queue[:one].empty!
			@queue[:one].size.should == 0
			@queue[:one].empty?.should == true
		end
	end
	

	#
	#
	#
	describe '#push' do
		it 'should add t-uples of (handle,query)' do
			@queue[:one].should respond_to :push

			@queue[:one].push :related, 'love'
			@queue[:one].size.should == 1
			@queue[:one].push :expected, 'love'
			@queue[:one].size.should == 2
			@queue[:one].empty?.should == false
		end



		#
		#
		#
		it 'should add t-uples of (handle,query,priority)' do
			@queue[:one].should respond_to :push

			@queue[:one].push REQ_RELATED, 'love', 
				VocabulariSe::Queue::PRIORITY_LOW
			@queue[:one].size.should == 1
			@queue[:one].push REQ_EXPECTED, 'love', 
				VocabulariSe::Queue::PRIORITY_HIGH
			@queue[:one].size.should == 2
			@queue[:one].empty?.should == false
		end


		it 'should fail when pushing the same element multiple times' do

			@queue[:one].push REQ_RELATED, 'love'
			lambda {
				@queue[:one].push REQ_RELATED, 'love'
			}.should raise_error VocabulariSe::Queue::AlreadyQueuedError


			@queue[:one].size.should == 1
			@queue[:two].size.should == 0
		end

		#
		#
		#
		it 'should separate queues with different names' do
			@queue[:one].size.should == 0
			@queue[:two].size.should == 0

			@queue[:one].push REQ_RELATED, 'love'

			@queue[:one].size.should == 1
			@queue[:two].size.should == 0

			# FIXME: it should fail here
			@queue[:two].push REQ_RELATED, 'love'

			@queue[:one].size.should == 1
			@queue[:two].size.should == 1
		end
	end


	#
	describe '#include?' do
		#
		it 'should allow test on included (handle,query)' do
			@queue[:one].should respond_to :include?

			@queue[:one].include?(:related, 'love').should == false
			@queue[:one].push :related, 'love'
			@queue[:one].include?(:related, 'love').should == true
			@queue[:one].include?(:expected, 'love').should == false
		end
	end


	describe '#first' do
		it 'should allow access to first' do
			@queue[:one].should respond_to :first

			helper_make_samepriority :one

			handler, query, priority = @queue[:one].first
			handler.should == REQ_RELATED
			query.should == 'love'
		end
	end


	describe '#shift' do
		it 'should be shift-able' do
			@queue[:one].should respond_to :shift

			helper_make_samepriority :one

			@queue[:one].shift.shift

			handler, query, priority = @queue[:one].first
			handler.should == REQ_AGGREGATING
			query.should == 'love'
		end
	end


	describe '#pop' do
		it 'should be pop-able' do
			@queue[:one].should respond_to :shift

			helper_make_samepriority :one

			@queue[:one].shift
			handler, query, priority = @queue[:one].pop

			handler.should == REQ_EXPECTED
			query.should == 'death'
		end
	end


	describe '#first' do
		#
		it 'should fail on an empty queue' do

			lambda{ @queue[:one].first }.should raise_error VocabulariSe::Queue::EmptyQueueError
		end

		#
		it 'should not shift an empty queue' do

			lambda{ @queue[:one].shift }.should raise_error VocabulariSe::Queue::EmptyQueueError
		end

		#
		it 'should prioritize' do
			pending("test not implemented")
		end
	end


	describe '#stress' do
		it 'should increase item priority in queue' do
		end
	end

	describe '#each' do
		it 'should iterate through entries' do
			@queue[:one].should respond_to :each

			pending("test not implemented")
		end

		it 'should preserve order' do
			@queue[:one].push :A, 1
			@queue[:one].push :B, 2
			@queue[:one].push :C, 3

			pending("test not implemented")
		end
	end

	describe '#lock' do
		it 'should disable the entry' do
			@queue[:one].push :A, 1
			@queue[:one].push :B, 2
			@queue[:one].push :C, 3

			@queue[:one].lock :A, 1
			h, q, p = @queue[:one].first
			h.should == 'B'
			q.should == 2
		end
	end

	describe '#delete' do
		it 'should delete an entry, wherever it is' do
			@queue[:one].push :A, 1
			@queue[:one].push :B, 2
			@queue[:one].push :C, 3

			@queue[:one].delete :A, 1
			h, q, p = @queue[:one].first
			h.should == 'B'
			q.should == 2
		end

		it 'should delete an entry even locked' do
			@queue[:one].push :A, 1
			@queue[:one].push :B, 2
			@queue[:one].push :C, 3

			@queue[:one].lock :A, 1
			@queue[:one].delete :A, 1
			@queue[:one].delete :B, 2
			h, q, p = @queue[:one].first
			h.should == 'C'
			q.should == 3
		end
	end

end

