use RJK::TotalCmd::Search;

my $conf = {
    name => '.video',
    SearchFor => '*.avi *.divx *.flv *.m1v *.m2v *.m4v *.mov *.mp1v *.mp2v *.mpe *.mpeg *.mpg *.mps *.mpv *.mpv1 *.mpv2 *.mkv *.ogm *.ogv *.vob *.wmv *.mp4 *.webm',
    SearchIn => '>',
    SearchText => '',
    SearchFlags => '0|000002000020||||||||22220|0000|',
};

my $s = new RJK::TotalCmd::Search(%$conf);

use Data::Dump;
dd($s);
