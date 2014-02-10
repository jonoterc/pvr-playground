A vagrant+puppet-based setup to provide an Ubuntu-based Ruby web-app development environment.

## Requirements:
* [VirtualBox version 4.30](https://www.virtualbox.org/wiki/Download_Old_Builds)
* [Vagrant](https://vagrantup.com)
  * after installing vagrant you will need to install the hostmanager plugin:  
  * \> vagrant plugin install vagrant-hostmanager

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
* Mysql
* Sqlite
* Imagemagick
* Smbd (windows-based) networking
* Afpd (apple-based) networking
* Ruby Version Manager 1.2.7, including:
  * "playground"-aliased installation with Ruby 2.0 and Rails 4.0
* virtual host "playground.vm"
* user "dev" with password "playground"
  * overide these passwords with the "puppet/hiera/common.yaml" configuration
* pre-created personal MySQL database, "dev"
* pre-created project MySQL databases, "playground_development" and "playground_test"

Also, vagrant is configured with 2 synced directories:
* the first is this project's "vagrant" directory, which maps to "/vagrant/" on the guest system
* the second is this projects' "working" directory, which maps to "/var/sites/playground" on the guest system

## Logging in and Setting Up

### Fix Working Directory Permissions

As foon as the initial provisioning is completed, a quick edit is required within "vagrant/Vagrantfile"; find the line that begins "config.vm.synced_folder '../working'" and uncomment the "owner" configuration further to the right on the same line.  This will establish the newly-created "dev" user as the owner of the working directory contents.  Next, reload vagrant to make these changes take effect:

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
    > rails new playground # installs a new Rails 4 app under /var/sites/  playground
    > cd playground  

Vagrant maps "/var/sites/playground" directory maps to the "working" directory, so you can begin modifiying this rails app skeleton immediately.  
Your first step should be to edit the Gemfile (in the new Rails app root) and uncomment the "therubyracecar" gem (this provides a Javascript engine, which is required by Rails 4's asset pipeline)

    > bundle install # update bundled gems
    > touch tmp/restart.txt # restart the server

Finally, verify that Rails 4 is working in a text-mode browser:

    > lynx http://playground.vm # view the pristine Rails 4 app in a text-mode web browser
    
You can also access this site from a browser on your host OS with nearly the same URL - you'll have to append the forwarded port number (whatever vagrant forwards port 80 to at startup; this can also be looked up via Virtualbox network settings on the running vagrant image).

OK, you're all set to start development; have fun!