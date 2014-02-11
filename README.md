A vagrant+puppet-based setup to provide an Ubuntu-based Ruby web-app development environment.

## Requirements:
* [VirtualBox version 4.30](https://www.virtualbox.org/wiki/Download_Old_Builds)
* [Vagrant](https://vagrantup.com)
  * after installing vagrant you will need to install the hostmanager plugin:  

        > vagrant plugin install vagrant-hostmanager

# Getting Started

## Launching the Environment

Download this repository, open up the project in your terminal and start the first-time provisioning as follows:

    > cd vagrant/
    > vagrant up

This will provision the environment (a 5-10 minutes process) as follows:

### Base Box configuration
Your base box (which is automatically downloaded by Vagrant) provides the following:

* Ubuntu 12.04 LTS virtual machine with support for VirtualBox 4.3.0
* pre-installed Puppet 3.3.1 support
* (up to) 32GB of space

### Puppet-based configuration
Upon first boot, vagrant will provision this base box via puppet,
providing the following enhancements:

* Puppet extensions, including
  * libshadow-based password configuration
  * augeaus-based configuration management
  * librarian-puppet-based module installation
* Apache
* Mysql
* Sqlite
* Imagemagick
* Smbd (windows-based) networking
* Afpd (apple-based) networking
* Ruby Version Manager, including:
  * "playground"-aliased configurations for Ruby 2.x and a fresh gemset
  * Passenger installed and configured to work with Apache ("ready for Rails")
* virtual host "playground.vm"
  *  domain is auto-configured on your Host system (to localhost)
* user "dev" with password "playground"
  * override these passwords via the "puppet/hiera/common.yaml" configuration
* pre-created personal and MySQL databases, "dev", "playground_development" and "playground_test"

Also, vagrant is configured with 2 synced directories between the Guest and Host systems:
* the first is this project's "vagrant" directory, which maps to "/vagrant/" on the Guest system
* the second is this projects' "working" directory, which maps to "/var/sites/playground" on the Guest system

## Logging in and Setting Up

### Set up a Working Directory

As soon as the initial provisioning is completed, there are a few quick steps to enable the synchronized working directory (in addition to the synchronized directory for vagrant/puppet configuration):

1. create a directory named "working" at the top level of the project  (i.e. 

        >  mkdir working

2. edit the Vagrantfile (located under "vagrant/") - un-comment the line that begins "config.vm.synced_folder '../working', '/var/sites/playground'".  This will activate the working folder (which requires/is owned by the the newly-created "dev" user
3. Next, reload vagrant to make these changes take effect:

        >  vagrant reload

### Log-in

Once the vagrant environment has reloaded, log-in, which will drop you into the vagrant user's home directory:

    > vagrant ssh  

Next, log-in as the user you'll be developing as, "dev":

    > su -l dev  

You'll be prompted for the dev user's password to login, which will drop you into that user's home directory.

### Set up Rails 4

Now you'll want to set up Rails 4:

    > cd /var/sites  
    > rvm use playground@playground # use the rvm ruby and gemset pre-created for the "playground" app
    > gem install rails --version=4.0.2 # or your preferred Rails version  
    > rails new playground # installs a new Rails 4 app under /var/sites/playground
    > cd playground  

Vagrant maps "/var/sites/playground" directory maps to the "working" directory, so you can begin modifiying this rails app skeleton from your Host system.  Your first step should be to edit the Gemfile (in the new Rails app root) and uncomment the "therubyracecar" gem (this provides a Javascript engine, which is required by Rails 4's asset pipeline)

    > bundle install # update bundled gems to include therubyracecar
    > touch tmp/restart.txt # restart the server

Finally, verify that Rails 4 is working in a text-mode browser:

    > lynx http://playground.vm # view the pristine Rails 4 app main page in a text-mode web browser
    
You can also access this site from a browser on your Host system by appending the forwarded port number (for web traffic on port 80).  Vagrant displays forwarded port info when starting/reloading a VM, and this info can also be looked up via Virtualbox network settings for the running VM.

You're all set to start development; have fun!
