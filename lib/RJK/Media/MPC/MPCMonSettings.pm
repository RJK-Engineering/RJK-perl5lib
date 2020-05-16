package RJK::Media::MPC::MPCMonSettings;

use RJK::Util::JSON;

sub new {
    my $self = bless {}, shift;
    my $file = shift;
    $self->{settingsFile} = new RJK::Util::JSON($file)->read;
    $self->{settings} = $self->{settingsFile}->data;
    return $self;
}

sub get {
    my ($self, $file, $prop) = @_;
    $file = $self->{settings}{$file};
    return $file && $file->{$prop};
}

sub set {
    my ($self, $file, $prop, $value) = @_;
    $file = $self->{settings}{$file} //= {};
    $file->{$prop} = $value;
    $self->{dirty} = 1;
}

sub save {
    my $self = shift;
    $self->{settingsFile}->write if $self->{dirty};
    $self->{dirty} = 0;
}

1;
