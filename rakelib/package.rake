MANIFEST = FileList["History.txt", "Manifest.txt", "README.txt", 
  "Rakefile", "LICENSE.txt", "lib/**/*.rb", "lib/jdbc_adapter/jdbc_adapter_internal.jar", "test/**/*.rb",
   "lib/**/*.rake", "src/**/*.java"]

file "Manifest.txt" => :manifest
task :manifest do
  File.open("Manifest.txt", "w") {|f| MANIFEST.each {|n| f << "#{n}\n"} }
end
Rake::Task['manifest'].invoke # Always regen manifest, so Hoe has up-to-date list of files

require File.dirname(__FILE__) + "/../lib/jdbc_adapter/version"
begin
  require 'hoe'
  Hoe.new("activerecord-jdbc-adapter", JdbcAdapter::Version::VERSION) do |p|
    p.rubyforge_name = "jruby-extras"
    p.url = "http://jruby-extras.rubyforge.org/activerecord-jdbc-adapter"
    p.author = "Nick Sieger, Ola Bini and JRuby contributors"
    p.email = "nick@nicksieger.com, ola.bini@gmail.com"
    p.summary = "JDBC adapter for ActiveRecord, for use within JRuby on Rails."
    p.changes = p.paragraphs_of('History.txt', 0..1).join("\n\n")
    p.description = p.paragraphs_of('README.txt', 0...1).join("\n\n")
  end.spec.dependencies.delete_if { |dep| dep.name == "hoe" }
rescue LoadError
  puts "You really need Hoe installed to be able to package this gem"
rescue => e
  puts "ignoring error while loading hoe: #{e.to_s}"
end

def rake(*args)
  ruby "-S", "rake", *args
end

%w(test package install_gem release clean).each do |task|
  desc "Run rake #{task} on all available adapters and drivers"
  task "all:#{task}" => task
end

(Dir["drivers/*/Rakefile"] + Dir["adapters/*/Rakefile"]).each do |rakefile|
  dir = File.dirname(rakefile)
  prefix = dir.sub(%r{/}, ':')
  tasks = %w(package install_gem debug_gem clean)
  tasks << "test" if File.directory?(File.join(dir, "test"))
  tasks.each do |task|
    desc "Run rake #{task} on #{dir}"
    task "#{prefix}:#{task}" do
      Dir.chdir(dir) do
        rake task
      end
    end
    task "#{File.dirname(dir)}:#{task}" => "#{prefix}:#{task}"
    task "all:#{task}" => "#{prefix}:#{task}"
  end
  desc "Run rake release on #{dir}"
  task "#{prefix}:release" do
    Dir.chdir(dir) do
      version = nil
      if dir =~ /adapters/
        version = ENV['VERSION']
      else
        Dir["lib/**/*.rb"].each do |file|
          version ||= File.open(file) {|f| f.read =~ /VERSION = "([^"]+)"/ && $1}
        end
      end
      rake "release", "VERSION=#{version}"
    end
  end
  # Only release adapters synchronously with main release. Drivers are versioned
  # according to their JDBC driver versions.
  if dir =~ /adapters/
    task "adapters:release" => "#{prefix}:release"
    task "all:release" => "#{prefix}:release"
  end
end
