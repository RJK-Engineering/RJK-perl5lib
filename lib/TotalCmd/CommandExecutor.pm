=begin TML

---+ package TotalCmd::CommandExecutor
Utility for executing =TotalCmd::Command=s.
Constructs a command string for a file selection and executes the command
using =system()= or invokes a callback subroutine.

---++ Example

<verbatim>
use TotalCmd::Command;
use TotalCmd::CommandExecutor;
use Try::Tiny;

my $cmd = new TotalCmd::Command(
    menu => "Name",
    cmd => "cmd",
    param => "/c dir %P%N",
);

try {
    my $ce = TotalCmd::CommandExecutor->new;
    my $exitcode = $ce->execute(
        $cmd, {
            source => "C:\\",
            target => undef,
            sourceSelection => [],
            targetSelection => [],
            sourceList => undef,
            targetList => undef,
        }, sub {
            my ($cmd, $args) = @_;
            print "$cmd $args\n";
            system "$cmd $args";
        }
    );
} catch {
    if ( $_->isa('TotalCmd::Command::UnsupportedParameterException') ) {
        warn sprintf "UnsupportedParameterException: %s", $_->parameter();
    } elsif ( $_->isa('TotalCmd::Command::FileException') ) {
        warn sprintf "FileException - %s: %s", $_->error, $_->path();
    } elsif ( $_->isa('TotalCmd::CommandException') ) {
        warn sprintf "CommandException - %s.", $_->error();
    } else {
        die $_;
    }
};
</verbatim>

=cut

package TotalCmd::CommandExecutor;

use strict;
use warnings;

use File::Spec::Functions qw(rel2abs splitpath catpath);
use TotalCmd::Utils;
use Win32;

use Exception::Class (
    'Exception',
    'TotalCmd::CommandException' =>
        { isa => 'Exception' },
    'TotalCmd::Command::UnsupportedParameterException' =>
        { isa => 'TotalCmd::CommandException',
          fields => ['parameter'] },
    'TotalCmd::Command::InsufficientDataException' =>
        { isa => 'TotalCmd::CommandException' },

    'TotalCmd::Command::NoSourceException' =>
        { isa => 'TotalCmd::Command::InsufficientDataException' },
    'TotalCmd::Command::NoTargetException' =>
        { isa => 'TotalCmd::Command::InsufficientDataException' },

    'TotalCmd::Command::FileException' =>
        { isa => 'TotalCmd::Command::InsufficientDataException',
          fields => ['path'] },
    'TotalCmd::Command::ListFileException' =>
        { isa => 'TotalCmd::Command::FileException' },
    'TotalCmd::Command::NoSourceFileException' =>
        { isa => 'TotalCmd::Command::FileException' },
    'TotalCmd::Command::NoTargetFileException' =>
        { isa => 'TotalCmd::Command::FileException' },
    'TotalCmd::Command::NoSourceShortNameException' =>
        { isa => 'TotalCmd::Command::FileException' },
    'TotalCmd::Command::NoTargetShortNameException' =>
        { isa => 'TotalCmd::Command::FileException' },

    'TotalCmd::Command::NoSelectionException' =>
        { isa => 'TotalCmd::Command::InsufficientDataException' },
    'TotalCmd::Command::NoSourceSelectionException' =>
        { isa => 'TotalCmd::Command::NoSelectionException' },
    'TotalCmd::Command::NoTargetSelectionException' =>
        { isa => 'TotalCmd::Command::NoSelectionException' },
);

###############################################################################
=pod

---++ Object methods

---+++ new() -> TotalCmd::CommandExecutor

=cut
###############################################################################

sub new {
    my $self = bless {}, shift;
    return $self;
}

my $directoryParams = 'PpTt';
my $filenameParams = 'NnMm';
my $fileParams = $filenameParams.'OoEe';
my $shortParams = 'ptnmoesr';

