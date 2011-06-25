require 'controllers/application'
require 'lib/datastore'

class IndexController < ApplicationController
	def template
		open('views/view.haml').read
	end

	def books
		DataStore.get_books
	end
end
