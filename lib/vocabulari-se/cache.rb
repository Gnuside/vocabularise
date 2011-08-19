
require "base64"
require 'fileutils'

# FIXME: lock file

module VocabulariSe
	class DirectoryCache
		include Enumerable

		def initialize directory, timeout
			@root = File.expand_path directory
			@timeout = timeout
			if not File.exist? @root then
				FileUtils.mkdir_p @root
			end
		end


		def include? key
			path = "%s.info" % (_key_to_path key)
			if File.exist? path then
				created_at = nil
				File.open path, "r" do |fh|
					created_at = fh.gets.strip
				end
				diff = Time.now.to_i - created_at.to_i
				return (diff < @timeout)
			else
				return false
			end
		end

		# takes a HTTP::Message (response)
		def []= key, resp
			#puts "resp.body class = %s" % resp.body.class
			pp resp.body.inspect

			path = "%s.info" % (_key_to_path key)
			File.open path, "w" do |fh|
				fh.puts Time.now.to_i
			end

			path = "%s.data" % (_key_to_path key)
			File.open path, "w" do |fh|
				fh.write Marshal.dump( resp )
			end
		end

		# return a HTTP::Message::Body
		def [] key
			path = "%s.data" % (_key_to_path key)
			puts "CACHE PATH = %s" % path
			value = nil
			File.open path, "r" do |fh|
				value = Marshal.load fh.read
			end 
			resp = value
			#HTTP::Message.new_response value
			return resp
		end

		def each &blk
			d = Dir.new @root
			d.each do |x|
				next if x == '.' or x == '..'
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
