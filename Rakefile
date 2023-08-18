require "bundler/gem_tasks"
require "rake/extensiontask"

Rake::ExtensionTask.new 'ssh_keypair' do |ext|
  ext.lib_dir = 'lib/capistrano/ec2_instance_connect'
end

task :default => :spec
