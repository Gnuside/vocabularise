
require 'bundler/setup'

require 'rake'
require 'rspec/core/rake_task'

desc 'Default: run specs.'
task :default => [:spec]

task :archive do
	date = `date +"%Y%m%d"`.strip
	name = "vocabulari-se.%s" % date
	sh "git archive --prefix #{name}/ -o ../#{name}.tar master"
end

desc "Run background jobs"
task :work do
	DataMapper::Logger.new($stdout, :info)
	Delayed::Worker.backend = :data_mapper
	Delayed::Job.auto_migrate!
	Delayed::Worker.new.start
end
desc "Run specs"
RSpec::Core::RakeTask.new(:spec) do |t|
	#t.libs << "test"
	#t.test_files = FileList['test/*_test.rb']
	#t.verbose = true
	list =  FileList['spec/**/*_spec.rb'].to_a
	list.reject!{ |arg| arg =~ /^spec\/obsolete/ }
	t.pattern = list
	t.verbose = true
	t.ruby_opts = "-Ilib"
	t.rspec_opts = "--color --format documentation"
end


desc "Run specs"
RSpec::Core::RakeTask.new(:coverage) do |t|
	list =  FileList['spec/**/*_spec.rb'].to_a
	list.reject!{ |arg| arg =~ /^spec\/obsolete/ }
	t.pattern = list
	t.rcov = true
	t.rcov_opts = [
		'--exclude', 'spec' 
	]
end

