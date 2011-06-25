require 'lib/cached_fetch'
require 'lib/util'
require 'json'
require 'time'

module DataStore
	module_function

	def get_books
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

		books.sort {|a,b|
			if a[:tags].first.to_s == b[:tags].first.to_s
				a[:title] <=> b[:title]
			else
				a[:tags].first.to_s <=> b[:tags].first.to_s
			end
		}
	end

	def save_books(books)
		books = symbolize_keys(books)
		open('data/books', 'w') do |fh|
			books.each do |data|
				add_book_rec(fh, data)
			end
		end
	end

	def add_book(book)
		open('data/books', 'a') do |fh|
			add_book_rec(fh, book)
		end
	end

	def add_book_rec(fh, data)
		fh.write "#{data[:isbn]}\t#{data[:rating]}"
		fh.write "\t#{data[:dtadded].to_s == '' ? '' : Time.parse(data[:dtadded]).to_i}"
		fh.write "\t#{data[:dtread].to_s == '' ? '' : Time.parse(data[:dtread]).to_i}"
		fh.write "\t#{data[:tags].to_s.split(/,/).map{|i| i.strip}.join(',')}"
		fh.write "\n"
	end
end
