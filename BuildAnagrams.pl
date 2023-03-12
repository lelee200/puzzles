#!/usr/bin/perl

unshift @INC, ('.');
require 'AnagramUtils.pl';

while (<>) {
	chomp;
	s/\W+//g;
	$_ = uc $_;
	my $key = AnagramCanonize($_);
	my $already = $Sets{$key};
	$Sets{$key} = $already ? "$already,$_" : $_;
}
foreach (sort keys %Sets) {
	print "$_:".$Sets{$_}."\n";
}
