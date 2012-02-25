package MARC::XS;

our $VERSION = '0.01';

use Modern::Perl;
use XSLoader;

XSLoader::load('MARC::XS', $VERSION);

1;
