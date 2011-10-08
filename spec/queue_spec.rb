
require 'fileutils'
require 'test/unit'
require 'pp'

require 'rubygems'
require 'bundler/setup'
require 'rspec'
require 'json'

require 'datamapper'
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
		@queue = ::VocabulariSe::Queue.new :example
	end

	before :each do
		VocabulariSe::QueueEntry.all.destroy
	end

	def helper_make_samepriority
		@queue.push "internal:related", 'love'
		@queue.push "internal:expected", 'death'
		@queue.push "internal:aggregating", 'love'
	end

	def helper_make_diffpriority
		@queue.push REQ_RELATED, 'love', 
			VocabulariSe::Queue::PRIORITY_HIGH
		@queue.push REQ_EXPECTED, 'death', 
			VocabulariSe::Queue::PRIORITY_LOW
		@queue.push REQ_AGGREGATING, 'love', 
			VocabulariSe::Queue::PRIORITY_NORMAL
	end

	describe '#size' do
		it 'should be zero at start' do
			@queue.size.should == 0
		end

		it 'should be increased by each push' do
			(1..100).each do |x|
				@queue.push REQ_RELATED, "item#{x}"
				@queue.size.should == x
			end
		end

		it 'should be minored by each pop/shift' do
		end
	end

	describe '#empty!' do
		it 'should empty the queue' do
			pending("test not implemented")
		end

		it 'should return the queue object' do
			@queue.empty!.should == @queue
		end
	end

	describe '#empty?' do
		it 'should respond true at start' do
			@queue.should respond_to :empty?

			@queue.empty?.should == true
		end

		it 'should repond true at start (even with selector)' do
			@queue.should respond_to :empty?

			@queue.empty?.should == true
		end

		it 'should remove pushed content' do
			@queue.should respond_to :empty!

			helper_make_samepriority

			@queue.size.should >= 0
			@queue.empty!
			@queue.size.should == 0
			@queue.empty?.should == true
		end
	end
	#

	describe '#push' do
		it 'should add t-uples of (handle,query)' do
			@queue.should respond_to :push

			@queue.push :related, 'love'
			@queue.size.should == 1
			@queue.push :expected, 'love'
			@queue.size.should == 2
			@queue.empty?.should == false
		end

		it 'should add t-uples of (handle,query,priority)' do
			@queue.should respond_to :push

			@queue.push REQ_RELATED, 'love', 
				VocabulariSe::Queue::PRIORITY_LOW
			@queue.size.should == 1
			@queue.push REQ_EXPECTED, 'love', 
				VocabulariSe::Queue::PRIORITY_HIGH
			@queue.size.should == 2
			@queue.empty?.should == false
		end
	end


	#

	describe '#include?' do
		#
		it 'should allow test on included (handle,query)' do
			@queue.should respond_to :include?

			@queue.include?(:related, 'love').should == false
			@queue.push :related, 'love'
			@queue.include?(:related, 'love').should == true
			@queue.include?(:expected, 'love').should == false
		end
	end


	describe '#first' do
		it 'should allow access to first' do
			@queue.should respond_to :first

			helper_make_samepriority

			handler, query, priority = @queue.first
			handler.should == REQ_RELATED
			query.should == 'love'
		end
	end


	describe '#shift' do
		it 'should be shift-able' do
			@queue.should respond_to :shift

			helper_make_samepriority

			@queue.shift.shift

			handler, query, priority = @queue.first
			handler.should == REQ_AGGREGATING
			query.should == 'love'
		end
	end


	describe '#pop' do
		it 'should be pop-able' do
			@queue.should respond_to :shift

			helper_make_samepriority

			@queue.shift
			handler, query, priority = @queue.pop

			handler.should == REQ_EXPECTED
			query.should == 'death'
		end
	end


	describe '#first' do
		#
		it 'should fail on an empty queue' do

			lambda{ @queue.first }.should raise_error VocabulariSe::Queue::EmptyQueueError
		end

		#
		it 'should not shift an empty queue' do

			lambda{ @queue.shift }.should raise_error VocabulariSe::Queue::EmptyQueueError
		end

		#
		it 'should prioritize' do
			pending("test not implemented")
		end
	end


	describe '#each' do
		it 'should iterate through entries' do
			@queue.should respond_to :each

			pending("test not implemented")
		end

		it 'should preserve order' do
			@queue.push :A, 1
			@queue.push :B, 2
			@queue.push :C, 3

			pending("test not implemented")
		end
	end

end

