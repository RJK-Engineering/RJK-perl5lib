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

---+++ get($filename) -> (\@loaded, $data)
---+++ get(\@filenames) -> (\@loaded, $data)
---+++ get($filename, $data) -> (\@loaded, $data)
---+++ get(\@filenames, $data) -> (\@loaded, $data)
   * =$filename= - path to data file relative to data directory
   * =@filenames= - paths to data files relative to data directory
   * =$data= - optional argument, updates existing data if present
   * =@loaded= - path list of loaded files

RJK::AppData
    get($filename) -> $data
    get($filename, $data) -> $data
    read($filename) -> RJK::Data
    write($filename, $data)
    write($filename, RJK::Data)
RJK::Data
    get() -> $value
    read($filename)
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
    my ($self, $filenames, $data) = @_;
    $self->read($filenames, $data);
}

sub read {
    my ($self, $filenames, $data) = @_;
    my @loaded;
    $filenames = [$filenames] if not ref $filenames;
    $data //= {};
    foreach my $file (@$filenames) {
        my @local = RJK::Env->findLocalFiles($file);
        push @loaded, @local;
        if ($file =~ /\.properties$/) {
            loadProperties($_, $data) for @local;
        } elsif ($file =~ /\.json$/) {
            loadJson($_, $data) for @local;
        } else {
            die "Unsupported file type: $file";
        }
    }
    return \@loaded, $data;
}

sub loadProperties {
    my ($path, $data) = @_;
    my $props = new RJK::Util::Properties();
    $props->load($path);

    while (my ($k, $v) = each %{$props->hash}) {
        $k =~ s/\.(\w?)/\U$1/g; # make camelCase
        $data->{$k} = $v;
    }
}

sub loadJson {
    my ($path, $data) = @_;
    my $json = RJK::Util::JSON->read($path);

    while (my ($k, $v) = each %$json) {
        $data->{$k} = $v;
    }
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
    my $local = (RJK::Env->findLocalFiles($filename))[0] || die "File not found: $filename";

    if (UNIVERSAL::isa('RJK::Data', $data)) {
        $data->write($local);
    } elsif ($filename =~ /\.properties$/) {
        $data = new RJK::Util::Properties($data) if not UNIVERSAL::isa('RJK::Util::Properties', $data);
        $data->write($local);
    } elsif ($filename =~ /\.json$/) {
        RJK::Util::JSON->write($local, $data);
    } else {
        die "Unsupported file type: $filename";
    }
}

1;
