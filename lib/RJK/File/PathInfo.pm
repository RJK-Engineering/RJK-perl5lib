package RJK::File::PathInfo;

use strict;
use warnings;

use File::Spec::Functions qw();

use Exporter ();
our @ISA = qw(Exporter);
our @EXPORT = qw(
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
));
our %EXPORT_TAGS = ( ALL => \@EXPORT_OK );

# from absolute path

sub filename {
    #~ (File::Spec::Functions::splitpath(@_))[2]
    ($_[0] =~ /([^\\\/]+)$/)[0]
}

sub directory {
    File::Spec::Functions::catdir((File::Spec::Functions::splitpath(@_))[0,1])
}

sub splitpath {
    File::Spec::Functions::splitpath(@_)
}

# from absolute or relative path

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
    ((splitname(@_))[0] =~ /^\./)
}

# join

sub catdir {
    File::Spec::Functions::catdir(@_)
}

1;
