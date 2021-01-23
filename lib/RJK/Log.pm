package RJK::Log;

use strict;
use warnings;

use File::Basename qw(fileparse);
use Log::Log4perl;

sub init {
    my ($self, $conf, $loggerName) = @_;
    _init($conf);
    return $self->logger($loggerName // caller);
}

sub logWarnings {
    my ($self, %opts) = @_;
    if (! $Log::Log4perl::Logger::INITIALIZED) {
        Log::Log4perl::Logger->init_warn;
        return;
    }
    my $logger = Log::Log4perl->get_logger($opts{logger} // 'warnings');
    my $existingHandler = $SIG{__WARN__} unless $opts{replaceHandler};

    $SIG{__WARN__} = sub {
        local $Log::Log4perl::caller_depth = $Log::Log4perl::caller_depth + 1;
        $logger->warn($_[0]);
        warn $_[0] unless $opts{quiet};
        $existingHandler->(@_) if $existingHandler;
    };
}

sub logDie {
    my ($self, %opts) = @_;
    _init() if ! $Log::Log4perl::Logger::INITIALIZED;
    my $logger = Log::Log4perl->get_logger($opts{logger} // 'die');
    my $existingHandler = $SIG{__DIE__} unless $opts{replaceHandler};

    $SIG{__DIE__} = sub {
        local $Log::Log4perl::caller_depth = $Log::Log4perl::caller_depth + 1;
        $logger->fatal($_[0]);
        $existingHandler->(@_) if $existingHandler;
    };
}

sub logger {
    my ($self, $loggerName) = @_;
    $loggerName //= caller;
    if ($loggerName eq 'main') {
        my $currExecProgFilename = fileparse($0);
        $loggerName = $currExecProgFilename =~ s/\.\w+$//r if $currExecProgFilename;
    }
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
