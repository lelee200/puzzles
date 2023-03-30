#!/usr/bin/perl

unshift @INC, ('.');
require 'SubCipher.pl';

if ($#ARGV < 1) {
  print "$0 <messge> <guess>\n";
  exit 0;
}

$guess = CryptCanonize(uc pop @ARGV);
#print "Pattern: $guess\n";
while (<>) {
    chomp;
    foreach $word (split /\s+/) {
        print "$word\n" if  CryptCanonize(uc $word) eq $guess;
    }
}