# Config version: $Id: tplBIRD.tpl 1694 2012-09-25 11:48:36Z robl $

router id 193.203.5.2;
define myas=8550;

protocol device { }

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

# Static default route
protocol static {
	route 0.0.0.0/0 via 10.0.0.1;
}

# This function excludes weird networks
function avoid_martians()
prefix set martians;
{
  martians = [ 169.254.0.0/16+, 172.16.0.0/12+, 192.168.0.0/16+, 10.0.0.0/8+,
               224.0.0.0/4+, 240.0.0.0/4+, 0.0.0.0/32-, 0.0.0.0/0{25,32}, 0.0.0.0/0{0,7} ];

  # Avoid RFC1918 and similar networks
  if net ~ martians then return false;

  return true;
}


function bgp_out(int peeras)
{
	if ! (source = RTS_BGP ) then return false;
 	if peeras > 65535 then
	{
		if (ro,0,peeras) ~ bgp_ext_community then return false;
		if (ro,myas,peeras) ~ bgp_ext_community then return true;
		if (ro,0,myas) ~ bgp_ext_community then return false;
	} else {
		if (0,peeras) ~ bgp_community || ((ro,0,peeras) ~ bgp_ext_community) then return false;
		if ((myas,peeras) ~ bgp_community) || ((ro,myas,peeras) ~ bgp_ext_community) then return true;
		if (0, myas) ~ bgp_community || ((ro,0,myas) ~ bgp_ext_community) then return false;
	}
		return true;
}

function bgp_in (int peeras)
{
        if ! (avoid_martians()) then return false;
        if ! (bgp_path ~ [= peeras * =]) then return false;

        /*
         * Peer filtering 
         */
	case gw {
		[% FOREACH pfx IN filterlist %] [% pfx.neighbor %]: if net ~ [ [% pfx.pfx %] ] then return true; 
		[% END %]

        	else: reject;
	}
}

/* build a list of bgp tables */
[% FOREACH i IN uniqueasn %]table T[% i %];
[% END %]

/* build a list of bgp pipes */
[% FOREACH i IN uniqueasn %]protocol pipe P[% i %] {
        table master;
        mode transparent;
	peer table T[% i %];
	import where bgp_in([% i %]);
	export where bgp_out([% i %]);
}
[% END %]

/* build a long list of bgp neighbors */

[% FOREACH neigh IN neighbors %]

protocol bgp R[% neigh.uniqueid %] {
        local as 8550;
        neighbor [% neigh.neighbor %] as [% neigh.asn %];
	passive on; 
        import all;
        export all;
        route limit [% neigh.maxpfx %];
        table T[% neigh.asn %];
	connect retry time 6000;
        rs client;
}

[% END %]

