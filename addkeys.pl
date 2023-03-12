#!/usr/bin/perl

unshift @INC, ('.');
require 'SubCipher.pl';

if ($#ARGV < 2) {
  print "$0 <keyfile> <encrypted> <clear>\n";
  exit 0;
}

$key = load_cipher($ARGV[0]);
$argIndex = 2;
while ($argIndex<=$#ARGV) {
	my @ins = split //, uc $ARGV[$argIndex-1];
	my @guess = split //, uc $ARGV[$argIndex];
	for (my $index = 0; $index <= $#ins; ++$index) {
		my $in = $ins[$index];
		my $out = $guess[$index];
		if ($AddCipher{$in}) {
			next if $out eq $AddCipher{$in};
			print STDERR "multiple values per key: $in -> $out,$AddCipher{$in}";
		}
		if ($key->{$in}) {
			next if $out eq $key->{$in};
			print STDERR "multiple values per key: $in -> $out,$key->{$in}";
		}
		$AddCipher{$in} = $out;
	}
	$argIndex += 2;
}

if (0 < %AddCipher) {
	print "Add to Cipher:\n";
	foreach(keys %AddCipher) {
		print "$_$AddCipher{$_}\n";
	}
	print "Writing to $ARGV[0]\n";
	open CIPHER, ">>$ARGV[0]" or die "Could not append to $ARGV[0]\n";
	print CIPHER "\n";
	foreach(keys %AddCipher) {
		print CIPHER "$_$AddCipher{$_}\n";
	}	
	close CIPHER;
}
