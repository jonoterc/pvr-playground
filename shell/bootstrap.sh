#!/bin/bash

# Directory in which librarian-puppet should manage its modules directory
PUPPET_DIR=/vagrant/puppet
PUPPET_HIERA_DIR=/vagrant/puppet/hiera
APT_GET=/usr/bin/apt-get
YUM=/usr/sbin/yum
GEM=/opt/ruby/bin/gem
PUPPET=/opt/ruby/bin/puppet
LIBRARIAN_PUPPET=/opt/ruby/bin/librarian-puppet

echo 'Shell provisioner: starting'

echo 'Shell provisioner: checking for system RVM'
if [ -s '/usr/local/rvm/scripts/rvm' ]; then

	type rvm | head -1

	# Load RVM into a shell session *as a function*
  source '/usr/local/rvm/scripts/rvm'

	echo 'Shell provisioner: system RVM found; switching to puppet-specific ruby at /opt/ruby/bin'
	rvm use system

else

  echo "Shell provisioner: system RVM not found; defaulting to puppet-specific ruby at /opt/ruby/bin"

fi

echo 'Shell provisioner: ensure that latest repository data is used'

if [ -x $YUM ]; then
	echo 'Shell provisioner: have not implemented repo updating for YUM'
	# ???? yum clean all
	# ???? yum makecache
elif [ -x $APT_GET ]; then
	apt-get -y update && touch /tmp/apt-get-updated
else
	echo "Shell provisioner: no package installer available. You may need to install some packages manually."
fi

echo 'Shell provisioner: ensure that /etc/shadow support for puppet is provided'
if [ `$GEM query --local | grep ruby-shadow | wc -l` -eq 0 ]; then
	echo 'Shell provisioner: installing ruby-shadow gem'
  $GEM install ruby-shadow --no-rdoc --no-ri --version='2.2.0'
else
	echo 'Shell provisioner: ruby-shadow gem already installed'
fi

echo 'Shell provisioner: ensure that augeas support for puppet is provided'
if [ `$GEM query --local | grep ruby-augeas | wc -l` -eq 0 ]; then
	if [ -x $YUM ]; then
		yum -q -y install pkg-config
		yum -q -y install libaugeas-dev
	elif [ -x $APT_GET ]; then
		apt-get -q -y install pkg-config
		apt-get -q -y install libaugeas-dev
	else
		echo "Shell provisioner: no package installer available. You may need to install dependencies for ruby-augeas manually."
	fi
	echo 'Shell provisioner: installing ruby-augeas gem'
  $GEM install ruby-augeas  --no-rdoc --no-ri --version='0.5.0'
else
	echo 'Shell provisioner: ruby-augeas gem already installed'
fi

echo 'Shell provisioner: ensure that git is installed'
# NB: librarian-puppet might need git installed. If it is not already installed
# in your basebox, this will manually install it at this point using apt or yum
GIT=/usr/bin/git
if [ ! -x $GIT ]; then
	echo 'Shell provisioner: installing git'
	if [ -x $YUM ]; then
		yum -q -y install git
	elif [ -x $APT_GET ]; then
		apt-get -q -y install git
	else
		echo "Shell provisioner: no package installer available. You may need to install git manually."
	fi
else
	echo "Shell provisioner: git already installed."
fi

echo 'Shell provisioner: ensure the librarian-puppet is installed and modules are updated'
if [ `$GEM query --local | grep librarian-puppet | wc -l` -eq 0 ]; then
  $GEM install librarian-puppet --no-rdoc --no-ri --version='0.9.12'
  cd $PUPPET_DIR && $LIBRARIAN_PUPPET install --clean
else
	echo 'Shell provisioner: updating puppet librarian settings'
  cd $PUPPET_DIR && $LIBRARIAN_PUPPET update
	# echo 'Shell provisioner: skipping librarian-puppet module update'
fi

echo 'Shell provisioner: ensure present Hiera configuration'
if [ ! -e $PUPPET_HIERA_DIR/common.yaml ]; then
  echo 'Shell provisioner: copying default Hiera configuration'
  sudo cp $PUPPET_HIERA_DIR/common.yaml.example $PUPPET_HIERA_DIR/common.yaml
else
  echo 'Shell provisioner: Hiera configuration is in place'
fi

echo 'Shell provisioner: run puppet'
cd $PUPPET_DIR && sudo $PUPPET apply -v --modulepath=$PUPPET_DIR/modules/ --confdir=$PUPPET_DIR/ $PUPPET_DIR/manifests/main.pp #--graph

echo 'Shell provisioner: completed'