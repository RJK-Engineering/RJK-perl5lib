package TBM::Factory;

use strict;
use warnings;

use RJK::DbTable;

my $classes = {
    'TBM::Object' => {
        cols => [qw'id date_created date_last_update'],
        readOnly => [qw'id date_created date_last_update'],
    },
    'TBM::Path' => {
        table => 'path',
        cols => [qw'head_id head_class tail_id tail_class filename'],
    },
    'TBM::Dir' => {
        table => 'directory',
        cols => ['path'],
    },
    'TBM::File' => {
        table => 'file',
        cols => [qw'name size created modified crc'],
    },
    'TBM::Volume' => {
        table => 'volume',
        cols => [qw'label cluster_size size_gb size_formatted free_space drive type'],
    },
};

my $tables;
my $objectCols = $classes->{'TBM::Object'}{cols};

sub getCols { my $class = shift; [@$objectCols, @{$class->{cols}}] }

use RJK::Module;

foreach my $className (keys %$classes) {
    my $class = $classes->{$className};
    next if ! $class->{table};
    RJK::Module->load($className);

    $tables->{$className} = new RJK::DbTable(
        table => $class->{table},
        cols => getCols($class),
        bless => $className,
        static => { class => $className },
        cached => 1
    );
};

*::table = *TBM::Factory::table;
sub table {
    my ($class) = @_;
    return $tables->{$class};
}

sub create {
    my ($self, $class, $id) = @_;
    print " create $class\n";
    table($class)->insert({id => $id});
}

sub save {
    my ($self, $object) = @_;
    table(ref $object)->update($object);
}

sub fetch {
    my $self = shift;
    my $class = shift;
    print " fetch $class\n";

    if (ref $_[0]) {
        _fetchById($class, $_[0]);
    } else {
        _fetchByPath($class, $_[0]);
    }
}

sub _fetchById {
    my ($class, $id) = @_;
    table($class)->get($id);
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
    table('TBM::Dir')->first({path => $path});
}

sub _fetchFile {
    my ($class, $dirPath, $filename) = @_;
    my $dir = _fetchDir($dirPath);
    my $path = _fetchPath($dir, $filename);
    $path->getFile();
}

sub _fetchPath {
    my ($dir, $filename) = @_;
    table('TBM::Path')->first({
        #~ tail => $dir,
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

package TBM::Factory::Volume;
sub create { TBM::Factory->create('TBM::Volume', $_[1]) }
sub fetch  { TBM::Factory->fetch ('TBM::Volume', $_[1]) }
sub get    { TBM::Factory->get   ('TBM::Volume', $_[1]) }

1;
