package RJK::Media::MPC::MPCMonSettings;

use strict;
use warnings;

use RJK::Util::JSON;

sub new {
    my $self = bless {}, shift;
    $self->{file} = shift;
    $self->load;
    return $self;
}

sub load {
    my $self = shift;
    my $data = RJK::Util::JSON->read($self->{file});
    $self->{files} = $data->{files};
    $self->{observers} = $data->{observers};
}

sub save {
    my $self = shift;
    return if ! $self->{dirty};

    RJK::Util::JSON->write($self->{file}, {
        files => $self->{files},
        observers => $self->{observers},
    });

    $self->{dirty} = 0;
}

sub files {
    return $_[0]{files};
}

sub observers {
    return $_[0]{observers} //= {};
}

sub setObserverEnabled {
    my ($self, $observer, $enabled) = @_;
    $self->{observers}{$observer}{enabled} = $enabled;
    $self->{dirty} = 1;
}

sub get {
    my ($self, $file, $prop) = @_;
    $file = $self->{files}{$file};
    return $file && $file->{$prop};
}

sub set {
    my ($self, $file, $prop, $value) = @_;

    my $settings = $self->{files}{$file} //= {};

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
    delete $self->{files}{$file};
    $self->{dirty} = 1;
}

sub undo {
    my $self = shift;
    my $p = $self->{previous};
    if ($p) {
        delete $self->{files}{ $p->{file} }{ $p->{prop} };
        print "Undo: $p->{file} ($p->{prop})\n";
        $self->{dirty} = 1;
    } else {
        print "No undo history\n";
    }
}

sub list {
    my $self = shift;
    while (my ($file, $settings) = each %{$self->{files}}) {
        my $cat = $settings->{category};
        printf "%s\t%s\n", $cat ? "$cat" : "", $file;
    }
    print "\n";
}

1;
