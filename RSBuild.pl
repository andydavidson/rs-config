#!/usr/bin/perl -w

use strict;
use warnings;
use RSTools;
use Data::Dumper;
use Template;
use Getopt::Std;

my %options=();
getopts("dc:b:m:",\%options);

if ((!$options{c}) || (!$options{b}))
{
  die "Incorrect config, use ./RSBuild -c config-file -b template-build-file";
}

my %tpllist;
my @neighbors;
my @filterlist;
my @neighbors6;
my @filterlist6;
my @pfxlist;
my %uniqueasn;

my $dflmaxpfx = $options{ m} || "100";
warn "Default max-prefix limit is $dflmaxpfx" if $options{ d};

### open template-build file
open (my $TPLBUILD, $options{b});
while (<$TPLBUILD>)
{
  chomp;
  next if /^#/;
  next if /^$/;

  my ($tpl,$outfile) = split(/,/, $_);
  $tpllist{$tpl} = $outfile;
}

### open config file, load data about each neighbor
open (my $CONFIG, $options{c});
while (<$CONFIG>)
{
  chomp;
  next if /^#/;
  next if /^$/;

  my ($neigh,$asn,$set,$desc,$maxpfx) = split(/,/, $_);

  # generate a unique ID for use in the Bird config.
  my $uniqueid;
  if ($neigh =~ /\b\d{1,3}\.\d{1,3}\.(\d{1,3})\.(\d{1,3})\b/) {
    # try to handle cases where neighbor is not in 193.203.5 in a suboptimal way
    if ($1 == "5") {
      $uniqueid = $asn."x".$2;
    } else {
      $uniqueid  = $asn."x".$1."x".$2;
    }
  } elsif ($neigh =~ /\:(\d{1,4})$/) {
    $uniqueid = $asn."x".$1;
  }
  warn "Unique ID for peer $neigh is $uniqueid" if $options{ d};

  my $nblock = {
                 neighbor => $neigh,
  		 asn      => $asn,
		 set      => $set,
		 desc     => $desc,
                 maxpfx   => $maxpfx || $dflmaxpfx,
		 uniqueid => $uniqueid,
               };
  $uniqueasn{$asn} = "r";

  if ($neigh =~ /\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b/)
  {
    push @neighbors, $nblock;
    ## Get a *sorted* (i.e. duplicated, aggregated) list of prefixes.  Make sure
    #  that your templates allow MORE SPECIFICS from route-server customers.
    @pfxlist = RSTools::getFilterPfx4($set);
    ## If there is an override file, add these prefixes to the ones learned by IRR db
    if ( -f "ovr-$asn" )
    {
      warn "Prefix override file found - parsing ipv4" if $options{ d};
      open (my $OVERRIDE, "ovr-$asn");
      while(<$OVERRIDE>)
      {
        next if /^#/;
        chomp;
        next unless /\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\/\d{1,2}\b/;
        push (@pfxlist, $_);
      }
    }

    foreach my $pfx (@pfxlist)
    {
      my $pblock = { 
                     neighbor => $neigh,
                     asn      => $asn,
                     pfx      => $pfx,
                   };
      push @filterlist, $pblock;
    } 
  } elsif ($neigh =~ /\:/) 
  {
    push @neighbors6, $nblock;
    @pfxlist = RSTools::getFilterPfx6($set);
    ## If there is a v6 override file, add these prefixes to the ones learned by IRR db
    if ( -f "ovr-$asn" )
    {
      warn "Prefix override file found - parsing ipv6" if $options{ d};
      open (my $OVERRIDE, "ovr-$asn");
      while(<$OVERRIDE>)
      {
        next if /^#/;
        next unless /\:/;
        push (@pfxlist, $_);
      }
    }
    
    foreach my $pfx (@pfxlist)
    {
      my $pblock = {
                     neighbor => $neigh,
                     asn      => $asn,
                     pfx      => $pfx,
                   };
      push @filterlist6, $pblock;
    }

  }
}

## generate list of unique asn
my @uniqueasn = sort keys %uniqueasn;

### template toolkit needs the data in a hash

my %tplvalues;
   $tplvalues{neighbors}   = \@neighbors;
   $tplvalues{filterlist}  = \@filterlist;
   $tplvalues{neighbors6}  = \@neighbors6;
   $tplvalues{filterlist6} = \@filterlist6;
   $tplvalues{uniqueasn}   = \@uniqueasn;

 warn Dumper %tplvalues if $options{ d};

# process the template
# TODO: check it writes to appropriate file: $tpllist{$tpl}
foreach my $tpl (keys %tpllist) {
   my $tt = Template->new;
   $tt->process($tpl, \%tplvalues, $tpllist{$tpl}) || die $tt->error(), "\n";
}

