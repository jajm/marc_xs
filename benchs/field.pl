#!/usr/bin/perl

use ExtUtils::testlib;
use Modern::Perl;
use Time::HiRes qw/gettimeofday tv_interval/;
use MARC::Field;
use MARC::XS;

my $nb_subfields = 1;
my $nb_fields = 1000000;

my ($start, $end, $elapsed);

while($nb_fields >= 1) {
	say "Creating $nb_fields fields with $nb_subfields subfields each";
	my @subfields;
	for(my $i=0; $i<$nb_subfields; $i++) {
		push @subfields, 'a', 'h';
	}

	$start = gettimeofday;
	for(my $i=0; $i<$nb_fields; $i++) {
		my $f = MARC::Field->new(245, '1', '0', @subfields);
	}
	$end = gettimeofday;
	$elapsed = tv_interval([$start], [$end]);
	say "MARC::Field::new: $elapsed seconds elapsed";

	$start = gettimeofday;
	for(my $i=0; $i<$nb_fields; $i++) {
		my $f = MARC::XS::Field->new(245, '1', '0', @subfields);
	}
	$end = gettimeofday;
	$elapsed = tv_interval([$start], [$end]);
	say "MARC::XS::Field::new: $elapsed seconds elapsed";

	$nb_subfields *= 10;
	$nb_fields /= 10;

	print "\n";
}
