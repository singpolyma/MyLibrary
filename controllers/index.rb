require 'controllers/application'
require 'lib/books'

class IndexController < ApplicationController
	include Books

	def template
		open('views/view.haml').read
	end
end
