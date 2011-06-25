require 'controllers/application'
require 'lib/openlibrary_search'

class SearchController < ApplicationController
	def template
		open('views/search.haml').read
	end

	def scrape_data
		OpenLibrary.search(@req['q'])
	end
end
