# Release Notes

## Current

## 0.2.3

* Update required version of `aws-sdk-ec2instanceconnect`

## 0.2.2

* Fix libssh configuration for multi-platform support

## 0.2.1

* Fix target path used by extconf

## 0.2.0

* Integrate with libssh for generating ed25519 keypairs
* Modify internal APIs to use new keypair interface

## 0.1.3

* Add validator for ssh_options that prompt on potentially invalid setups.

## 0.1.2

* Add task for uploading linked files that can be made automatic

## 0.1.1

* Fix typo in RSA key size to 4096

## 0.1.0

* First working version
  * This version handles setting up the environment and options needed to properly
    connect via EC2 Instance Connect with SSM acting as an SSH tunnel.
