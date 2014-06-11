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
    echo 'Host git.debian.org'                     >> ~/.ssh/config
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
    gbp-pull
    gbp import-orig --uscan --pristine-tar

Releasing
---------

    dch -r
    git commit
    git push --all

Reading
-------

* https://wiki.debian.org/Teams/DebianPerlGroup
* https://wiki.debian.org/Teams/DebianPerlGroup/Welcome
* http://pkg-perl.alioth.debian.org/git.html
* http://pkg-perl.alioth.debian.org/howto/quilt.html
* http://pkg-perl.alioth.debian.org/tips.html

