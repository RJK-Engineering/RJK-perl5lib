use strict;
use warnings;

use RJK::Log;

my $logger = RJK::Log->logger(); # gets logger for current package or rootlogger if not defined
$logger->fatal("1");

$logger = RJK::Log->init(\q(
    log4perl.rootLogger=DEBUG, root
    log4perl.logger.main=DEBUG, default
    log4perl.logger.A=DEBUG, A
    log4perl.logger.B=DEBUG, B
    log4perl.logger.warnings=DEBUG, default
    log4perl.logger.die=DEBUG, default
    log4perl.appender.root=Log::Log4perl::Appender::Screen
    log4perl.appender.root.layout=Log::Log4perl::Layout::PatternLayout
    log4perl.appender.root.layout.ConversionPattern=[%r] %F %L root - %m%n
    log4perl.appender.default=Log::Log4perl::Appender::Screen
    log4perl.appender.default.layout=Log::Log4perl::Layout::PatternLayout
    log4perl.appender.default.layout.ConversionPattern=[%r] %F %L %c - %m%n
    log4perl.appender.A=Log::Log4perl::Appender::Screen
    log4perl.appender.A.layout=Log::Log4perl::Layout::PatternLayout
    log4perl.appender.A.layout.ConversionPattern=[%r] %F %L %c - %m%n
    log4perl.appender.B=Log::Log4perl::Appender::Screen
    log4perl.appender.B.layout=Log::Log4perl::Layout::PatternLayout
    log4perl.appender.B.layout.ConversionPattern=[%r] %F %L %c - %m%n
));
$logger->warn("2");

package A;
$logger = RJK::Log->logger();
$logger->warn("3");

package B;
push our @ISA, 'A';
$logger = RJK::Log->logger();
$logger->warn("4");

RJK::Log->logWarnings();
warn "5";

eval {
    $SIG{__DIE__} = sub { print "this will still be called, after logging FATAL message" };
    RJK::Log->logDie();
    die "6";
};

eval {
    $SIG{__DIE__} = sub { print "this will NOT be called" };
    RJK::Log->logDie(undef, 1); # replace handler
    die "7";
};
