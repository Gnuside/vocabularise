
require "base64"
require 'fileutils'

module VocabulariSe
	class DirectoryCache
		include Enumerable

		def initialize directory, timeout
			@root = File.expand_path directory
			if not File.exist? @root then
				FileUtils.mkdir_p @root
			end
		end


		def include? key
			path = _key_to_path key
			return (File.exist? path)
		end

		# takes a HTTP::Message (response)
		def []= key, resp
			path = _key_to_path key
			File.open path, "w" do |fh|
				fh.puts resp.body.content
			end
		end

		# return a HTTP::Message::Body
		def [] key
			path = _key_to_path key
			value = nil
			File.open path, "r" do |fh|
				value = fh.gets
			end
			resp = HTTP::Message.new_response value
			return resp
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
			path =  (File.join @root, Base64.encode64(key)).strip
			return path
		end
	end
end
