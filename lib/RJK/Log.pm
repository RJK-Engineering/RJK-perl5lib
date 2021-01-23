package RJK::Log;

use strict;
use warnings;

use RJK::Env;
use RJK::Path;
use RJK::Paths;
use Log::Log4perl;

our $conf;

sub init {
    my ($self, $conf, $loggerName) = @_;
    _init($conf);
    return $self->logger($loggerName // caller);
}

sub config {
    $Log::Log4perl::Config::OLD_CONFIG;
}

sub logWarnings {
    my ($self, %opts) = @_;
    _init($opts{conf}) if ! $Log::Log4perl::Logger::INITIALIZED;
    my $logger = Log::Log4perl->get_logger($opts{logger} // 'warnings');
    my $existingHandler = $SIG{__WARN__} unless $opts{replaceHandler};

    $SIG{__WARN__} = sub {
        local $Log::Log4perl::caller_depth = $Log::Log4perl::caller_depth + 1;
        $logger->warn($_[0] =~ s/\v+$//r);
        warn $_[0] unless $opts{quiet};
        $existingHandler->(@_) if $existingHandler;
    };
}

sub logDie {
    my ($self, %opts) = @_;
    _init($opts{conf}) if ! $Log::Log4perl::Logger::INITIALIZED;
    my $logger = Log::Log4perl->get_logger($opts{logger} // 'die');
    my $existingHandler = $SIG{__DIE__} unless $opts{replaceHandler};

    $SIG{__DIE__} = sub {
        local $Log::Log4perl::caller_depth = $Log::Log4perl::caller_depth + 1;
        $logger->fatal($_[0] =~ s/\v+$//r);
        $existingHandler->(@_) if $existingHandler;
    };
}

sub logger {
    my ($self, $loggerName) = @_;
    _init() if ! $Log::Log4perl::Logger::INITIALIZED;
    return Log::Log4perl->get_logger($loggerName // caller);
}

sub _init {
    $conf = shift // &localConfFile // \q(
        log4perl.rootLogger=DEBUG, StdErr
        log4perl.appender.StdErr=Log::Log4perl::Appender::Screen
        log4perl.appender.StdErr.stderr=1
        log4perl.appender.StdErr.layout=Log::Log4perl::Layout::SimpleLayout
    );
    Log::Log4perl::init($conf);
}

sub localConfFile {
    my $appName = RJK::Paths->get($0)->basename;
    (RJK::Env->findLocalFiles("$appName/log4perl.conf"))[0]
    ||
    (RJK::Env->findLocalFiles('log4perl.conf'))[0];
}

1;
