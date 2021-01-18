###############################################################################
=begin TML

---+ package RJK::TotalCmd::CatalogMakerFile

=cut
###############################################################################

package RJK::TotalCmd::CatalogMakerFile;

use strict;
use warnings;

###############################################################################
=pod

---++ Object attributes

Return object attribute value if called with no arguments, set object
attribute value and return the same value otherwise.

---+++ name([$name]) -> $name

=cut
###############################################################################

#~ use Class::AccessorMaker {
    #~ name => undef,
#~ }, "no_new";
#~ }, "new_init";
#~ };

###############################################################################
=pod

---++ Object creation

---+++ new(%attrs) -> RJK::TotalCmd::CatalogMakerFile
Returns a new =RJK::TotalCmd::CatalogMakerFile= object.

=cut
###############################################################################

sub new {
    my $self = bless {}, shift;

    $self->{dirs} = [];
    $self->{dirIndex} = {};
    $self->{files} = [];
    $self->{dircount} = 0;
    $self->{filecount} = 0;
    $self->{total}{size} = 0;

    if ($self->{path} = shift) {
        $self->load($self->{path});
    }

    return $self;
}

sub traverse {
    my ($self, %opts) = @_;
    $opts{visitFile} ||= sub {};
    $opts{visitFile}->($_) foreach @{$self->{files}};
}

sub dirs {
    @{$_[0]{dirs}};
}

sub getDir {
    $_[0]{dirIndex}{$_[1]};
}

sub files {
    @{$_[0]{files}};
}

###############################################################################
=pod

---++ File access

---+++ read() -> RJK::TotalCmd::CatalogMakerFile
Read data from file. Returns false on failure, callee on success.

---+++ write() -> RJK::TotalCmd::CatalogMakerFile
Write data to file. Returns false on failure, callee on succes.

=cut
###############################################################################

sub load {
    my ($self, $path) = @_;

    my $level = 0;
    my $currdir = { path => "\\",
                   files => [],
                   level => $level };

    my $sizeRE = '(\d+(?:,\d+)*)';

    open(F, $path) || return 0;
    while (<F>) {
        chomp;
        if (/^(.+)\\$/) {
            push @{$self->{dirs}}, $currdir;
            $self->{dirIndex}{$currdir->{path}} = $currdir;

            $currdir->{filecount} = @{$currdir->{files}};
            $self->{filecount} += $currdir->{filecount};
            #~ push @{$currdir->{dirs}}, $_;

            $level = split /\\/;
            $currdir = { path => $1,
                        files => [],
                        level => $level };
        } elsif (/^total files $sizeRE\s+total size\s+$sizeRE\s*$/) {
        } elsif (/\s*(.*?)\s+$sizeRE\s*$/) {
            $_ = { name => $1,
                   path => "$currdir->{path}\\$1",
                dirpath => $currdir->{path},
                   size => ($2 =~ s/,//gr), #/
                  level => $level };

            $self->{total}{size} += $_->{size};
            push @{$currdir->{files}}, $_;
            push @{$self->{files}}, $_;
        } else {
            push @{$self->{nomatch}}, $_;
        }
    }
    close F;

    push @{$self->{dirs}}, $currdir;
    $self->{dirIndex}{$currdir->{path}} = $currdir;

    $currdir->{filecount} = @{$currdir->{files}};
    $self->{filecount} += $currdir->{filecount};
    $self->{dircount} = @{$self->{dirs}};
}

sub print2file {
    &write(@_);
}

sub write {
    my ($self, $out) = @_;

    open(F, ">$out") || return 0;
    foreach (@{$self->{dirs}}) {
        printf F "%s\\\n", $_->{name};
    }
    close F;
}

1;
