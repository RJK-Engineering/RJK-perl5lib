use strict;
use warnings;

use RJK::Log;

RJK::Log->logWarnings(); # prints warning, only works after initialization

my $logger = RJK::Log->logger(); # gets logger for current package, auto-initializes
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

package main;
RJK::Log->logWarnings(
    logger => 'warnings',  # defaults
    quiet => 0,
    replaceHandler => 0
);
warn "5";
RJK::Log->logWarnings(
    quiet => 1,
    replaceHandler => 1
);
warn "6";

eval {
    $SIG{__DIE__} = sub { print "this will still be called, after logging FATAL message" };
    RJK::Log->logDie(
        logger => 'die',    # defaults
        replaceHandler => 0
    );
    die "7";
};

eval {
    $SIG{__DIE__} = sub { print "this will NOT be called" };
    RJK::Log->logDie(
        replaceHandler => 1
    );
    die "8";
};
