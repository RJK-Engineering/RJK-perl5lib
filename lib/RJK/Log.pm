package RJK::Log;

use strict;
use warnings;

use Log::Log4perl;

sub init {
    my ($self, $conf, $loggerName) = @_;
    _init($conf);
    return $self->logger($loggerName // caller);
}

sub logWarnings {
    my ($self, $loggerName, $rewarn) = @_;
    if (! $Log::Log4perl::Logger::INITIALIZED) {
        Log::Log4perl::Logger->init_warn;
        return;
    }
    my $logger = Log::Log4perl->get_logger($loggerName // 'warnings');

    $SIG{__WARN__} = sub {
        local $Log::Log4perl::caller_depth = $Log::Log4perl::caller_depth + 1;
        $logger->warn($_[0]);
        warn $_[0] if $rewarn;
    };
}

sub logDie {
    my ($self, $loggerName, $replace) = @_;
    _init() if ! $Log::Log4perl::Logger::INITIALIZED;
    my $logger = Log::Log4perl->get_logger($loggerName // 'die');
    my $existingHandler = $SIG{__DIE__};

    $SIG{__DIE__} = sub {
        local $Log::Log4perl::caller_depth = $Log::Log4perl::caller_depth + 1;
        $logger->fatal($_[0]);
        $existingHandler->(@_) unless $replace;
    };
}

sub logger {
    my ($self, $loggerName) = @_;
    $loggerName //= caller;
    _init() if ! $Log::Log4perl::Logger::INITIALIZED;
    return Log::Log4perl->get_logger($loggerName);
}

sub _init {
    my $conf = shift // \q(
        log4perl.rootLogger=DEBUG, StdErr
        log4perl.appender.StdErr=Log::Log4perl::Appender::Screen
        log4perl.appender.StdErr.stderr=1
        log4perl.appender.StdErr.layout=Log::Log4perl::Layout::SimpleLayout
    );
    Log::Log4perl::init($conf);
}

1;
