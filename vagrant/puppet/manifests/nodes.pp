node default {

$csrterc_data = hiera('csrterc')
$default_hiera = $csrterc_data['default']

#####
#####
# baseline support
#####
#####
	
  # vagrant/puppet baseline support
  class { 'csrterc::baseline': }

  # enable monitoring
  -> class { 'monit': }

  # networking support
  -> class { 'csrterc::ssh': }
  -> class { 'csrterc::afp':
    server_name => 'development' ,
  }
  -> class { 'csrterc::smb':
    server_name => 'development' ,
    server_string => "Development Server" ,
  }

#####
#####
# setting up general web applications support
#####
#####

  # misc. developer tools
  -> class { 'csrterc::tools::editors': }
  -> class { 'csrterc::tools::versioning': }

  # database support
  -> class { 'csrterc::sqlite': }
  -> class { 'csrterc::mysql':
    # root_password => '' # not using a password on development servers
  }

  # language support
  -> class { 'csrterc::rvm':
    rvm_version => '1.25.17' ,
    default_ruby => 'ruby-2.0.0-p195' ,
    
    system_ruby_path => '/vagrant/puppet/' ,
    system_ruby_user => 'vagrant' ,
  }

  # webserver support
  -> class { 'csrterc::webserver::apache': }
  -> class { 'csrterc::webserver::apache::passenger':
    passenger_version => '4.0.37' , # latest version of passenger
    ruby_version => 'ruby-2.0.0-p195' , # passenger uses the default rvm ruby
  }

	# sites directory
  -> file { '/var/sites':
    ensure => "directory" ,
    mode => 0644 ,
  }

	# everybody loves imagemagick...
  -> package { 'imagemagick':
    ensure => 'present' ,
  }
  
  # lynx for reviewing locally
  -> package { 'lynx':
    ensure => 'present' ,
  }

#####
#####
# environment
#####
#####

  # developer-specific account
  -> csrterc::developer { 'dev':
    plaintext_password => $default_hiera['developer']['dev']['user']['plaintext_password'] ,
    hashed_password => $default_hiera['developer']['dev']['user']['hashed_password'] ,
    rvm_user => true ,
  }
  -> csrterc::developer::afp_share { 'dev': }
  -> csrterc::developer::smb_share { 'dev':
    password => $default_hiera['developer']['dev']['smb_share']['password']
  }

  -> rvm_alias { 'playground':
    ensure => present ,
    target_ruby => 'ruby-2.0.0-p195' , # using the default rvm ruby
    require => Rvm_system_ruby['ruby-2.0.0-p195'] ,
  }

  -> rvm_gemset { 'playground@playground':
    ensure => present ,
    require => Rvm_alias['playground'] ,
  }
  
  -> file { '/home/dev/sites':
    ensure => "directory" ,
    owner => 'dev' ,
    group => 'dev' ,
    mode => 0644 ,
    require => [
      Csrterc::Developer['dev'] ,
    ] ,
  }

  -> file { '/var/sites/playground':
    ensure => "directory" ,
    owner => 'dev' ,
    group => 'dev' ,
    mode => 0644 ,
    require => [
      File['/var/sites'] ,
    ] ,
  }
  -> file { '/home/dev/sites/playground':
    ensure => "link" ,
    target => "/var/sites/playground" ,
  }

  -> file { '/var/sites/playground/public':
    ensure => "directory" ,
    owner => 'dev' ,
    group => 'dev' ,
    mode => 0644 ,
    require => [
      File['/var/sites/playground'] ,
    ] ,
  }
	# do this on development, not on anything deployed
  -> file { '/var/sites/playground/public/system':
    ensure => "directory" ,
    owner => 'dev' ,
    group => 'dev' ,
    mode => 0644 ,
    require => [
      File['/var/sites/playground/public'] ,
    ] ,
  }
  -> csrterc::webserver::apache::passenger::vhost { 'playground':
    site_path => '/var/sites/playground' ,
    ruby_path => '/usr/local/rvm/wrappers/ruby-2.0.0-p195@playground/ruby' ,
    site_domain => 'playground.vm' ,
    site_root => '/var/sites/playground/public' ,
    site_group_name => 'dev' ,
    site_owner_name => 'dev' ,
    require => [
      File['/var/sites/playground'] ,
      Csrterc::Developer['dev'] ,
    ] ,
  }
	
	-> csrterc::webserver::afp_share { 'playground':
		user_name => 'dev' ,
		share_path => '/var/sites/playground'
	}
  -> csrterc::webserver::smb_share { 'playground':
		user_name => 'dev' ,
    password => $default_hiera['webserver']['smb_share']['password'] ,
		share_path => '/var/sites/playground' ,
  }

  -> csrterc::developer::mysql_db { 'dev':
  }
  -> csrterc::developer::mysql_db { 'playground_development':
  }
  -> csrterc::developer::mysql_db { 'playground_test':
  }

}
