#! /usr/bin/perl -w

use strict;
use warnings;

use RSTools;

my $set = $ARGV[0] || 'AS-LONAP';

my @pfxlist = RSTools::getFilterPfx4($set);

print "# IPV4:\n";
foreach my $pfx (@pfxlist)
{
  print $pfx . "\n";
}

my @pfxlistsix = RSTools::getFilterPfx6($set);

print "\n\n# IPv6:\n";
foreach my $pfx (@pfxlistsix)
{
  print $pfx . "\n";
}



print " # Donezo\n";

