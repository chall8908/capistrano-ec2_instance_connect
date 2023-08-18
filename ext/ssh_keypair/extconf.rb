require 'mkmf'

append_cflags(['-Wall'])
pkg_config('libssh')

unless find_library('ssh', 'ssh_pki_generate')
  abort 'libssh is missing.  Please install libssh and development headers'
end


create_makefile('capistrano/ec2_instance_connect/ssh_keypair')
