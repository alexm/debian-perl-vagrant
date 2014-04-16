class { 'apt': always_apt_update => true }

Package { require => Class['apt'] }

$present_packages = [
  'pkg-perl-tools',
  'myrepos',
]

package { $present_packages: ensure => present }

$home = '/home/vagrant'

file {
  "${home}/.ssh":
    ensure => directory,
    mode   => '0700';

  "${home}/.ssh/id_rsa":
    ensure  => link,
    target  => '/vagrant/keys/alioth',
    require => File["${home}/.ssh"];

  "${home}/.ssh/id_rsa.pub":
    ensure  => link,
    target  => '/vagrant/keys/alioth.pub',
    require => File["${home}/.ssh"];

  "${home}/.config":
    ensure => directory;

  "${home}/.config/dpt.conf":
    ensure  => file,
    require => File["${home}/.config"];

  "${home}/.quiltrc":
    ensure => file;
}

file_line {
  'dpt setup for pkg-perl':
    ensure  => present,
    path    => "${home}/.config/dpt.conf",
    line    => "DPT_PACKAGES=${home}/src/pkg-perl/packages",
    match   => 'DPT_PACKAGES=',
    require => File["${home}/.config/dpt.conf"];

  'quilt for pkg-perl':
    ensure  => present,
    path    => "${home}/.quiltrc",
    line    => 'QUILT_PATCHES=debian/patches',
    match   => 'QUILT_PATCHES=',
    require => File ["${home}/.quiltrc"];
}
