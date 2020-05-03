use RJK::File::PathInfo qw(:ALL);

    #~ my $filepath = "V:\\"; # not a file
    #~ my $filepath = "V:\\file.a.ext";
    #~ my $filepath = "V:\\file.a.ext~";
    my $filepath = "V:\\.file.a.ext~";
    #~ my $filepath = "V:\\.hidden";

    my ($volume, $directories, $file) = splitpath($filepath);
    my $catdir = catdir($volume, $directories);

    print "volume:      $volume\n";
    print "directories: $directories\n";
    print "file:        $file\n";
    print "catdir:      $catdir\n";

    my $filename = filename($filepath);
    my $directory = directory($filepath);
    my ($basename, $extension) = splitname($filepath);

    print "directory:   $directory\n";
    print "filename:    $filename\n";
    print "basename:    $basename\n";
    print "extension:   $extension\n";

    $basename = basename($filepath);
    $extension = extension($filepath);
    my $hidden = hidden($filepath);

    print "basename:    $basename\n";
    print "extension:   $extension\n";
    print "hidden:      $hidden\n";
