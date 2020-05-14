package RJK::Util::Monitor;

sub new {
    return bless {}, shift;
}

sub init {
    return shift;
}

sub poll { ... }

sub finish {}

1;
