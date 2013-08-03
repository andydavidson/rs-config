#!/usr/bin/perl -w

use strict;
use warnings;
use Getopt::Std;

my %options=();
getopts("c:t:",\%options);

if (!$options{c})
{
  die "Incorrect config, use ./ASBuild -c config-file";
}

my %uniqueasn;
my %uniqueasn6;

### open config file, load data about each neighbor
open (my $CONFIG, $options{c});
while (<$CONFIG>)
{
  chomp;
  next if /^#/;
  my ($neigh,$asn,$set,$desc) = split(/,/, $_);

  my $nblock = {
                 neighbor => $neigh,
  		 asn      => $asn,
		 set      => $set,
		 desc     => $desc,
               };

  if ($neigh =~ /\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b/)
  {
    $uniqueasn{$asn} = "$set"; 
  } elsif ($neigh =~ /\:/) 
  {
    $uniqueasn6{$asn} = "$set";
  }
}

## generate list of unique asn
my @uniqueasn  = sort keys %uniqueasn;
my @uniqueasn6 = sort keys %uniqueasn6;

foreach (@uniqueasn) 
{
  print "members: AS".$_;
  if ($uniqueasn{$_})
  {
    print ", ".$uniqueasn{$_};
  }
  print "\n";
}


print "\n\n\n\n\nLONAP v6 peers:\n";
foreach (@uniqueasn6)
{
  print "members: AS".$_;
  if ($uniqueasn6{$_})
  {
    print ", ".$uniqueasn6{$_};
  }
  print "\n";
}

