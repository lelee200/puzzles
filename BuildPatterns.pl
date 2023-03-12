#!/usr/bin/perl

unshift @INC, ('.');
require 'SubCipher.pl';

%Dict;
while (<>) {
	next unless /[a-z']+/;
	my $val = $&;
	my $key = CryptCanonize($val);
	my $entry = $Dict{"$key"};
	$entry .= ";$val";
	$Dict{"$key"} = $entry;
}

foreach (sort keys %Dict) {
	print "${_}$Dict{$_}\n";
}