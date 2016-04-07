#!/usr/bin/env bash
# set the hieradata version here
init_hiera_ver="0.1"


# Set custom facter facts
set_facter() {
  export FACTER_$1="${2}"
  if [[ ! -d /etc/facter ]]; then
    mkdir -p /etc/facter/facts.d
  fi
  echo "${1}=${2}" > /etc/facter/facts.d/"${1}".txt
  chmod -R 600 /etc/facter
  cat /etc/facter/facts.d/"${1}".txt
}
# Parse the commmand line arguments
while [[ -n "${1}" ]] ; do
  case "${1}" in
  --role|-r)
    set_facter init_role "${2}"
    shift
    ;;
  --environment|-e)
    set_facter init_env "${2}"
    shift
    ;;

  *)
    echo "Unknown argument: ${1}"
    exit
    ;;
  esac
  shift
done

set -x
PATH=$PATH:/usr/local/bin
export PATH
# DNS seems to fail occasionally - so insert entry in hosts file
echo '192.30.252.131   github.com' >> /etc/hosts
echo '54.186.104.15 api.rubygems.org' >> /etc/hosts
# kill the firewall service
systemctl stop firewalld
systemctl disable firewalld
#setup puppet environment with dependencies from Puppetfile
if [ `uname -s` == "Linux" ]; then
  if [ -x /usr/bin/apt-get ]; then
    apt-get update -qq
    apt-get install -y ruby ruby-dev build-essential git
  fi
  if [ -x /usr/bin/yum ]; then
    yum -y update
    yum -y install ruby ruby-devel git
    # should we need the same as build-essential
    # yum -y install gcc gcc-c++ kernel-devel
  fi
fi
gem install bundler
cd /vagrant
bundle install

# TODO get the hiera data
pushd /etc
git clone -b "${init_hiera_ver}" git@bitbucket.com:neil_millard/hieradata_odoo.git "hieradata"
# Exit if the clone fails
if [[ ! -d "hieradata" ]]; then
  echo "Failed to clone git@bitbucket.com:neil_millard/hieradata_odoo.git" && exit 1
fi
popd

cp /vagrant/hiera.yaml /etc/hiera.yaml
cp /vagrant/Puppetfile /etc/Puppetfile

r10k puppetfile install
puppet apply /vagrant/site.pp