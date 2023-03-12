#!/usr/bin/perl

unshift @INC, ('.');
require 'SubCipher.pl';

$word = "we'll";
$patterns = load_patterns();
$key = {};

print "$word\n";
print join '|', fetch_patterns($key,$patterns,$word);
print "\n";