Debian Perl Vagrant
===================

Playing with vagrant boxes for helping Debian Perl job.

Warning!
--------

I'm afraid that the debian-sid.box file size is 1.3 GB. I know it
is too much for a minimal vagrant box, but the fact that there's
no easy way to install sid from scratch makes it difficult to
make it tinier. I'll keep trying.

On this first attempt to build a vagrant box for debian-perl the
puppet-common package was missing, so you need to install it from
the shell before provisioning the box. That will be fixed in the
future, too.

Starting
--------

    git submodule update --init
    vagrant up --no-provision
    vagrant ssh -c "sudo apt-get update"
    vagrant ssh -c "sudo apt-get install puppet-common"
    vagrant provision

Identifying
-----------

    vagrant ssh
    git config --global user.name "Your Name"
    git config --global user.email "your.name@example.org"
    echo 'export DEBFULLNAME="Your Name"'          >> ~/.bash_aliases
    echo 'export DEBEMAIL="your.name@example.org"' >> ~/.bash_aliases
    echo 'Host *.debian.org'                       >> ~/.ssh/config
    echo '    user your-alioth-username'           >> ~/.ssh/config

Cloning
-------

    vagrant ssh
    mkdir ~/src
    cd ~/src
    git clone ssh://git.debian.org/git/pkg-perl/meta.git pkg-perl

Creating
--------

    vagrant ssh
    mkdir ~/src/pkg-perl/packages
    cd ~/src/pkg-perl/packages
    dh-make-perl --pkg-perl --cpan Foo::Bar

Pushing
-------

    vagrant ssh
    git config --global push.default simple
    cd ~/src/pkg-perl/packages/libfoo-bar-perl
    git status
    git log
    git remote -v
    git branch -av
    dpt alioth-repo

Patching
--------

    vagrant ssh
    cd ~/src/pkg-perl/packages/libfoo-bar-perl
    quilt new fix-something.patch
    quilt edit path/to/file
    quilt fold < someone-elses-patch.diff
    quilt refresh
    quilt pop
    prove -e "patchedit check" debian/patches/fix-something.patch
    git add debian/patches
    git commit
    git push --all

Building
--------

    vagrant ssh
    sudo cowbuilder --create
    cd ~/src/pkg-perl/packages/libfoo-bar-perl
    pdebuild --pbuilder cowbuilder

Upgrading
---------

    vagrant ssh
    cd ~/src/pkg-perl/packages/libfoo-bar-perl
    uscan --report
    gbp pull
    git checkout upstream
    git checkout master
    gbp import-orig --uscan --pristine-tar --upstream-branch=upstream

Releasing
---------

    dch -r
    git commit
    git tag debian/${RELEASE}
    git push --all
    git push --tags
    (cd .. && dput ftp-master *.changes)

schroot
-------

Please, add a new hard drive (sdb) and then follow these steps:

    sudo apt-get install sbuild
    sudo pvcreate /dev/sdb1
    sudo vgcreate schroot /dev/sdb1
    sudo lvcreate -n schroot-sid -L1G schroot
    sudo mkfs.ext4 /dev/schroot/schroot-sid
    sudo mount /dev/schroot/schroot-sid /mnt
    sudo sbuild-createchroot sid /mnt http://httpredir.debian.org/debian
    sudo umount /mnt
    cat <<EOF | sudo tee -a /etc/schroot/chroot.d/sid.conf
    [sid]
    type=lvm-snapshot
    device=/dev/schroot/schroot-sid
    description=Debian sid
    users=vagrant
    root-users=vagrant
    source-root-users=root
    aliases=unstable
    lvm-snapshot-options=--size 2G
    EOF

schroot-sid
-----------

    cat <<EOF | sudo schroot -c source:sid
    echo 'APT::Install-Recommends "false";' > /etc/apt/apt.conf.d/50schroot-sid
    EOF
    sudo schroot -c source:sid -- chmod 644 /etc/apt/apt.conf.d/50schroot-sid
    sudo sbuild-update -udr sid

autopkgtest
-----------

    sudo apt-get install autopkgtest pkg-perl-autopkgtest
    adt-run libfoo-bar-perl --- schroot sid

Reading
-------

* https://wiki.debian.org/Teams/DebianPerlGroup
* https://wiki.debian.org/Teams/DebianPerlGroup/Welcome
* http://pkg-perl.alioth.debian.org/git.html
* http://pkg-perl.alioth.debian.org/howto/quilt.html
* http://pkg-perl.alioth.debian.org/tips.html
* http://pkg-perl.alioth.debian.org/autopkgtest.html
* http://www.enricozini.org/2008/tips/joys-of-schroot/

