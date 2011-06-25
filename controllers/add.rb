require 'controllers/application'
require 'lib/datastore'
require 'lib/openlibrary_search'

class AddController < ApplicationController
	def template
		open('views/add.haml').read
	end

	def title
		'Add ' + super
	end

	def save
		DataStore.add_book(:isbn => @req.POST['isbn'])
		[303, {'Location' => '/edit/'}, '']
	end

	def scrape_data
		OpenLibrary.search(@req['q'])
	end
end
