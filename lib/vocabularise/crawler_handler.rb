
module VocabulariSe ; module CrawlerHandler
	class Base
		#inspired by YARD::Handlers::Base
		# cf https://github.com/lsegal/yard/blob/master/lib/yard/handlers/base.rb

		class << self
			def clear_subclasses
				@@subclasses = []
			end

			def subclasses
				@@subclasses ||= []
			end

			def inherited(subclass)
				@@subclasses ||= []
				@@subclasses << subclass
			end

			def handles(*matches)
				(@handlers ||= []).push(*matches)
			end

			def handles?(statement)
				raise NotImplementedError, "override #handles? in a subclass"
			end

			def handlers
				@handlers ||= []
			end

			def process(&block)
				mod = Module.new
				mod.send(:define_method, :process, &block)
				include mod
			end
		end

		def process
			raise NotImplementedError, "#{self} did not implement a #process method for handling."
		end

	end

end ; end
