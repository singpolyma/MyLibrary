require 'open-uri'
require 'digest/sha1'

def cached_fetch(uri)
	path = File.join('cache', Digest::SHA1.hexdigest(uri))

	if File.exists?(path) && (Time.now - File.new(path).mtime) < 2000
		open(path).read
	else
		data = open(uri).read
		open(path, 'w') {|fh|
			fh.write(data)
		}
		data
	end
end
