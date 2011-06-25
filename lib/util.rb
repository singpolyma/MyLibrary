def u(s)
	s.to_s.gsub(/([^a-zA-Z0-9_.-]+)/n) {
		'%'+$1.unpack('H2'*$1.bytesize).join('%').upcase
	}
end

# from http://snippets.dzone.com/posts/show/11121
def symbolize_keys(arg)
	case arg
		when Array
			arg.map { |elem| symbolize_keys(elem) }
		when Hash
			Hash[
				arg.map { |key, value|
					k = key.is_a?(String) ? key.to_sym : key
					v = symbolize_keys(value)
					[k,v]
				}]
		else
			arg
	end
end

def with_auth(env, &protected)
	auth = ::Rack::Auth::Digest::MD5.new(protected, 'MyLibrary') {|u| $config[:password] }
	auth.opaque = $$.to_s
	auth.call(env)
end

class AlmostNil
	def method_missing(*args)
		self
	end

	def to_s
		''
	end

	def inspect
		'AlmostNil'
	end

	def nil?
		true
	end
end

def an(a)
	if a.nil?
		AlmostNil.new
	else
		a
	end
end
