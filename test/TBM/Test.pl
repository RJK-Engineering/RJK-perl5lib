use strict;
use warnings;

# FIXME

use JSON;

use TBM::Store::FileSystem;
#~ use TBM::Document;
use TBM::Factory;

use Data::Dump;

my $json = JSON->new->allow_nonref->convert_blessed->canonical->pretty;
my $store = new TBM::Store::FileSystem(
    contentRoot => "C:\\data\\TBM\\content",
    unfiledDir => "C:\\data\\TBM\\unfiled",
    metadataDir => "C:\\data\\TBM",
);

#~ my $d = TBM::Factory::Document->createInstance($store);
#~ die;

my $file = "index.json";
my $doc = TBM::Factory::JSON->fetchInstanceByPath($store, $file);


if ($doc) {
    dd $doc;
    my $text = join "", $doc->getTextContent();
    my $data = $json->decode($text);
    dd $data;
} else {
    $doc = TBM::Factory::Document::createInstance($store);
    $doc->setName($file);

    my $data = {};
    $doc->setTextContent($json->encode($data));
    $doc->checkIn();

    #~ my $root = TBM::Factory::Folder::fetchRoot($store);
    #~ $root->file($doc);
}
