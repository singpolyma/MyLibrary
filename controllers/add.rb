require 'controllers/application'
require 'lib/datastore'
require 'lib/openlibrary_search'
require 'lib/util'

class AddController < ApplicationController
	def template
		open('views/add.haml').read
	end

	def title
		'Add ' + super
	end

	def save
		if recommender
			DataStore.add_recommend(:isbn => @req.POST['isbn'], :recommender => @req.POST['recommender'])
			[303, {'Location' => '/'}, '']
		else
			with_auth(@env) { |env|
				DataStore.add_book(:isbn => @req.POST['isbn'])
				[303, {'Location' => '/edit/'}, '']
			}
		end
	end

	def recommender
		@req['recommender']
	end

	def scrape_data
		OpenLibrary.search(@req['q'])
	end
end
