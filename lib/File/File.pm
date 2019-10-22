package File::File;

use strict;
use warnings;
use File::Spec::Functions qw(catfile catpath splitpath rel2abs);

our $curdir = File::Spec->curdir();
our $updir = File::Spec->updir();

use Class::AccessorMaker {
    # [path]
    # [dir][name]
    # [volume][dirs][name]
    path => "",
    volume => "",
    dir => "",
    name => "",
    dirs => "",

    # status values and flags
    size => undef,
    exists => undef,
    isDir => undef,
    isFile => undef,
    isRoot => undef,
    isWritable => undef,
    isExecutable => undef,
    accessed => undef,
    modified => undef,
    created => undef,
    isLink => undef,

    # filecheck fields
    partition => undef,
    id => undef,
    crc => undef,
}, "no_new";

sub new {
    my $self = bless {}, shift;
    $self->set(@_);
    return $self;
}

sub set {
    my $self = shift;

    if (@_ == 1) {
        my ($path) = @_;
        $self->{path} = rel2abs($path);
    } elsif (@_ == 2) {
        my ($dir, $name) = @_;
        $self->{path} = catfile(rel2abs($dir), $name);
    } elsif (@_ == 3) {
        my ($volume, $dirs, $name) = @_;
        $self->{path} = catpath($volume, $dirs, $name);
    } else {
        die "Invalid argument count";
    }

    $self->splitPath();

    if ($self->{name} eq '') {
        $self->{isRoot} = 1;
        $self->{dir} = '';
        $self->{dirs} = '';
        $self->{path} .= '\\';
    }
}

sub splitPath {
    my $self = shift;

    $self->{path} =~ s/[\\\/]+$//;   # remove trailing slashes and dots
    $self->{path} =~ s/^(\w:)/\U$1/; # upper case drive letter

    my @sp = splitpath($self->{path});
    $self->{volume} = $sp[0];
    $self->{dirs} = $sp[1];
    $self->{name} = $sp[2];
    $self->{name} =~ s/\.+$//;       # remove trailing dots
    $self->{dir} = catpath($self->{volume}, $self->{dirs}, "");
}

sub setDir {
    my ($self, $path) = shift;
    $self->set($path, $self->{name});
}

sub setName {
    my ($self, $name) = @_;
    $name ne '' || die "Invalid filename";

    $name =~ s/\.+$//;   # remove trailing dots
    $self->{name} = $name;
    $self->{path} = catfile($self->{dir}, $name);
}

sub setBasename {
    my ($self, $basename) = @_;
    $basename ne '' || die "Invalid basename";
    my $extension = $self->extension;
    $self->setName("$basename.$extension");
}

sub setExtension {
    my ($self, $extension) = @_;
    my $basename = $self->basename;
    $self->setName("$basename.$extension");
}

sub parent {
    my $self = shift;
    return if $self->{isRoot};
    my $parent = $self->{parent};
    if (! $parent) {
        $parent = $self->{parent} =
            __PACKAGE__->new($self->{dir});
        $parent->{partition} = $self->{partition} if $self->{partition};
    }
    return $parent;
}

sub files {
    my $self = shift;
    opendir my $dh, $self->{path};
    #~ my @files = grep { -f $_->{path} && $_ } map { new File::File($self->{dir}, $_) } readdir $dh;
    my @files = grep { -f $_->{path} } map { new File::File($self->{path}, $_) } readdir $dh;
    closedir $dh;
    return wantarray ? @files : \@files;
}

sub children {
    my $self = shift;
    opendir my $dh, $self->{path};
    my @files = map { new File::File($self->{dir}, $_) } readdir $dh;
    closedir $dh;
    return wantarray ? @files : \@files;
}

sub names {
    my $self = shift;
    my @names = map { $_->{name} } $self->children;
    return wantarray ? @names : \@names;
}

sub getChild {
    my ($self, $name) = @_;
    my $child = __PACKAGE__->new($self->{path}, $name);
    $child->{partition} = $self->{partition} if $self->{partition};
    return $child;
}

sub getSibling {
    my ($self, $name) = @_;
    my $parent = $self->parent;
    return $parent ? $parent->getChild($name) : undef;
}

sub stat {
    my $self = shift;
    if (my @stat = CORE::stat $self->{path}) {
        $self->{exists} = 1;
        $self->{isDir} = -d _;
        $self->{isFile} = -f _;
        $self->{isWritable} = -w _;
        $self->{isExecutable} = -x _;
        $self->{size} = $stat[7];
        $self->{accessed} = $stat[8];
        $self->{modified} = $stat[9];
        $self->{created} = $stat[10];
        $self->{isLink} = -l $self->{path}; # updates stat buffer, don't use _ for this file hereafter!
    } else {
        $self->{exists} = 0;
    }
    return $self;
}

sub toString {
    $_[0]{path};
}

# '0' can be a filename extension, use defined to check if there is a
# filename extension!
# Extension/basename regex:
# At least one character before dott, e.g. the filename '.profile' has
# no extension. The dott indicates a hidden file, not the start of the
# filename extension.
sub extension {
    #~ ($_[0]{name} =~ /[^.]\.([^\.]+)$/)[0] || '';
    ($_[0]{name} =~ /.+\.(.*)/)[0] // '';
}

sub basename {
    #~ ($_[0]{name} =~ /(.+)\.[^\.]+$/)[0] || $_[0]{name};
    ($_[0]{name} =~ /(.+)\..*/)[0] // $_[0]{name};
}

sub driveLetter {
    ($_[0]{volume} =~ /(.):/)[0];
}

sub drivePath {
    catpath('', $_[0]{dirs}, $_[0]{name});
}

sub touch {
    return if -e $_[0]{path};
    open my $f, '>', $_[0]{path};
    close $f;
}

sub isShortFilename {
    return $_[0]{name} =~ /^\S{1,6}~\d{1,6}+\.\w{0,3}$/;
}

sub getLongPath {
    return Win32::GetLongPathName($_[0]{path});
}

# static function for getting File object from arguments
# FIXME: move to util class or something
sub getFile {
    my %opts = @_ % 2 ? (path => @_) : @_;
    return $opts{file} if $opts{file};

    $opts{path} = $opts{dir} if $opts{dir};

    if ($opts{path}) {
        return __PACKAGE__->new($opts{path});
    } elsif ($opts{parentdir} && defined $opts{filename}) {
        return __PACKAGE__->new($opts{parentdir}, $opts{filename});
    }
}

1;
