#!/usr/bin/perl
use File::Spec::Functions 'catfile';

sub decrypt_string {
  my $key = shift;
  my $text = uc shift;
  my $retval;
  foreach (split //, $text) {
    if (/[A-Z]/) {
      my $letter = $key->{$_};
      $retval .= $letter ? $letter : ".";
    } else {
      $retval .= $_;
    }
  }
  return $retval;
}

sub load_patterns {
	my $patterns;
	my $wlPath = $ENV{WORDLIST_PATH};
	$wlPath = '.' unless $wlPath =~ /\w/;
	my $fname = "Patterns_en_us.txt";
	my $fqName = catfile($wlPath, $fname);
	
	open PATTERNS, $fqName or die "could not open $fqName"; 
	while(<PATTERNS>) {
		chomp;
		$patterns->{"$1"} = $2 if /([\w']+);([;a-z']+)/i;
	}
	close PATTERNS;
	return $patterns;
}

sub load_cipher {
	my $filename = shift;
	my $key = {"'" => "'"};
	my %seenB4;
	open INFILE, $filename or die "Could not open $filename\n";
	my $lineNo = 0;
	while (<INFILE>) {
  		++$lineNo;
		if (/([A-Z])([A-Z])/) {
			$mapper = $1;
    		$mapped = $2;
    		print STDERR "Duplicate Mapped $mapped at line $lineNo($seenB4{$mapped})\n" if $seenB4{$mapped};
    		print STDERR "Duplicate Mapper $mapper at line $lineNo\n" if $key->{$mapper};
      	$key->{$mapper} = $mapped;
      	$seenB4{$mapped} = $lineNo;
    	}
	}
	close INFILE;
	return $key;
}

sub slurp_message {
  my $filename = shift;
  open INFILE, $filename or die "Could not open $filename\n";
  local $/;
  my $retval = <INFILE>;
  close INFILE;
  return $retval;
}

sub count_letters {
  my $text = shift;
  my @prev;
  $Letters;
  foreach (split //, $text) {
    unless (/[A-Z]/) {
      $Lasts->{$prev}++ if $prev;
      undef $prev;
      undef $prevPrev;
      next;
    }
    $Letters->{$_}++;
    $Total++;
    if ($prev) {
      $Digraphs->{$prev.$_}++;
      $Doubles->{$_.$_}++ if $_ eq $prev;
      if ($prevPrev) {
        $Trigraphs->{$prevPrev.$prev.$_}++;
      }
    } else {
      $Firsts->{$_}++;
    }
    $prevPrev = $prev;
    $prev = $_;
  }
  foreach (split /\W+/, $text) {
    $Words->{$_}++;
  } 
}

sub by_count {
  return $GlobRef->{$b} <=> $GlobRef->{$a};
}

sub print_hash {
  local $GlobRef = shift;
  my $title = shift;
  my $threshold = shift;
  my $max = shift;
  $max = 60 unless $max;
  $threshold = 1 unless $threshold;
  my $index = 1;
  print "\t$title (%)\n";
  foreach (sort by_count keys %$GlobRef) {
    last if $GlobRef->{$_} < $threshold;
    print sprintf "$_:%d ", (100 * $GlobRef->{$_} / $Total);
    print "\n" unless $index++ % 12;
    last if $index >= $max;
  }
  print "\n" if ($index-1) %8;
}

sub CryptCanonize {
	local $_ = lc $_[0];
	my $count = 65;
	my %assign = ("'" => "'");
	my $canon = '';
	foreach(split //) {
		next unless /[a-z']/; #'
		my $code = $assign{$_};
		unless (defined $code) {
			$code = chr($count++);
			$assign{$_} = $code;
		}
		$canon .= $code;
	}
	return $canon;
}

sub fetch_patterns {
	my $cipher = shift;
	my $patterns = shift;
	my $word = shift;
	my $expr = '.' x length $word;
	if ($cipher && 0 < %$cipher) {
		$expr = lc decrypt_string ($cipher, $word);
		my $notexpr = lc '[^'.(join '', sort values %$cipher).']';
		$notexpr = '.' unless 3 < length $notexpr;
		$expr =~ s/\./$notexpr/g;
	}
	my $key = CryptCanonize($word);
	my @retVal;
	foreach (split /;/, $patterns->{$key}) {
		push @retVal, ($_) if /$expr/;
	}
	return @retVal;
}

1
