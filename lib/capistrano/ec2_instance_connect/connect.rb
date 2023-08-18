require 'capistrano/plugin'
require 'capistrano/ec2_instance_connect/backend'

module Capistrano
  module Ec2InstanceConnect
    class AbortConnection < StandardError
      def initialize(message='Connection attempt aborted')
        super(message)
      end
    end

    class Connect < Capistrano::Plugin

      # Abusing Capistrano to set some SSHKit options
      def set_defaults
        set_if_empty(:proxy_command, %{sh -c "aws ssm start-session --target %h --document-name AWS-StartSSHSession --parameters 'portNumber=%p'"})

        set(:sshkit_backend, Backend)

        # Forcibly unset any previously set keys and provide the key data produced
        # by our Backend instead
        proxy_command = fetch(:proxy_command)
        set(:ssh_options,
            (fetch(:ssh_options) || {}).merge(
              keys: [],
              key_data: [Backend.ssh_key],
              keys_only: true,
              proxy: (Net::SSH::Proxy::Command.new(proxy_command) if proxy_command)
            )
           )

        validate(:ssh_options) do |_, value|
          proxy_command = fetch(:proxy_command)
          next unless proxy_command

          unless value[:proxy] == proxy_command
            warn 'ssh_options may not be set correctly.  Proxy command is unset so connecting may not work.'

            if fetch(:continue_on_bad_ssh_options)[0] == 'n'
              raise Capistrano::Ec2InstanceConnect::AbortConnection
            end
          end
        end

        ask(:continue_on_bad_ssh_options, 'n', prompt: "Do you want to continue? [y/n]")
      end

      def define_tasks
        eval_rakefile File.expand_path('tasks/upload.rake', __dir__)
      end
    end
  end
end
