#!/usr/bin/env rackup
# encoding: utf-8
#\ -E deployment

# load paths relative to document root
$: << ::File.dirname(__FILE__)
::Dir.chdir(::File.dirname(__FILE__))

# load config file
require 'yaml'
$config = YAML::load_file('config.yaml')

require 'rack/auth/digest/md5'
require 'rack/accept_media_types'
#require 'rack/supported_media_types'
require 'lib/path_info_fix'
require 'lib/subdirectory_routing'
require 'lib/util'
require 'http_router'

use Rack::Reloader
use Rack::ContentLength
use Rack::ShowExceptions
use PathInfoFix
use Rack::Static, :urls => ['/stylesheets'] # Serve static files if no real server is present
use SubdirectoryRouting, $config['subdirectory'].to_s
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
		with_auth(env) {|env|
			require 'controllers/edit'
			EditController.new(env).render
		}
	}

	post('/edit/?').to { |env|
		with_auth(env) {
			require 'controllers/edit'
			EditController.new(env).save
		}
	}

	get('/add/?').head.to { |env|
	# Digest auth is currently broken for query strings
	# So, whatever, the search results are public, just protect the save endpoint
	#	with_auth(env) {
			require 'controllers/add'
			AddController.new(env).render
	#	}
	}

	post('/add/?').to { |env|
		# Auth requirement is inside, only if not a recommendation
		require 'controllers/add'
		AddController.new(env).save
	}
}
