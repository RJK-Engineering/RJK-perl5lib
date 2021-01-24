package RJK::Util::ObservableMonitor;
use parent 'RJK::Util::Monitor';
use parent 'RJK::Util::Observable';

sub poll {
    return if ! @{$_[0]{observers}};
    $_[0]->doPoll();
}

sub doPoll { ... }

1;
