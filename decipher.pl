#!/usr/bin/perl

unshift @INC, ('.');
require 'SubCipher.pl';

if ($#ARGV < 0) {
  print "$0 <messge> \[<keyfile> \[go\]\]\n";
  exit 0;
}

$patterns = load_patterns();

$msg = slurp_message($ARGV[0]);

if (0 < $#ARGV) {
  $key = load_cipher($ARGV[1]);
}

count_letters("$msg ");
my $threshold = $Total * 0.05;
print_hash($Letters, "Letters", $Threshold);
#@lists = qw/Firsts Lasts Doubles Digraphs Trigraphs Words/;
@lists = qw/Doubles Words/;
foreach (@lists) {
  print_hash(${$_}, $_, 1, 8);
}

print "\n";

while (1) {
	my %AddCipher;
	foreach (split /[\r\n]+/, $msg) {
		print "$_\n";
		my $s;
		$s = decrypt_string ($key, $_);
		print $s;
		my $index = 0;
		@s = split /[^\w.']+/, $s; #'
		foreach (split /[^\w']+/) { #'
			if ($s[$index++] =~ /\./) {
				my @list = fetch_patterns($key,$patterns,$_);
				$cnt = 1 + $#list;
				if (15 >= $cnt) {
					print "\n\t$_:".join '|', @list
				} else {
					print "\n\t$_:$cnt";
				}
				if (1 == @list) {
					my @ins = split //;
					my @outs = split //, uc $list[0];
					for (my $index = 0; $index <= $#ins; ++$index) {
						my $in = $ins[$index];
						my $out = $outs[$index];
						next if $AddCipher{$in} || $key->{$in};
						$AddCipher{$in} = $out;
					}
				}
			}
		}
		print "\n\n";
	}

	last if 0 == %AddCipher;
	
	print "Add to Cipher:\n";
	foreach(keys %AddCipher) {
		print "$_$AddCipher{$_}\n";
		$key->{$_} = $AddCipher{$_};
	}
	if (0 < $#ARGV) {
		print "Writing back to $ARGV[1]\n";
		open CIPHER, ">>$ARGV[1]" or die "Could not append to $ARGV[1]\n";
		print CIPHER "\n";
		foreach(keys %AddCipher) {
			print CIPHER "$_$AddCipher{$_}\n";
		}	
		close CIPHER;
	}
	last if 2 > $#ARGV;
}