my $sourceParams = 'PpNnOoEe';
my $targetParams = 'TtMm';
my $listFileParams = 'LlFfDd';
my $sourceArgsParams = 'Ss';
my $targetArgsParams = 'Rr';
my $argsParams = $sourceArgsParams.$targetArgsParams;
my $allParams = $sourceParams.$targetParams.$listFileParams.$argsParams;
my $modifierParams = 'ZzX';

###############################################################################
=pod

---+++ execute($cmd, $selection, $callback)

Constructs a command string for a file selection and optionally execute the command.
Invokes =$callback= if defined, executes the command using =system()= otherwise.
Throws whatever =getParams()= throws.

   * =$cmd= - the =TotalCmd::Command= to execute
   * =$selection->{source}= - source file or directory
   * =$selection->{sourceList}= - source list file
   * =$selection->{sourceSelection}= - reference to array of source files or directories
   * =$selection->{target}= - target file or directory
   * =$selection->{targetList}= - target list file
   * =$selection->{targetSelection}= - reference to array of target files or directories
   * =$callback= - reference to array of target files or directories

=cut
###############################################################################

sub execute {
    my ($self, $cmd, $selection, $callback) = @_;
    $callback //= sub { system @_ };

    if ($cmd->{param}) {
        my $params = $self->getParams($cmd, $selection);
        my $argStr = $self->getArgStr($cmd, $params);
        $callback->($cmd->{cmd}, $argStr);
        $self->finish($params);
    } else {
        $callback->($cmd->{cmd});
    }
}

###############################################################################
=pod

---+++ getParams($selection) -> \%params
Get parameter values.

