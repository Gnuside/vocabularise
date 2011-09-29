
module VocabulariSe

	class RequestManager

		def new config
		end

		def in_queue? action, intag
		end

		def in_cache? action, intag
		end

		def queue action, intag
		end

		def cache action, intag, result
		end

		def unqueue action, intag
		end

		def uncache action, intag
		end

	end
end
