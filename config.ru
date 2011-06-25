#!/usr/bin/env rackup
# encoding: utf-8
#\ -E deployment

# load paths relative to document root
$: << ::File.dirname(__FILE__)
::Dir.chdir(::File.dirname(__FILE__))

# load config file
require 'yaml'
$config = YAML::load_file('config.yaml')

require 'rack/accept_media_types'
#require 'rack/supported_media_types'
require 'lib/path_info_fix'
require 'lib/subdirectory_routing'
require 'http_router'

use Rack::Reloader
use Rack::ContentLength
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
		protected = lambda {|env|
			require 'controllers/edit'
			EditController.new(env).render
		}

		require 'rack/auth/digest/md5'
		auth = ::Rack::Auth::Digest::MD5.new(protected, 'mylibrary') {|u| $config[:password] }
		auth.opaque = $$.to_s
		auth.call(env)
	}

	post('/edit/?').to { |env|
		require 'controllers/edit'
		EditController.new(env).save
	}
}
