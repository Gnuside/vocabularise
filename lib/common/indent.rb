
require 'singleton'

class Indent

	include Singleton

	INDENT_SIZE_DEFAULT=4

	class IndentError < RuntimeError ; end

	def initialize size=INDENT_SIZE_DEFAULT
		@size = size
		@indent = 0
	end

	def less step=1
		@indent -= step
		raise IndentError, "Unable to indent less than zero" if @indent < 0
	end

	def more step=1
		@indent += step
	end

	def str
		" " * @size * @indent
	end

	def to_s
		str
	end

	def self.more
		self.instance.more
	end

	def self.less
		self.instance.less
	end

	def self.to_s
		self.instance.to_s
	end

	def self.str
		self.instance.str
	end
end
