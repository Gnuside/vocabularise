
task :default => [:archive]

task :archive do
	date = `date +"%Y%m%d"`.strip
	name = "vocabulari-se.%s" % date
	sh "git archive --prefix #{name}/ -o ../#{name}.tar master"
end
