package RJK::Media::MPC::WebIF;

use strict;
use warnings;
use utf8;

use LWP::UserAgent;

sub new {
    my $self = bless {}, shift;
    my %opts = @_;

    $self->{host} = $opts{host} || "localhost";
    $self->{port} = $opts{port} || 12345;
    $self->{requestAgent} = $opts{requestAgent} || "MyApp/0.1";
    $self->{requestTimeout} = $opts{requestTimeout} || 5;

    return $self;
}

sub init {
    my $self = shift;

    $self->{url} = $self->getStatusPageUrl();
    $self->{UserAgent} = LWP::UserAgent->new;
    $self->{UserAgent}->agent($self->{requestAgent});

    $self->{HttpRequest} = HTTP::Request->new(GET => $self->{url});
    $self->{UserAgent}->timeout($self->{requestTimeout});

    return $self;
}

sub getStatus {
    my $self = shift;
    my $status = {};

    my $res = $self->{UserAgent}->request($self->{HttpRequest});
    $status->{timestamp} = time;
    $status->{ok} = $res->is_success;
    $status->{message} = $res->message;

    if ($status->{ok}) {
        foreach (split /^/, $res->content) {
            if (m|<p id="(\w+)">(.+)</p>|) {
                $status->{$1} = $2;
                unless (utf8::decode $status->{$1}) {
                    warn "[utf8::decode] String invalid as extended UTF-8: $2",
                }
            }
        }
    }

    return $status;
}

sub getStatusPageUrl {
    my $self = shift;
    return "http://$self->{host}:$self->{port}/variables.html"
}

1;
