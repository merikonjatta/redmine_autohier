require 'redmine'
require 'wiki_page_patch'
require 'wiki_patch'

Redmine::Plugin.register :redmine_automatic_hierarchy do
  name 'Redmine Automatic Hierarchy plugin'
  author 'Shinya Maeyama'
  description <<HERE
This plugin:\n
does this\n
does that\n
and does this too\n
HERE
  version '0.0.1'
end
