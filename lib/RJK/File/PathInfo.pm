package RJK::File::PathInfo;

use strict;
use warnings;

use File::Spec::Functions qw();

use Exporter ();
our @ISA = qw(Exporter);
our @EXPORT = qw(
    rel2abs
    filename
    directory
    basename
    extension
);
our @EXPORT_OK = (@EXPORT, qw(
    splitpath
    splitname
    hidden
    catdir
    path
));
our %EXPORT_TAGS = ( ALL => \@EXPORT_OK );

sub rel2abs {
    File::Spec::Functions::rel2abs(@_)
}

sub path {
    File::Spec::Functions::path()
}

# from absolute path

sub directory {
    File::Spec::Functions::catdir((File::Spec::Functions::splitpath(@_))[0,1])
}

sub splitpath {
    File::Spec::Functions::splitpath(@_)
}

# from absolute or relative path

sub filename {
    ($_[0] =~ /([^\\\/]+)$/)[0]
}

sub basename {
    (splitname(@_))[0]
}

sub extension {
    (splitname(@_))[1]
}

sub splitname {
    ($_[0] =~ /([^\\\/]+)\.(.+)$/)[0,1]
}

sub hidden {
    filename(@_) =~ /^\./
}

# join

sub catdir {
    File::Spec::Functions::catdir(@_)
}

1;
