namespace :ec2_instance_connect do
  desc 'Uploads local versions of linked files to the remote'
  task :upload_files do
    on release_roles(:all) do
      fetch(:linked_files).each do |file|
        unless test("[ -f #{File.join(shared_path, file)} ]")
          execute :mkdir, '-p', File.join(shared_path, File.dirname(file))
          upload! file, File.join(shared_path, file)
        end
      end
    end
  end
end
