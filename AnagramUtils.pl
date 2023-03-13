#!/usr/bin/perl
use File::Spec::Functions 'catfile';

# AnagramCanonize())
# Sort letters in a word as canonical anagram
# 2 words are anagrams of each other if they have the same canonical anagram
# Params: (string) word
# returns (string) all letters sorted in ascending order
sub AnagramCanonize {
	my @ar = split //, $_[0];
	@ar = sort @ar;
	return join '', @ar; 
}

# CanonSubstring()
# Establish whether a canonical anagram is a subset of another canonical anagram
# Params: (string) Container - canonical anagram hosting smaller canonical anagram
#				(string) pattern - smaller canonical anagram to check bigger canonical anagram
# Returns: (string)
#	* - pattern not a subset of container
#	(otherwise) - remaining letters after pattern letters removed from container
sub CanonSubstring {
	my @remainder;
	my @container = split //, shift;
	my @pattern = split //, shift;
	while (@container && @pattern) {
		return '*' if @container < @pattern;
		if ($container[0] eq $pattern[0]) {
			shift @container;
			shift @pattern;
		} elsif ($container[0] lt $pattern[0]) {
			push @remainder, (shift @container);
		} else {
			return '*'
		}
	}
	return '*' if @pattern;
	push @remainder, @container;
	return join '', @remainder;
}

sub IsRealWord {
	my $word = uc shift;
	my $canon = AnagramCanonize();
	my $list = $Canons{$canon};
	return 1 if $list && $list =~ /$word/;
	return 0;
}

# LoadAnagramCanons()
# load the canonical anagrams hash used by subsequent subs
# Note: the canonical anagrams file is made by running BuildAnagrams with a word list.
# No parameters - filename is hard-coded
# returns none
# Globals:
# @CanonList -list of all canonical anagrams
# %FirstIndex - index of first letters in CanonList
# %Canons - hash mapping canonical form to comma-separated list of real words
sub LoadAnagramCanons {
	my $initial = '';
	my $wlPath = $ENV{WORDLIST_PATH};
	$wlPath = '.' unless $wlPath =~ /\w/;
	my $fname = "Anagrams_en_us.txt";
	my $fqName = catfile($wlPath, $fname);
	open INFILE, "$fqName" or die "Could not load Anagrams list: $fqName\n";
	while (<INFILE>) {
		chomp;
		next unless /(([A-Z])[A-Z]*):([A-Z,]+)/;
		if ($2 ne $initial) {
			$initial = $2;
			$FirstIndex{$initial} = @CanonList;
		}
		$Canons{$1} = $3;
		push @CanonList, ($1);
	}
	close INFILE;
}

# FetchCanonSubsets()
# Get list of canonical subsets with their remainders.
# Parameters: (string) target canonical anagram
#	(optional int) required length of the canonical substrings
# Returns: list of pipe-separated tuples: subset|remainder
sub FetchCanonSubsets {
	my $target = shift;
	my $size = @_ > 0 ? shift : 0;
	my $initial = substr $target, 0, 1;
	my @hitList;
	for (my $index = $FirstIndex{$initial}; $index < @CanonList; $index++) {
		my $candidate = $CanonList[$index];
		next if $size > 0 && length $candidate != $size;
		my $leftover = &CanonSubstring($target,$candidate);
		next if '*' eq $leftover;
		push @hitList, ("$candidate|$leftover");
	}
	return @hitList;
}

# FetchNextCanonSubsets()
# expand canon subset groups based on sized of words
# Parameters (string) current subset 
sub FetchNextCanonSubsets {
	my $prevSubs;
	my $target;
	my $size = 0;
	($prevSubs, $target) = split /\|/, $_[0];
	$size = $& if $prevSubs =~ s/\d+//;
	my @hitList =  ($target, $size);
	return @hitList if 0 == @hitList || !$prevSubs;
	return map { "$prevSubs $_" } @hitList;
}

sub FetchMultiwordAnagrams {
   my $sizes = 1 < @_ ? $_[1] : '';
	my @list = ("$sizes|$_[0]");
	my @result;
	my @retVal;
	while(0 < @list) {
		my $target = shift @list;
		@result = FetchNextCanonSubsets($target);
		foreach (@result) {
			if (/(.+)\|$/) { push @retVal, PermuteMultipleCanons($1); }
			else { push @list, ($_); }
		}
	}
	return @retVal;
}

sub PermuteMultipleCanons {
	my $canons = shift;
	$canons =~ s/^\s+|\s+$//g;
	$canons =~ s/\s+/\|/g;
	my @workingList = ("|$canons");
	my @retVal;
	while (@workingList) {
		my @pieces = split /\|/, shift @workingList;
		my $left = shift @pieces;
		my $subject = shift @pieces;
		my $right = join '|', @pieces;
		$entry = $Canons{$subject};
		next unless $entry;
		my @perms = split /,/, $entry;
		if ($left) {
			@perms = map { "$left $_"; } @perms;
		}
		if ($right) {
			@perms = map { "$_|$right"; } @perms;
			push @workingList, @perms;
		} else {
			push @retVal, @perms;
		}
	}
	return @retVal;
}

1