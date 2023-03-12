while(<>) {
	s/[^A-Z]+/ /gi;
	s/^\s+|\s+$//gsm;
	print uc $_;
	print "\n";
}