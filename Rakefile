
require 'rake'
require 'rubygems'
require 'bundler/setup'
require 'rspec/core/rake_task'

desc 'Default: run specs.'
task :default => [:spec]

task :archive do
	date = `date +"%Y%m%d"`.strip
	name = "vocabulari-se.%s" % date
	sh "git archive --prefix #{name}/ -o ../#{name}.tar master"
end

desc "Run specs"
RSpec::Core::RakeTask.new(:spec) do |t|
	#t.libs << "test"
	#t.test_files = FileList['test/*_test.rb']
	#t.verbose = true
	t.pattern = FileList['spec/**/*_spec.rb']
	t.verbose = true
	t.ruby_opts = "-Ilib"
	t.rspec_opts = "--color --format documentation"
end


desc "Run specs"
RSpec::Core::RakeTask.new(:coverage) do |t|
	t.pattern = FileList['spec/**/*_spec.rb']
	t.rcov = true
	t.rcov_opts = [
		'--exclude', 'spec' 
	]
end

