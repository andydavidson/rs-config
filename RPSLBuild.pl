#!/usr/bin/perl -w

#### This is the script to build RPSL filters, and not
#    the route-server config.
#

use strict;
use warnings;
use Template;
use Getopt::Std;

my %options=();
getopts("c:t:",\%options);

if ((!$options{c}) || (!$options{t}))
{
  die "Incorrect config, use ./RPSLBuild -c config-file -t template-file";
}

my @neighbors;
my @filterlist;
my @neighbors6;
my @filterlist6;
my @pfxlist;
my %uniqueasn4;
my %uniqueasn6;
my %uniqueip;

### open config file, load data about each neighbor
open (my $CONFIG, $options{c});
while (<$CONFIG>)
{
  chomp;
  # skip comments:
  next if /^#/;
  # skip blank lines:
  next if /^$/;
  my ($neigh,$asn,$set,$desc) = split(/,/, $_);
  next unless ($neigh);

  my $nblock = {
                 neighbor => $neigh,
  		 asn      => $asn,
		 set      => $set,
		 desc     => $desc,
               };

  if ($uniqueip{$neigh}) {

	  print STDERR "WARNING: duplicate neighbor configured for $neigh - skipping $neigh - $asn\n";
	  next;

  }



  if ($neigh =~ /\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b/)
  {
    next if $uniqueasn4{$asn};
    push @neighbors, $nblock;
    $uniqueasn4{$asn} = "r";
    $uniqueip{$neigh} = "r";

  } elsif ($neigh =~ /\:/) 
  {
    next if $uniqueasn6{$asn};
    push @neighbors6, $nblock;
    $uniqueasn6{$asn} = "r";
    $uniqueip{$neigh} = "r";
  }
}

###template toolkit needs the data in a hash

my %tplvalues;
   $tplvalues{neighbors}   = \@neighbors;
   $tplvalues{filterlist}  = \@filterlist;
   $tplvalues{neighbors6}  = \@neighbors6;
   $tplvalues{filterlist6} = \@filterlist6;

 #use Data::Dumper;
 #warn Dumper %tplvalues;

# process the template
my $tt = Template->new;
   $tt->process($options{t}, \%tplvalues);


