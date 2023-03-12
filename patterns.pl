#!/usr/bin/perl

unshift @INC, ('.');
require 'SubCipher.pl';

if ($#ARGV < 1) {
  print "$0 <keyfile> \{<word>\}\n";
  exit 0;
}

$cipher = load_cipher(shift @ARGV);
$patterns = load_patterns();

foreach (@ARGV) {
	print "$_:\n";
	foreach (fetch_patterns($cipher,$patterns,$_)) {
		print "\t$_\n";
	}
}