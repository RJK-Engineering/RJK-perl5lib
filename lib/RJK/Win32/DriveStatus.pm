###############################################################################
=begin TML

---+ package RJK::Win32::DriveStatus

File persisted drive status model.

=cut
###############################################################################

package RJK::Win32::DriveStatus;

use strict;
use warnings;

use RJK::Util::JSON;
use RJK::Win32::VolumeInfo;

use Exception::Class (
    'Exception',
    'RJK::Win32::DriveStatus::Exception' =>
        { isa => 'Exception' },
    'RJK::Win32::DriveStatus::NoVolumeInfoException' =>
        { isa => 'RJK::Win32::DriveStatus::Exception' },
);

###############################################################################
=pod

---++ Object creation

---+++ new(%opts)
Create a new =RJK::Win32::DriveStatus= object.
   * =%opts=
    * =$opts{ignore}=
    * =$opts{status}=

---++ Object attributes

---+++ status([$status]) -> $status
---+++ ignore([$ignore]) -> $ignore

=cut
###############################################################################

sub new {
    my $self = bless {}, shift;
    my $opts = shift;
    $self->{ignore} = $opts->{ignore};
    $self->{status} = RJK::Util::JSON->read($self->{statusFile} = $opts->{statusFile});
    return $self;
}

sub commit {
    RJK::Util::JSON->write($_[0]{statusFile}, $_[0]{status});
}

sub status {
    return wantarray ? %{$_[0]{status}} : $_[0]{status};
}

sub ignore {
    return wantarray ? %{$_[0]{ignore}} : $_[0]{ignore};
}

###############################################################################
=pod

---++ Other methods

---+++ update() -> $status
Get online volumes, newly online volumes are set to active.
Returns true if the set of online of volumes has changed, false otherwise.
Throws =RJK::Win32::DriveStatus::NoVolumeInfoException=.

=cut
###############################################################################

sub update {
    my $self = shift;
    my $volumes = RJK::Win32::VolumeInfo->getVolumes();
    throw RJK::Win32::DriveStatus::NoVolumeInfoException("$^E") if !$volumes;

    my $changed;
    $self->_setOffline($volumes, \$changed);
    $self->_setOnline($volumes, \$changed);

    $self->commit() if $changed;
    return $changed;
}

sub _setOffline {
    my ($self, $volumes, $changed) = @_;
    foreach my $vol (values %{$self->{status}}) {
        my $l = $vol->{letter};
        next if $self->{ignore}{$l};
        next if ! $vol->{online};
        next if $volumes->{$l};

        $vol->{online} = 0;
        $$changed = 1;
    }
}

sub _setOnline {
    my ($self, $volumes, $changed) = @_;
    my $status = $self->{status};
    foreach my $vol (values %$volumes) {
        my $l = $vol->{letter};
        next if $self->{ignore}{$l};

        if ($status->{$l}) {
            next if $status->{$l}{online};
            $status->{$l}{online} = 1;
            $$changed = 1;
        } else {
            $status->{$l} = $vol;
        }
    }
}

###############################################################################
=pod

---+++ all() -> \%volumes or @volumes
Returns all volumes.
Returns a list of volumes sorted by drive letter in list context.
Returns a =$driveLetter => \%volume= hash reference in scalar context.

=cut
###############################################################################

sub all {
    my $self = shift;
    return wantarray ? valuesSortedByKey($self->{status}) : $self->{status};
}

###############################################################################
=pod

---+++ online() -> \%volumes or @volumes
Returns online volumes.
Returns a list of volumes sorted by drive letter in list context.
Returns a =$driveLetter => \%volume= hash reference in scalar context.

=cut
###############################################################################

sub online {
    my $self = shift;
    my %online;
    foreach ($self->all) {
        my $driveLetter = $_->{letter};
        next if $self->{ignore}{$driveLetter};
        $online{$driveLetter} = $_ if $_->{online};
    }
    return wantarray ? valuesSortedByKey(\%online) : \%online;
}

###############################################################################
=pod

---+++ offline() -> \%volumes or @volumes
Returns offline volumes.
Returns a list of volumes sorted by drive letter in list context.
Returns a =$driveLetter => \%volume= hash reference in scalar context.

=cut
###############################################################################

sub offline {
    my $self = shift;
    my %offline;
    foreach ($self->all) {
        my $driveLetter = $_->{letter};
        next if $self->{ignore}{$driveLetter};
        $offline{$driveLetter} = $_ unless $_->{online};
    }
    return wantarray ? valuesSortedByKey(\%offline) : \%offline;
}

###############################################################################
=pod

---+++ active() -> \%volumes or @volumes
Returns active volumes.
Returns a list of volumes sorted by drive letter in list context.
Returns a =$driveLetter => \%volume= hash reference in scalar context.

=cut
###############################################################################

sub active {
    my $self = shift;
    my %active;
    foreach ($self->all) {
        my $driveLetter = $_->{letter};
        next if $self->{ignore}{$driveLetter};
        $active{$driveLetter} = $_ if $_->{active};
    }
    return wantarray ? valuesSortedByKey(\%active) : \%active;
}

###############################################################################
=pod

---+++ inactive() -> \%volumes or @volumes
Returns inactive volumes.
Returns a list of volumes sorted by drive letter in list context.
Returns a =$driveLetter => \%volume= hash reference in scalar context.

=cut
###############################################################################

sub inactive {
    my $self = shift;
    my %inactive;
    foreach ($self->all) {
        my $driveLetter = $_->{letter};
        next if $self->{ignore}{$driveLetter};
        $inactive{$driveLetter} = $_ unless $_->{active};
    }
    return wantarray ? valuesSortedByKey(\%inactive) : \%inactive;
}

###############################################################################
=pod

---+++ toggleActive($driveLetter) -> $boolean
Returns new value.

=cut
###############################################################################

sub toggleActive {
    my ($self, $driveLetter) = @_;
    my $status = $self->{status}{$driveLetter} // return;
    $status->{active} = $status->{active} ? 0 : 1;
    $self->commit();
    return $status->{active};
}

###############################################################################
=pod

---+++ isOnline($driveLetter) -> $boolean
---+++ str() -> $statusString

=cut
###############################################################################

sub isOnline {
    my ($self, $driveLetter) = @_;
    $self->{status}{$driveLetter} // return;
    $self->{status}{$driveLetter}{online};
}

sub valuesSortedByKey {
    my $hash = shift;
    map { $hash->{$_} } sort keys %$hash;
}

sub str {
    my $vol = $_[1] // $_;
    !$vol->{online} && "offline" ||
    $vol->{active} && "active"  || "inactive";
}

1;
