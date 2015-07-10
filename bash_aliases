# http://pkg-perl.alioth.debian.org/tips.html

#----------------------------------------------------------------
# 2. Aliases

# download upstream tarball and import it into git-buildpackage
alias git-uscan='gbp-pull ; git-import-orig --uscan ; rm ../*.tar.gz'
# quickly edit your aliases/functions
# presumes ~/.aliases is loaded on shell startup
alias ale='vim ~/.bash_aliases; unalias -a; source ~/.bash_aliases'

#----------------------------------------------------------------
# 3. Functions

# afsp = apt-file search $perl; obsolete since `dh-make-perl --locate'
function afsp {
    apt-file search $(echo "/$@" | sed -e 's|::|/|g ; s|-|/|g ; s|$|.pm|') | uniq
}
# extract package details. used in the rest below
pkg_info()
{
    dpkg-parsechangelog|grep ^$1|cut -f2 -d' '
}
# run lintian and diffstat on the package built in pbuilder result/
# directory
# package name is deduced from ./debian.
# all argumentts are given to lintian
lpdb()
{
    local PKG=`pkg_info Source:`
    local VER=`pkg_info Version:|sed 's/^.\+://'`
    local ARCH=`dpkg-architecture -qDEB_HOST_ARCH`
    local PDB=/var/cache/pbuilder/result
    local CMD="lintian $@ -I --color=auto ${PDB}/${PKG}_${VER}_${ARCH}.changes"
    echo $CMD
    $CMD
    if [ -e ${PDB}/${PKG}_${VER}.diff.gz ]; then
        echo diffstat ${PDB}/${PKG}_${VER}.diff.gz
        diffstat ${PDB}/${PKG}_${VER}.diff.gz
    else
        echo Native package.
    fi
}
# show upstream/debian/binary differences between the version in the
# archive and the built package in pbuilder result/ directory
# package name deduced from ./debian/
dpdb()
{
    local PKG=`pkg_info Source:`
    local VER=`pkg_info Version:|sed 's/^.\+://'`
    local ARCH=`dpkg-architecture -qDEB_HOST_ARCH`
    local PDB=/var/cache/pbuilder/result
    BINS=`awk '/^Package: /{print $2}' < debian/control`
    TMP=`mktemp -d`
    trap "rm -r $TMP" INT TERM QUIT
    (cd $TMP && apt-get -t sid -d source ${PKG})
    ( echo "UPSTREAM DIFF"; debdiff -w $TMP/*.dsc ${PDB}/${PKG}_${VER}.dsc \
        | filterdiff -x '*/debian/*' ) \
            | tee $PDB/${PKG}_${VER}-upstream.diff | colordiff | less -R
    ( echo "DEBIAN DIFF"; debdiff -w $TMP/*.dsc ${PDB}/${PKG}_${VER}.dsc \
        | filterdiff -i '*/debian/*' ) \
            | tee ${PDB}/${PKG}_${VER}-debian.diff | colordiff | less -R
    ( cd $TMP && mkdir -p archives/partial && for b in $BINS; do apt-get -o Dir::Cache=. -o Debug::NoLocking=1 install --reinstall -y -d -t sid $b/unstable; done )
    ( cd $TMP && for p in $BINS; do echo "DEBDIFF $p"; echo "============"; debdiff --wl archives/${p}_*.deb ${PDB}/${p}_${VER}*.deb; echo; done ) \
        | tee ${PDB}/${PKG}_${VER}-deb.diff \
        | less -R
}
# debc on the package in the pbuilder result/ directory
cpdb()
{
    local PKG=`pkg_info Source:`
    local VER=`pkg_info Version:|sed 's/^.\+://'`
    local ARCH=`dpkg-architecture -qDEB_HOST_ARCH`
    local PDB=/var/cache/pbuilder/result
    echo debc ${PDB}/${PKG}_${VER}_${ARCH}.changes
    debc ${PDB}/${PKG}_${VER}_${ARCH}.changes|less
}
# sign and upload the package from pbuilder result/ directory
# any arguments are passed to debsign (-k $SELF useful when sponsoring)
spdb()
{
    local PKG=`pkg_info Source:`
    local VER=`pkg_info Version:|sed 's/^.\+://'`
    local ARCH=`dpkg-architecture -qDEB_HOST_ARCH`
    local PDB=/var/cache/pbuilder/result
    echo debsign $* ${PDB}/${PKG}_${VER}_${ARCH}.changes
    debsign $* ${PDB}/${PKG}_${VER}_${ARCH}.changes
    echo dupload --to debian ${PDB}/${PKG}_${VER}_${ARCH}.changes
    dupload --to debian ${PDB}/${PKG}_${VER}_${ARCH}.changes
}
# upload package from pbuilder result/ directory to local apt reposutory
# useful for making packages in NEW available to pbuilder
lupdb()
{
    local DEST
    DEST=$1
    if [ -z "$DEST" ]; then
        echo "Synopsys: lpdb DEST"
        return 1
    fi
    local PKG=`pkg_info Source:`
    local VER=`pkg_info Version:|sed 's/^.\+://'`
    local ARCH=`dpkg-architecture -qDEB_HOST_ARCH`
    local PDB=/var/cache/pbuilder/result
    reprepro -b /disk1/test-repo/$DEST include sid ${PDB}/${PKG}_${VER}_${ARCH}.changes
}
# run development version of dh-make-perl
dh-make-perl-dev() {
    local DHMP=~/work/debian/pkg-perl/apps/dh-make-perl
    PERL5LIB=$DHMP/lib $DHMP/dh-make-perl --data-dir $DHMP/share "$@"
}

#----------------------------------------------------------------

# Supersede LC_* with current LANG
export LC_ALL=$LANG

