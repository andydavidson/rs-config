rs-config
=========

(c) Andy Davidson, LONAP Ltd 2013

IX Route Server configurator configures Multi-Lateral peering services for use at Internet Exchange Points.

It was created by Andy Davidson and extended by Will Hargrave and Rob Lister at LONAP (an exchange point in London) and powered the route-server configuration management for four years.  It has been used in several European and African exchange points.

New MLP services should consider using the IXP Manager tool on Github created by INEX, the Irish exchange point.  This is a full IXP management project and can be used to build route-server configurations.


Using the tool
==============

The tool allows IXP administrators to write a Template::Toolkit based configuration file for route-servers, and generate config for each of their peers, which creates BGP sessions facing the peers, and produces IRR based filter lists for their peers.

Sample template files are included for BIRD (generating files for IPv4 and IPv6 route-server instances) and OpenBGPd.


Hands on configuration
======================

You should make two configuration files:

 - peer configuration - a list of IXP Participants which you will add to the Internet Exchange Point route-server.  They should be listed one per line, in the format:   <ip address>,<as-number>,<as-set>,<Peer Name>.   You can add a fifth value - <max-prefix>.  An example file is included in this repository - cfgPeerList.cfg.

 - output behaviour configuration - a list of route-server configuration files to create.  An example file is included in this repository - cfgTplConfigs.cfg


Running the script
==================

perl RSBuild.pl -c cfgPeerList.cfg -b cfgTplConfigs.cfg

Generates OpenBGPd and BIRD config files according to the default cfgTplConfigs file.

RPSLBuild can be used to generate an aut-num object showing the correct import/export data for the route-servers aut-num based on the configured peering sessions.

If you use this, or would like some help, please drop me a line.