Throws:%BR%
(additional =[[https://metacpan.org/pod/Exception::Class][Exception::Class]]= fields between parenthesis)
   * =TotalCmd::CommandException=
      * =TotalCmd::Command::UnsupportedParameterException= (parameter)
      * =TotalCmd::Command::InsufficientDataException=
         * =TotalCmd::Command::NoSourceException=
         * =TotalCmd::Command::NoTargetException=
         * =TotalCmd::Command::FileException= (path)
            * =TotalCmd::Command::ListFileException= (path)
            * =TotalCmd::Command::NoSourceFileException= (path)
            * =TotalCmd::Command::NoTargetFileException= (path)
            * =TotalCmd::Command::NoSourceShortNameException= (path)
            * =TotalCmd::Command::NoTargetShortNameException= (path)
         * =TotalCmd::Command::NoSelectionException=
            * =TotalCmd::Command::NoSourceSelectionException=
            * =TotalCmd::Command::NoTargetSelectionException=

=cut
###############################################################################

sub getParams {
    my ($self, $cmd, $selection) = @_;
    my %params;

    if ($cmd->{param} && $cmd->{param} =~ /%/) {
        if ($cmd->{param} =~ /[^%]%([^%$allParams$modifierParams])/) {
            throw TotalCmd::Command::UnsupportedParameterException(
                error => "Unsupported parameter: $1",
                parameter => $1,
            );
        }
    } else {
        return \%params;
    }

    # under cursor
    my $source = $selection->{source} // $selection->{sourceSelection}[0];
    my $target = $selection->{target} // $selection->{targetSelection}[0];

    # selections in list files
    $params{sourceListFile} = $selection->{sourceList};
    $params{targetListFile} = $selection->{targetList};

    # source parameters
    my ($long, $short, $dir, $file, $name, $extension);
    if ($cmd->{param} =~ /%[$sourceParams]/) {
        if (! defined $source) {
            throw TotalCmd::Command::NoSourceException("No source specified");
        }

        ($source, $short) = GetPaths($source);
        ($dir, $file, $name, $extension) = ParsePath($source);

        $params{P} = $dir;
        if ($file ne '') {
            $params{N} = $file;
            $params{O} = $name;
            $params{E} = $extension;
        } elsif ($cmd->{param} =~ /%[$fileParams]/) {
            throw TotalCmd::Command::NoSourceFileException(
                error => "No source file specified",
                path => $source,
            );
        }

        if ($short) {
            ($dir, $file, $name, $extension) = ParsePath($short);
            $params{p} = $dir;
            if ($file ne '') {
                $params{n} = $file;
                $params{o} = $name;
                $params{e} = $extension;
            }
        } elsif ($cmd->{param} =~ /%[$shortParams]/) {
            throw TotalCmd::Command::NoSourceShortNameException(
                error => "Source short name could not be determined",
                path => $source,
            );
        }
    }

    # source selection as list file parameters
    if (my $listType = ($cmd->{param} =~ /%([$listFileParams])/)) {
        if (! $selection->{sourceList}) {
            if (! $selection->{sourceSelection}) {
                throw TotalCmd::Command::NoSourceSelectionException(
                    "No source selection specified");
            }

            # create list file
            my ($fh, $error);
            ($fh, $params{sourceListFile}, $error) = TotalCmd::Utils::tempFile();
            if ($error) {
                if (defined $params{sourceListFile}) {
                    throw TotalCmd::Command::ListFileException(
                        error => $error,
                        path => $params{sourceListFile},
                    );
                }
                throw TotalCmd::CommandException(
                    error => $error,
                );
            }
            print $fh "$_\n" foreach @{$selection->{sourceSelection}};
            close $fh;
        }

        if ($params{sourceListFile}) {
            $params{$_} = $params{sourceListFile} foreach split //, $listFileParams;
        }
    }

    # source selection as arguments parameters
    if ($cmd->{param} =~ /%[$sourceArgsParams]/) {
        if (! $selection->{sourceSelection}) {
            throw TotalCmd::Command::NoSourceSelectionException(
                "No source selection specified");
        }

        foreach (@{$selection->{sourceSelection}}) {
            ($long, $short) = GetPaths($_);
            ($dir, $file) = ParsePath($long);

            push @{$params{S}},
                defined $params{P} && $dir ne $params{P} ?
                    "$params{P}$file" : $file;

            if ($short) {
                ($dir, $file) = ParsePath($short);
                push @{$params{s}},
                    defined $params{p} && $dir ne $params{p} ?
                        "$params{p}$file" : $file;
            } elsif ($cmd->{param} =~ /%[$shortParams]/) {
                throw TotalCmd::Command::NoSourceShortNameException(
                    error => "Source short name could not be determined",
                    path => $_,
                );
            }
        }
    }

    # target selection as arguments parameters
    if ($cmd->{param} =~ /%[$targetArgsParams]/) {
        if (! $selection->{targetSelection}) {
            throw TotalCmd::Command::NoTargetSelectionException(
                "No target selection specified");
        }
        foreach (@{$selection->{targetSelection}}) {
            ($long, $short) = GetPaths($_);
            ($dir, $file) = ParsePath($long);

            push @{$params{R}},
                defined $params{T} && $dir ne $params{T} ?
                    "$params{T}$file" : $file;

            if ($short) {
                ($dir, $file) = ParsePath($short);
                push @{$params{r}},
                    defined $params{t} && $dir ne $params{t} ?
                        "$params{t}$file" : $file;
            } elsif ($cmd->{param} =~ /%[$shortParams]/) {
                throw TotalCmd::Command::NoTargetShortNameException(
                    error => "Target short name could not be determined",
                    path => $_,
                );
            }
        }
    }

    # target parameters
    if ($cmd->{param} =~ /%[$targetParams]/) {
        # second argument is target if no list param
        $target //= shift @ARGV if $cmd->{param} !~ /%[$listFileParams$sourceArgsParams]/;

        if (! defined $target) {
            throw TotalCmd::Command::NoTargetException("No target specified");
        }

        ($target, $short) = GetPaths($target);
        ($dir, $file) = ParsePath($target);

        $params{T} = $dir;
        if ($file ne '') {
            $params{M} = $file;
        } elsif ($cmd->{param} =~ /%[$fileParams]/) {
            throw TotalCmd::Command::NoTargetFileException(
                error => "No target file specified",
                path => $source,
            );
        }

        if ($short) {
            ($dir, $file) = ParsePath($short);
            $params{t} = $dir;
            $params{m} = $file if $file ne '';
        } elsif ($cmd->{param} =~ /%[$shortParams]/) {
            throw TotalCmd::Command::NoTargetShortNameException(
                error => "Target short name could not be determined",
                path => $source,
            );
        }
    }

    return \%params;
}

###############################################################################
=pod

---+++ getArgStr($params) -> $argString
Returns parameter string with parameters substituted which can be
used for command execution.

=cut
###############################################################################

sub getArgStr {
    my ($self, $cmd, $params) = @_;

    my $quote = sub {
        $_[0] =~ /\s/ ? qq("$_[0]") : $_[0];
    };

    my $s = "";
    my $param = $cmd->{param};

    while ($param =~ s/
        (?<text> .*?) %
        (?:
              (?<dir1>  [$directoryParams]) % (?<file1> [$filenameParams])
            | (?<dir2>  [$directoryParams]) % (?<args1> [$argsParams])
            |           [$modifierParams]   % (?<dir3>  [$directoryParams])
            | (?<file2> [$filenameParams])
            | (?<args2> [$argsParams])
            | (?<any>   [$allParams])
            | (?<pct>   %)
            | (?<other> .)
        ) //x
    ) {
        $s .= $+{text};
        if ($+{dir1}) {
            $s .= $quote->($params->{$+{dir1}}.$params->{$+{file1}});
        } elsif ($+{dir2}) {
            my $dir = $params->{$+{dir2}};
            my $files = $params->{$+{args1}};
            $s .= join " ", map { $quote->($dir.$_) } @$files;
        } elsif ($+{dir3}) {
            $s .= $params->{$+{dir3}};
        } elsif ($+{file2}) {
            $s .= $quote->($params->{$+{file2}});
        } elsif ($+{args2}) {
            my $files = $params->{$+{args2}};
            $s .= join " ", map { $quote->($_) } @$files;
        } elsif ($+{any}) {
            $s .= $params->{$+{any}};
        } elsif ($+{pct}) {
            $s .= '%';
        } else {
            throw TotalCmd::Command::UnsupportedParameterException($+{other});
        }
    }
    return $s.$param;
}

###############################################################################
=pod

---+++ finish($params)
Removes temp files.

=cut
###############################################################################

sub finish {
    my ($self, $params) = @_;
    if ($params->{sourceListFile}) {
        unlink $params->{sourceListFile}
        ||
        throw TotalCmd::Command::ListFileException(
            error => "$!",
            path => $params->{sourceListFile},
        );
    }
}

###############################################################################
=pod

---++ Class methods

---+++ GetPaths($path) -> ($longPath, $shortPath)
Returns absolute long and short path names. Converts a relative path
to an absolute path and makes sure a directory name ends with a =\=.

=cut
###############################################################################

sub GetPaths {
    my $isDir = $_[0] =~ /[\/\\]$/;
    my $long = rel2abs($_[0]);
    my $short = Win32::GetShortPathName($long);
    if ($isDir || -d $long) {
        $long .= "\\";
        $short .= "\\";
    }
    return ($long, $short);
}

###############################################################################
=pod

---+++ ParsePath($path) -> ($dir, $file, $name, $extension)
   * =$path= - full path to a file or a directory
   * =$dir= - full path to directory part
   * =$file= - filename part
   * =$name= - filename without extension
   * =$extension= - filename extension

=cut
###############################################################################

sub ParsePath {
    my ($volume, $directories, $file) = splitpath($_[0]);
    my $dir = catpath($volume, $directories, '');
    my ($name, $extension) = ($file =~ /^(.+)\.([^\.]+)$/);
    $name //= $file;
    $extension //= '';
    return ($dir, $file, $name, $extension);
}

1;
