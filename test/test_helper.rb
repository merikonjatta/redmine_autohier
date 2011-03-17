# Load the normal Rails helper
require File.expand_path(File.dirname(__FILE__) + '/../../../../test/test_helper')

# # Ensure that we are using the temporary fixture path
Engines::Testing.set_fixture_path

# We need factory girl
begin
  require 'factory_girl'
rescue LoadError => e
  puts "We need factory_girl. Please install it:\ngem install factory_girl"
  exit
end

# We want debugger
require 'ruby-debug'

# Refresh DB
WikiContent.destroy_all
WikiRedirect.destroy_all
WikiPage.destroy_all
Wiki.destroy_all
Project.destroy_all

require File.expand_path(File.dirname(__FILE__))+'/factories.rb'
