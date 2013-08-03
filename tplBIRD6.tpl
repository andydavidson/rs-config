# Config version: $Id: tplBIRD6.tpl 824 2011-02-17 10:51:56Z will $


router id 193.203.5.2;
listen bgp v6only;

protocol device {
}

protocol direct {
	disabled;
}

# Comment 'disabled' if you want to have learned routes in UNIX routing table
protocol kernel {
	disabled;
       import all;             # Default is import all
       export all;             # Default is export none
	scan time 10;		# Scan kernel tables every 10 seconds
}

# This function excludes weird networks
function avoid_martians()
{
	# Peer filtering
[% FOREACH pfx IN filterlist6 %]	if ( gw = [% pfx.neighbor %] ) && ( net ~ [% pfx.pfx %] ) then return 1;
[% END %]

	return 0;
}


function match_community(pair c_allow; pair c_deny)
{
	if c_deny ~ bgp_community then return 0;
	if c_allow ~ bgp_community then return 1;
	if (0, 8550) ~ bgp_community then return 0;
	return 1;
}

function bgp_out(pair c_allow; pair c_deny)
{
       if ! (source = RTS_BGP ) then return 0;
	return match_community(c_allow, c_deny);
}

function bgp_in (bgpmask msk)
{
	if (avoid_martians() = 0) then return 0;
	if ! (bgp_path ~ msk) then return 0;
	return 1;
}


[% FOREACH neigh IN neighbors6 %]
protocol bgp R[% neigh.uniqueid %] {
	/* Peer:  [% neigh.desc %] [% neigh.set %] */
	local as 8550;
	neighbor [% neigh.neighbor %] as [% neigh.asn %];
	passive on;
	import where bgp_in([= [% neigh.asn %] * =]) = 1;
	export where bgp_out((8550,[% neigh.asn %]),(0,[% neigh.asn %])) = 1;
	rs client;
}
[% END %]

