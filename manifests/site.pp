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
    ensure  => file,
    source  => '/vagrant/keys/alioth',
    require => File["${home}/.ssh"];

  "${home}/.ssh/id_rsa.pub":
    ensure  => file,
    source  => '/vagrant/keys/alioth.pub',
    require => File["${home}/.ssh"];

  "${home}/.config":
    ensure => directory;

  "${home}/.config/dpt.conf":
    ensure  => file,
    require => File["${home}/.config"];

  "${home}/.quiltrc":
    ensure => file;

  "${home}/.bash_aliases":
    ensure  => file,
    source  => '/vagrant/bash_aliases',
    replace => false;

  "${home}/.mrconfig":
    ensure  => file,
    content => "[src/pkg-perl]\nchain = true\ncheckout = git clone ssh://git.debian.org/git/pkg-perl/meta.git pkg-perl\n";

  "${home}/.mrtrust":
    ensure  => file,
    content => "~/src/pkg-perl/.mrconfig\n";

  "${home}/.reportbugrc":
    ensure  => file,
    content => "smtphost reportbug.debian.org\n";
}

file_line {
  'dpt setup for pkg-perl':
    ensure  => present,
    path    => "${home}/.config/dpt.conf",
    line    => "DPT_PACKAGES=${home}/src/pkg-perl/packages",
    match   => 'DPT_PACKAGES=',
    require => File["${home}/.config/dpt.conf"];

  'quilt patches for pkg-perl':
    ensure  => present,
    path    => "${home}/.quiltrc",
    line    => "QUILT_PATCHES=\"debian/patches\"",
    match   => 'QUILT_PATCHES=',
    require => File ["${home}/.quiltrc"];

  'quilt diff args for pkg-perl':
    ensure  => present,
    path    => "${home}/.quiltrc",
    line    => "QUILT_DIFF_ARGS=\"--no-timestamps --no-index -pab\"",
    match   => 'QUILT_DIFF_ARGS=',
    require => File ["${home}/.quiltrc"];

  'quilt refresh args for pkg-perl':
    ensure  => present,
    path    => "${home}/.quiltrc",
    line    => "QUILT_REFRESH_ARGS=\"--no-timestamps --no-index -pab\"",
    match   => 'QUILT_REFRESH_ARGS=',
    require => File ["${home}/.quiltrc"];
}
