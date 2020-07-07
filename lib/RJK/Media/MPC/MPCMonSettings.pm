package RJK::Media::MPC::MPCMonSettings;

use strict;
use warnings;

use RJK::Util::JSON;

sub new {
    my $self = bless {}, shift;
    my $file = shift;
    $self->{settingsFile} = new RJK::Util::JSON($file)->read;
    $self->{settings} = $self->{settingsFile}->data;
    return $self;
}

sub files {
    return $_[0]{settings}{files};
}

sub observers {
    return $_[0]{settings}{observers} //= {};
}

sub setObserverEnabled {
    my ($self, $observer, $enabled) = @_;
    $self->{settings}{observers}{$observer}{enabled} = $enabled;
    $self->{dirty} = 1;
}

sub get {
    my ($self, $file, $prop) = @_;
    $file = $self->{settings}{files}{$file};
    return $file && $file->{$prop};
}

sub set {
    my ($self, $file, $prop, $value) = @_;

    my $settings = $self->{settings}{files}{$file} //= {};

    $self->{previous} = {
        file => $file,
        prop => $prop,
        value => $settings->{$prop}
    };

    $settings->{$prop} = $value;

    $self->{dirty} = 1;
}

sub delete {
    my ($self, $file) = @_;
    delete $self->{settings}{files}{$file};
    $self->{dirty} = 1;
}

sub save {
    my $self = shift;
    return if ! $self->{dirty};
    $self->{settingsFile}->write;
    $self->{dirty} = 0;
}

sub undo {
    my $self = shift;
    my $p = $self->{previous};
    if ($p) {
        delete $self->{settings}{files}{ $p->{file} }{ $p->{prop} };
        print "Undo: $p->{file} ($p->{prop})\n";
        $self->{dirty} = 1;
    } else {
        print "No undo history\n";
    }
}

sub list {
    my $self = shift;
    while (my ($file, $settings) = each %{$self->{settings}{files}}) {
        my $cat = $settings->{category};
        printf "%s\t%s\n", $cat ? "$cat" : "", $file;
    }
    print "\n";
}

1;
