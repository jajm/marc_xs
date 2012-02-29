#!/usr/bin/perl

use ExtUtils::testlib;
use Modern::Perl;
use Time::HiRes qw/gettimeofday tv_interval/;
use MARC::Field;
use MARC::XS;

my @subfields;
for(my $i=0; $i<10000; $i++) {
	push @subfields, 'a', 'hahaha';
}

#my $start = gettimeofday;
#for(my $i=0; $i<10000; $i++) {
#	my $f = MARC::Field->new(245, '1', '0', @subfields);
#}
#my $end = gettimeofday;
#my $elapsed = tv_interval([$start], [$end]);
#say "$elapsed s elapsed";

#my $start = gettimeofday;
#for(my $i=0; $i<10000; $i++) {
#	my $f = MARC::XS::Field->new(245, '1', '0', @subfields);
#}
#my $end = gettimeofday;
#my $elapsed = tv_interval([$start], [$end]);
#say "$elapsed s elapsed";

my $start = gettimeofday;
for(my $i=0; $i<10000000; $i++) {
	my $f = MARC::XS::Subfield->new('a', 'Yoooooohoooo');
}
my $end = gettimeofday;
my $elapsed = tv_interval([$start], [$end]);
say "$elapsed s elapsed";
