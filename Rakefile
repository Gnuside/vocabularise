
require 'rake'
require 'rubygems'
require 'bundler/setup'
require 'rspec/core/rake_task'


task :default => [:spec]

task :archive do
	date = `date +"%Y%m%d"`.strip
	name = "vocabulari-se.%s" % date
	sh "git archive --prefix #{name}/ -o ../#{name}.tar master"
end

desc "Test behaviour"
RSpec::Core::RakeTask.new(:spec) do |t|
	#t.libs << "test"
	#t.test_files = FileList['test/*_test.rb']
	#t.verbose = true
	t.pattern = FileList['test/*_spec.rb']
	t.verbose = true
	t.ruby_opts = "-Ilib"
end

