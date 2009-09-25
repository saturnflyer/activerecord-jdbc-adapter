require 'rubygems'
require 'rake'

require 'rake/testtask'
require 'rake/clean'
CLEAN.include 'derby*', 'test.db.*','test/reports', 'test.sqlite3','lib/**/*.jar','manifest.mf', '*.log'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "activerecord-jdbc-adapter"
    gem.summary = %Q{JDBC adapter for ActiveRecord, for use within JRuby on Rails.}
    gem.description = %Q{JDBC adapter for ActiveRecord, for use within JRuby on Rails.}
    gem.email = "nick@nicksieger.com, ola.bini@gmail.com"
    gem.homepage = "http://github.com/saturnflyer/activerecord-jdbc-adapter"
    gem.authors = ["Nick Sieger", "Ola Bini", "JRuby contributors"]
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

task :default => [:java_compile, :test]

task :filelist do
  puts FileList['pkg/**/*'].inspect
end

