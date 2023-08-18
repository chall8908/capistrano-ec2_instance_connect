# Capistrano::Ec2InstanceConnect

This Capistrano plugin allows for more secure connections to EC2 instances by
using a combination of AWS Session Manager and EC2 Instance Connect.

Using static, pre-shared keys is a security nightmare.  There are many ways to
circumvent this problem (e.g. cert-based SSH), but AWS provides its own,
built-in solutions as well.

Using Session Manager allows for connections to EC2 instances without opening
ports or sharing keys.  Unfortunately, Capistrano wasn't designed to work over
anything except SSH easily.  Enter EC2 Instance Connect.  Instance Connect works
over SSH like Capistrano expects, but requires extra setup in order to allow
authentication.

Using SSH's built-in Proxy Command functionality, we can get the best of both:
no open ports and short-lived keys.  Session Manager allows us to proxy the SSH
connection and EC2 Instance Connect allows us to send our keys to the server
prior to connection.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'capistrano-ec2_instance_connect', require: false
```

And then execute:

    $ bundle install

## Usage

Add the following to your Capfile:

``` ruby
require 'capistrano/ec2_instance_connect/connect'
install_plugin Capistrano::Ec2InstanceConnect::Connect
```

Change any `server` declarations to use your EC2 instance-id instead of IP.

``` ruby
# For example

server 'i-1234567890abcd', user: 'os-user', roles: %w{ web }
```

### Configuration

The plugin itself only exposes a single configuration option:

* `proxy_command`
  * This command is used by SSH to proxy your session.  You shouldn't need to
    change this as, by default, it's required to correctly proxy your connection
    to the EC2 instance.  By default, it's set to use the premade `AWS-StartSSHSession`
    SSM Document.
  * If set to `false`, disables proxying.  Useful if you're only using the Instance
    Connect portion of this plugin.

In order to use this plugin, you must have credentials configured for AWS using
one of the [automatic methods prescribed by the AWS SDK for Ruby v3](aws-sdk-ruby-v3).

### AWS Permissions

By default, your account will require the following permissions for the instances
you are attempting to connect to:

* ec2:DescribeInstanceStatus
  * Required for looking up instance availability zone
* ec2-instance-connect:SendSSHPublicKey
  * Required for actually sending the public key to the instance
  * For added security, this should be scoped to the specific user you will be
    connecting as
* ssm:StartSession
  * Must be able to use the AWS-StartSSHSession document
  * For added security, you should limit users to only this document

### Server Setup

In order for the above to function, your server must have the [SSM Agent](aws-ssm-agent)
and [EC2 Instance Connect](aws-ec2-instance-connect) packages installed.  EC2
Instances created from newer AMIs may have one or both of these utilities
pre-installed.

### Uploading Files

Since an SSH-less setup makes SCP and similar tools difficult to use, this plugin
provides a task `ec2_instance_connect:upload_files` which will upload local versions
of files in the `:linked_files` array to their appropriate places on the remote.

You can automate this process by adding the following to your `deploy.rb`:

``` ruby
before 'deploy:check:linked_files', 'ec2_instance_connect:upload_files'
```

This will automatically upload any missing linked files to all remotes on deploy.

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

[aws-sdk-ruby-v3]: https://docs.aws.amazon.com/sdk-for-ruby/v3/developer-guide/setup-config.html
[aws-ssm-agent]: https://docs.aws.amazon.com/systems-manager/latest/userguide/sysman-manual-agent-install.html
[aws-ec2-instance-connect]: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-connect-set-up.html#ec2-instance-connect-install
