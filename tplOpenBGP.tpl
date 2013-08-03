# Config version: $Id: tplOpenBGP.tpl 1246 2011-11-17 14:14:23Z andy $

AS 8550
router-id 193.203.5.1
transparent-as yes
fib-update no

[% FOREACH i IN uniqueasn %]rde rib peer[% i %]
[% END %]

group "RS" {
  announce all
  set nexthop no-modify

  [% FOREACH neigh IN neighbors %]
  neighbor [% neigh.neighbor %] {
    descr "[% neigh.desc %]"
    remote-as [% neigh.asn %]
    passive
    max-prefix [% neigh.maxpfx %] restart 15
    enforce neighbor-as yes
    rib peer[% neigh.asn %]
    announce IPv4 unicast
  }
  [% END %]

  [% FOREACH neigh IN neighbors6 %]
  neighbor [% neigh.neighbor %] {
    descr "[% neigh.desc %]-6"
    remote-as [% neigh.asn %]
    max-prefix [% neigh.maxpfx %]
    enforce neighbor-as yes
    rib peer[% neigh.asn %]
    announce IPv6 unicast
    announce IPv4 none
  }
  [% END %]

}

deny from any inet prefixlen 8 >< 29

deny from any inet prefix 0.0.0.0/0
deny from any prefix 10.0.0.0/8  prefixlen >= 8
deny from any prefix 127.0.0.0/8 prefixlen >= 8
deny from any prefix 169.254.0.0/16 prefixlen >= 16
deny from any prefix 172.16.0.0/12 prefixlen >= 12
deny from any prefix 192.0.2.0/24 prefixlen >= 24
deny from any prefix 192.168.0.0/16 prefixlen >= 16
deny from any prefix 224.0.0.0/4 prefixlen >= 4
deny from any prefix 240.0.0.0/4 prefixlen >= 4

deny quick to group RS community 0:neighbor-as
deny quick to group RS community 0:8550
allow to group RS community 8550:neighbor-as
allow to group RS community 8550:8550

[% FOREACH pfx IN filterlist %] allow quick from [% pfx.neighbor %] prefix [% pfx.pfx %] prefixlen <=24 
[% END %]

[% FOREACH pfx IN filterlist6 %] allow quick from [% pfx.neighbor %] prefix [% pfx.pfx %]
[% END %]

deny from any
