as-set: AS-LONAP-MLP
descr: ===============================================
descr: IPv4 Multilateral peering participants at LONAP
descr: ===============================================
descr: See www.lonap.net for information about the service.
descr: See AS8550 aut-num object for filtering policy.
members: AS8330
members: AS112
[% FOREACH neigh IN neighbors %]members: AS[% neigh.asn %][% IF neigh.set %], [% neigh.set %] [% END %] # [% neigh.desc %]
[% END %]tech-c: AS8330-RIPE
remarks: SVN Version: $Id: tplRipeDB.tpl 1529 2012-05-31 19:05:16Z robl $
admin-c: AS8330-RIPE
mnt-by: AS8330-MNT
mnt-by: AS8330-AUTO-MNT
changed: ripedb@lonap.net
source: RIPE

as-set: AS-LONAP-MLP-V6
descr: ===============================================
descr: IPv6 Multilateral peering participants at LONAP
descr: ===============================================
descr: See www.lonap.net for information about the service.
descr: See AS8550 aut-num object for filtering policy.
members: AS8330
members: AS112
[% FOREACH neigh IN neighbors6 %]members: AS[% neigh.asn %][% IF neigh.set %], [% neigh.set %] [% END %] # [% neigh.desc %]
[% END %]tech-c: AS8330-RIPE
remarks: SVN Version: $Id: tplRipeDB.tpl 1529 2012-05-31 19:05:16Z robl $
admin-c: AS8330-RIPE
mnt-by: AS8330-MNT
mnt-by: AS8330-AUTO-MNT
changed: ripedb@lonap.net
source: RIPE

