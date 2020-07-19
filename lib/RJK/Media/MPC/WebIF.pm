=begin TML

---+ package RJK::Media::MPC::WebIF

=cut

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

    $self->{userAgent} = new LWP::UserAgent;
    $self->{userAgent}->agent($self->{requestAgent});
    $self->{userAgent}->timeout($self->{requestTimeout});

    my $url = "http://$self->{host}:$self->{port}/variables.html";
    $self->{statusHttpRequest} = new HTTP::Request(GET => $url);

    $self->{commandUrl} = "http://$self->{host}:$self->{port}/command.html";

    return $self;
}

sub getStatus {
    my $self = shift;
    my $status = {};

    my $res = $self->{userAgent}->request($self->{statusHttpRequest});
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

###############################################################################
=pod

---++ sendCommand($commandId) -> $response
   * =$commandId= - Command ID.
   * =$response= - =HTTP::Response= object.

Returns response.

NOTE: some commands (like "Open File" which opens a dialog) are blocking a
response. To do a fire-and-forget, use
=RJK::Media::MPC::WebIF::NonBlocking->sendCommandNonBlocking()=.

=cut
###############################################################################

sub sendCommand {
    my ($self, $commandId) = @_;
    return $self->{userAgent}->post($self->{commandUrl}, {wm_command=>$commandId});
}

1;
