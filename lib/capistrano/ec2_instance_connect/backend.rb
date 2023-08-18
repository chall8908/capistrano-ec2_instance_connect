require 'forwardable'
require 'aws-sdk-ec2'
require 'aws-sdk-ec2instanceconnect'
require 'sshkit/backends/netssh'
require 'capistrano/ec2_instance_connect/ssh_keypair'

module Capistrano
  module Ec2InstanceConnect
    class Backend < SSHKit::Backend::Netssh
      class UnableToSend < StandardError
        def initialize(request_id, host)
          super("Unable to send SSH key to host (#{host}) - #{request_id}")
        end
      end

      extend Forwardable

      # Copied from SSHKit::Backend::Netssh
      #
      # Note that this pool must be explicitly closed before Ruby exits to
      # ensure the underlying IO objects are properly cleaned up. We register an
      # at_exit handler to do this automatically, as long as Ruby is exiting
      # cleanly (i.e. without an exception).
      @pool = SSHKit::Backend::ConnectionPool.new
      at_exit { @pool.close_connections if @pool && !$ERROR_INFO }

      class << self
        def ec2_client
          @ec2_client ||= Aws::EC2::Client.new
        end

        def instance_connect_client
          @instance_connect_client ||= Aws::EC2InstanceConnect::Client.new
        end

        def ssh_key
          @ssh_key ||= keypair.private_key
        end

        def public_key
          @public_key ||= keypair.ssh_key_type + ' ' + keypair.public_key
        end

        private

        def keypair
          @keypair ||= SshKeypair.new
        end
      end

      def initialize(host, &block)
        @key_sent = false

        super
      end

      # Delegate these methods up to the class
      delegate [:ec2_client, :instance_connect_client, :ssh_key, :public_key] => self

      private

      def with_ssh(&block)
        ensure_key_sent!

        super
      end

      def ensure_key_sent!
        return if @key_sent

        resp = instance_connect_client.send_ssh_public_key(
          instance_id: @host.hostname,
          instance_os_user: @host.username,
          ssh_public_key: public_key
        )

        raise UnableToSend(resp.request_id, @host.hostname) unless resp.success

        @key_sent = true
      end
    end
  end
end
