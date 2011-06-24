require 'controllers/application'
require 'lib/books'

class EditController < ApplicationController
	include Books

	def template
		open('views/edit.haml').read
	end

	def save
		open('data/books', 'w') do |fh|
			@req.POST.each do |isbn, data|
				fh.write "#{isbn}\t#{data['rating']}"
				fh.write "\t#{data['dtadded'].to_s == '' ? '' : Time.parse(data['dtadded']).to_i}"
				fh.write "\t#{data['dtread'].to_s == '' ? '' : Time.parse(data['dtread']).to_i}"
				fh.write "\t#{data['tags'].split(/,/).map{|i| i.strip}.join(',')}"
				fh.write "\n"
			end
		end

		render(:info => 'Books saved!')
	end
end
