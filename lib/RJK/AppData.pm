###############################################################################
=begin TML

---+ package RJK::AppData

Read and write data from files stored in application data directories.

Supported file types:
   * JSON - objects containing hashes and/or arrays, no comments
   * Ini - key/value pairs in sections, one key/value pair per line, comments
   * Properties - key/value pairs, values can span multiple lines, comments

=cut
###############################################################################

package RJK::AppData;

use strict;
use warnings;

use RJK::Env;
use RJK::Util::JSON;
use RJK::Util::Properties;

###############################################################################
=pod

---++ Class methods

---+++ get($filename, $defaults) -> (\@loaded, $data)
   * =$filename= - path to data file relative to data directory
   * =$defaults= - optional default data, not static, may be altered
   * =@loaded= - path list of loaded files
   * =$data= - the data

RJK::AppData
    get($filename, $defaults) -> $data
    read($filename) -> RJK::Data
    write($filename, $data)
    write($filename, RJK::Data)
RJK::Data
    new($data)      -- calls add($data)
    get() -> $data  -- get pure perl data representation
    clear()         -- remove all data
    add($data)      -- load (update) from pure perl data
    load($filename) -- load (update) from file
    write($filename)
RJK::JSON implements RJK::Data
RJK::INI implements RJK::Data
RJK::Properties implements RJK::Data

my $data = AppData->get("file.json", {update=>"me"});
my $dataObj = AppData->read("file.json");
my $data = $dataObj->get();
AppData->write("file.json", $data);
AppData->write("file.json", $dataObj);

=cut
###############################################################################

sub get {
    my ($self, $filename, $defaults) = @_;
    $self->read($filename, $defaults);
}

sub getFile {
    my ($self, $filename) = @_;
    RJK::Env->findLocalFiles($filename) or die "File not found: $filename";
}

sub read {
    my ($self, $filename, $defaults) = @_;
    my $data;
    my @paths = RJK::Env->findLocalFiles($filename) or die "File not found: $filename";
    if ($filename =~ /\.properties$/) {
        $data = loadProperties(\@paths, $defaults);
    } elsif ($filename =~ /\.json$/) {
        $data = loadJson(\@paths, $defaults);
    } else {
        die "Unsupported file type: $filename";
    }
    return \@paths, $data;
}

sub loadProperties {
    my ($paths, $defaults) = @_;
    my $p = new RJK::Util::Properties($defaults);
    $p->load($_) for @$paths;
    return $p->hash;
}

sub loadJson {
    my ($paths, $defaults) = @_;
    foreach (@$paths) {
        my $json = RJK::Util::JSON->read($_) || return;
        while (my ($k, $v) = each %$json) {
            $defaults->{$k} = $v;
        }
    }
    return $defaults;
}

###############################################################################
=pod

---+++ write($filename, $data)
   * =$filename= - path to data file relative to data directory
   * =$data= - the data

=cut
###############################################################################

sub write {
    my ($self, $filename, $data) = @_;
    my $path = (RJK::Env->findLocalFiles($filename))[0] or die "File not found: $filename";

    if (UNIVERSAL::isa('RJK::Data', $data)) {
        $data->write($path);
    } elsif ($filename =~ /\.properties$/) {
        $data = new RJK::Util::Properties($data) if not UNIVERSAL::isa('RJK::Util::Properties', $data);
        $data->write($path);
    } elsif ($filename =~ /\.json$/) {
        RJK::Util::JSON->write($path, $data);
    } else {
        die "Unsupported file type: $path";
    }
}

1;
