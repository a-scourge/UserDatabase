#!/usr/bin/perl
#
use warnings;
use strict;
use Net::LDAP;

my $ad = Net::LDAP->new( 'ldaps://colada.eng.cam.ac.uk' ) or die "$@";

my $mesg = $ad->bind( 'AD\gmj33',
    password    =>  'etherline'
);

$ad->debug(12);

$ad->unbind();

