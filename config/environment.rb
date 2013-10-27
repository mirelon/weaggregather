# Load the rails application
require File.expand_path('../application', __FILE__)

Weaggregather::Application.config.threadsafe!

# Initialize the rails application
Weaggregather::Application.initialize!
