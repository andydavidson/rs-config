#! /usr/bin/perl -w

package RSTools;
use Net::CIDR::Lite;

sub getFilterPfx4
{
  my $rawcidr = Net::CIDR::Lite->new;
  my $set = shift;
  my $ret = `peval -h whois.radb.net -s RIPE,RADB,ARIN,APNIC 'afi ipv4 $set'`;
  chomp($ret);
  return unless ($ret =~ /\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b/);
     $ret =~ s/[\{\(|\\)}]//isg;
  my @rawlist = split(/[\s]{0,}\,[\s]{0,}/,$ret);
  foreach my $p (@rawlist)
  {
    $rawcidr->add($p);
  }
  my @pfxlist =  $rawcidr->list;
  return @pfxlist;
} 

sub getFilterPfx6
{
  my $set = shift;
  my $ret = `peval -h whois.radb.net -s RIPE,RADB,ARIN,APNIC 'afi ipv6 $set'`;
  chomp($ret);
  return unless ($ret =~ /:/);
     $ret =~ s/[\{\(|\\)}]//isg;
  my @pfxlist = split(/[\s]{0,}\,[\s]{0,}/,$ret);
  return @pfxlist;
}

1;
