use strict;
use warnings;

use File::Search qw(Files);

#~ my $dataFile = FindDataFile("comments_2018.txt", ['c:\docs\notes']) or die "No comments file found";
#~ my $dataFiles = FindDataFiles(/comments_\d+\.txt/, ['c:\docs\notes']);
#~ print "File: $dataFile\n";

my @paths = Files(
   in => 'c:\docs\notes',
   filter => sub { /comments/ },
   #~ orderBy => 'name',
   #~ orderBy => 'size',
   #~ orderBy => 'date',
   #~ orderBy => 'adate',
   #~ orderBy => 'cdate',
   #~ orderReversed => 1,
   visit => sub { print "Filename: $_\n" },
   visitPath => sub { print "Path: $_\n" },
);
if (!@paths) {
   die "No files found";
}
foreach (@paths) {
   print "$_\n";
}

