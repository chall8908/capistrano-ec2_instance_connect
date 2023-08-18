require_relative 'lib/capistrano/ec2_instance_connect/version'

Gem::Specification.new do |spec|
  spec.name          = "capistrano-ec2_instance_connect"
  spec.version       = Capistrano::Ec2InstanceConnect::VERSION
  spec.authors       = ["Chris Hall"]
  spec.email         = ["chall8908@gmail.com"]

  spec.summary       = %q{Adds functionality to Capistrano to allow it to connect via EC2 Instance Connect}
  spec.description   = %q{Adds functionality to Capistrano to allow it to connect via EC2 Instance Connect}
  spec.homepage      = ""
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = spec.homepage

  spec.extensions << 'ext/ssh_keypair/extconf.rb'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.require_paths = ["lib"]

  spec.add_dependency 'capistrano', '~> 3.16'
  spec.add_dependency 'aws-sdk-ec2', '~> 1.17'
  spec.add_dependency 'aws-sdk-ec2instanceconnect', '~> 1.22'

  # Required for Net::SSH to be able to understand ed25519 keys
  spec.add_dependency 'ed25519', '~> 1.2'
  spec.add_dependency 'bcrypt_pbkdf', '~> 1.0'

  spec.add_development_dependency 'rake-compiler'
end
