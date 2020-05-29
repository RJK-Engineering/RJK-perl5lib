use strict;
use warnings;

use RJK::Media::MPC::WebIF::NonBlocking;

my $mpcwif = new RJK::Media::MPC::WebIF::NonBlocking(
    host => "localhost",
    port => 13578,
    requestAgent => "MyApp/0.1",
    requestTimeout => 5,
    callback => sub { print shift->status_line, "\n" },
    errorCallback => sub { print shift->status_line, "\n" },
)->init;

use Data::Dump;
my $status = $mpcwif->getStatus;
dd $status;

print "Send command, waiting for response...\n";
my $response = $mpcwif->sendCommand(800); # Open File
dd $response;

print "Send command non-blocking...\n";
$mpcwif->sendCommandNonBlocking(800); # Open File

print "Command queued, waiting for thread to complete...\n";
$mpcwif->exit();

print "Done.\n";
