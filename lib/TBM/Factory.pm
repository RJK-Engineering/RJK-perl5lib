package TBM::Factory;

use strict;
use warnings;

use TBM::Tables;

sub create {
    my ($self, $class, $id) = @_;
    print " create $class\n";
    my $object = $self->get($class, $id);
    $object->{create} = 1;
    return $object;
}

sub fetch {
    my $self = shift;
    my $class = shift;
    print " fetch $class\n";

    if (ref $_[0]) {
        _fetchById($class, ${$_[0]});
    } else {
        _fetchByPath($class, $_[0]);
    }
}

sub get {
    my $self = shift;
    my $class = shift;
    print " get $class\n";

    if ($_[0]) {
        ::table($class)->getInstance({id => newId()});
    } elsif (ref $_[0]) {
        ::table($class)->getInstance({id => ${$_[0]}});
    } else {
        ::table($class)->getInstance({id => newId(), path => $_[0]});
    }
}

sub newId {undef}

sub _fetchById {
    my ($class, $id) = @_;
    ::table($class)->get($id);
}

sub _fetchByPath {
    my ($class, $path) = @_;
    if ($class eq 'TBM::Dir') {
        _fetchDir($path);
    } else {
        $path =~ s|/([^/]+)$||;
        my $filename = $1;
        _fetchFile($class, $path, $filename);
    }
}

sub _fetchDir {
    my ($path) = @_;
    ::table('TBM::Dir')->first({path => $path});
}

sub _fetchFile {
    my ($class, $dirPath, $filename) = @_;
    my $dir = _fetchDir($dirPath);
    my $path = _fetchPath($dir, $filename);
    $path->getFile();
}

sub _fetchPath {
    my ($dir, $filename) = @_;
    ::table('TBM::Path')->first({
        #~ XXX tail => $dir,
        tail_id => $dir->{id},
        filename => $filename
    });
}

sub AUTOLOAD {
    our $AUTOLOAD;
    bless {}, $AUTOLOAD;
}

package TBM::Factory::Dir;
sub create { TBM::Factory->create('TBM::Dir', $_[1]) }
sub fetch  { TBM::Factory->fetch ('TBM::Dir', $_[1]) }
sub get    { TBM::Factory->get   ('TBM::Dir', $_[1]) }

package TBM::Factory::File;
sub create { TBM::Factory->create('TBM::File', $_[1]) }
sub fetch  { TBM::Factory->fetch ('TBM::File', $_[1]) }
sub get    { TBM::Factory->get   ('TBM::File', $_[1]) }

package TBM::Factory::Path;
sub create { TBM::Factory->create('TBM::Path', $_[1]) }
sub fetch  { TBM::Factory->fetch ('TBM::Path', $_[1]) }
sub get    { TBM::Factory->get   ('TBM::Path', $_[1]) }

package TBM::Factory::Volume;
sub create { TBM::Factory->create('TBM::Volume', $_[1]) }
sub fetch  { TBM::Factory->fetch ('TBM::Volume', $_[1]) }
sub get    { TBM::Factory->get   ('TBM::Volume', $_[1]) }

1;
