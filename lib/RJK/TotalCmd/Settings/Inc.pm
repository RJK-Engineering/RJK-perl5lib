=begin TML

---+ package RJK::TotalCmd::Settings::Inc
Total Commander =TOTALCMD.INC= file.

=cut

package RJK::TotalCmd::Settings::Inc;

use RJK::TotalCmd::Item::InternalCmd;

use Exception::Class (
    'Exception',
    'RJK::TotalCmd::Exception' =>
        { isa => 'Exception' },
    'RJK::TotalCmd::Settings::Inc::Exception' =>
        { isa => 'RJK::TotalCmd::Exception' },
);

###############################################################################
=pod

---++ Object Creation

---+++ new([$path]) -> RJK::TotalCmd::Settings::Inc
Returns a new =RJK::TotalCmd::Settings::Inc= object.

=cut
###############################################################################

sub new {
    my $self = bless {}, shift;
    $self->{path} = shift;
    return $self;
}

###############################################################################
=pod

---+++ read($path) -> $inc
Read data from file. Returns false on failure, callee on success.

---+++ write($path) -> $inc
Write data to file. Returns false on failure, callee on succes.

=cut
###############################################################################

sub read {
    my $self = shift;
    $self->{commands} = [];
    $self->{categories} = [];
    $self->{byCategory} = {};
    $self->{byName} = {};
    $self->{byNumber} = {};

    my $category;
    open(my $fh, '<', $self->{path}) or return;
    while (<$fh>) {
        if (/^\[_+(.+?)_+\]=0$/) {
            $category = $1;
            push @{$self->{categories}}, $1;
        } elsif (/^(.+)=(-?\d+);\s*(.*)\s*$/) {
            my $cmd = new RJK::TotalCmd::Item::InternalCmd(
                name => $1,
                number => $2,
                menu => $3,
            );
            push @{$self->{commands}}, $cmd;
            push @{$self->{byCategory}{$category}}, $cmd;
            $self->{byName}{$1} = $cmd;
            $self->{byNumber}{$2} = $cmd;
        }
    }
    close $fh;

    return $self;
}

sub write {
    my ($self) = @_;

    open(my $fh, '>', "$self->{path}~") or return;
    my $c;
    foreach my $category (@{$self->{categories}}) {
        print $fh "\n" if $c++;
        printf $fh "[%s%s%s]=0\n", '_'x16, $category, '_'x16;
        foreach (@{$self->{byCategory}{$category}}) {
            printf $fh "%s=%s;%s\n", $_->{name}, $_->{number}, $_->{description};
        }
    }
    close $fh;

    return $self;
}

###############################################################################
=pod

---++ Other methods

---+++ categories() -> @names or \@names
Get category names.

---++++ getCommand($nr) -> $command
Get internal command by number.
Returns =undef= if not found.

---++++ getCommandByName($name) -> $command
Get internal command by name.
Returns =undef= if not found.

---++++ getCommands([$category]) -> \@commands
Get commands in =$category=.
Get all internal commands if =$category= is undefined.
Returns =undef= if not found.

=cut
###############################################################################

sub categories {
    my $categories = shift->{categories};
    wantarray ? @$categories : $categories;
}

sub getCommand {
    my ($self, $nr) = @_;
    return $self->{byNumber}{$nr};
}

sub getCommandByName {
    my ($self, $name) = @_;
    return $self->{byName}{$name};
}

sub getCommands {
    my ($self, $category) = @_;
    if ($category) {
        return $self->{byCategory}{$category};
    } else {
        return $self->{commands};
    }
}

1;
