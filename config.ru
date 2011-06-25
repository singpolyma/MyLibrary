#!/usr/bin/env rackup
# encoding: utf-8
#\ -E deployment

$: << File.dirname(__FILE__)

require 'rack/accept_media_types'
#require 'rack/supported_media_types'
require 'lib/path_info_fix'
require 'lib/subdirectory_routing'
require 'http_router'

use Rack::Reloader
use Rack::ContentLength
use PathInfoFix
use Rack::Static, :urls => ['/stylesheets'] # Serve static files if no real server is present
#use SubdirectoryRouting, $config['subdirectory'].to_s
#use Rack::SupportedMediaTypes, ['application/xhtml+xml', 'text/html', 'text/plain']

run HttpRouter.new {
	get('/?').head.to { |env|
		require 'controllers/index'
		IndexController.new(env).render
	}

	get('/search/?').head.to { |env|
		require 'controllers/search'
		SearchController.new(env).render
	}

	get('/edit/?').head.to { |env|
		require 'controllers/edit'
		EditController.new(env).render
	}

	post('/edit/?').to { |env|
		require 'controllers/edit'
		EditController.new(env).save
	}
}
