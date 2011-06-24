require 'lib/cached_fetch'
require 'lib/util'
require 'json'
require 'time'

module Books
	def books
		books = open('data/books').read.split(/\n/).map do |line|
			line = line.split(/\t/)
			line[1] = line[1].to_s == '' ? nil : line[1].to_i
			line[2] = line[2].to_s == '' ? nil : Time.at(line[2].to_i)
			line[3] = line[3].to_s == '' ? nil : Time.at(line[3].to_i)
			{
				:isbn    => line[0],
				:rating  => line[1],
				:dtadded => line[2],
				:dtread  => line[3],
				:tags    => line[4].to_s.split(/,/)
			}
		end

		books.each_slice(40) do |slice|
			uri = 'http://openlibrary.org/api/books?format=json&jscmd=data&bibkeys=' + slice.map {|b| 'ISBN:'+b[:isbn]}.join(',')
			json = cached_fetch(uri)
			JSON::parse(json).each do |k, v|
				books.each do |b|
					b.merge!(symbolize_keys(v)) if 'ISBN:'+b[:isbn] == k
				end
			end
		end

		books
	end
end
