package RJK::Filecheck::Site;

use Class::AccessorMaker {
    name => "",
    alias => "",
    protocol => "",
    host => "",
    download => "",
    search => "",
    hd => "",
    latest => "",
    playlist => undef,
    hq => "136+140",
    lq => "134+140",
    timeout => 0,
    idregex => undef,
};

sub downloadUrl {
    my ($self, $id) = @_;
    my $url = sprintf "$self->{protocol}://$self->{host}/$self->{download}", $id;
    return $url;
}

sub searchUrl {
    my ($self, $query) = @_;
    my $url = sprintf "$self->{protocol}://$self->{host}/$self->{search}", $query;
    return $url;
}

1;
