require_relative 'boot'

require 'rails/all'

Bundler.require(*Rails.groups)

module InventoryControlSystem
  class Application < Rails::Application
    config.load_defaults 5.2

    config.log_formatter = proc do |severity, datetime, progname, message|
      "[#{datetime.strftime('%Y-%m-%d %H:%M:%S')}] #{severity}: #{message}\n"
    end


     # Load environment variables from .env file
    Dotenv::Railtie.load
    config.colorize_logging = true
  end
end
