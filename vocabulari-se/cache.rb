
require "base64"
require 'fileutils'

module VocabulariSe
	class DirectoryCache
		include Enumerable

		def initialize directory
			@root = File.expand_path directory
			if not File.exist? @root then
				FileUtils.mkdir_p @root
			end
		end


		def include? key
			path = _key_to_path key
			return (File.exist? path)
		end

		def []= key, value
			path = _key_to_path key
			File.open path, "w" do |fh|
				fh.puts value	
			end
		end

		def each &blk
			d = Dir.new @root
			d.each do |x|
				next if x == '.'
				next if x == '..'
				yield x
			end
		end

		private

		def _key_to_path key
			path =  File.join @root, Base64.encode64(key)
			return path
		end
	end
end
