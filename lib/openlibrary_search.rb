require 'lib/cached_fetch'
require 'lib/util'
require 'lib/isbn'
require 'json'
require 'nokogiri'

module OpenLibrary
	module_function

	def search(q)
		page = cached_fetch('http://openlibrary.org/search?q=' + u(q))
		doc = Nokogiri::parse(page)
		doc.search('#searchResults li')[0,10].map do |el|
			work_id  = an(el.at('.booktitle a')).attributes['href'].to_s.split('/')
			work_id.pop
			work_id = work_id.pop

			editions = JSON::parse(cached_fetch(
				'http://openlibrary.org/query.json?type=/type/edition&works=/works/'+u(work_id)+'&isbn_13=&isbn_10=&limit=1000'
			)).map do |ed|
				if ed['isbn_13']
					ed['isbn_13'].first
				elsif ed['isbn_10']
					ISBN::isbn10_to_isbn13(ed['isbn_10'].first)
				end
			end.compact

			next if editions.length < 1

			{
				:title    => an(el.at('.booktitle')).text.strip,
				:author   => an(el.at('.bookauthor')).text.strip,
				:url      => 'http://openlibrary.org'+an(el.at('.booktitle a')).attributes['href'].to_s,
				:editions => editions
			}
		end.compact
	end
end
