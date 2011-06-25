require 'controllers/application'
require 'lib/datastore'

class EditController < ApplicationController
	def template
		open('views/edit.haml').read
	end

	def save
		DataStore.save_books(@req.POST.values)
		render(:info => 'Books saved!')
	end

	def books
		DataStore.get_books
	end
end
