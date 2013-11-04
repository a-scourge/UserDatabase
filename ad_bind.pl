#!/usr/bin/perl
#
use warnings;
use strict;
use Net::LDAP;

my $ad = Net::LDAP->new( 'ldaps://colada.eng.cam.ac.uk' ) or die "$@";

my $mesg = $ad->bind( 'AD\HeatExcE',
    password    =>  'password1'
);

$ad->debug(12);

$ad->unbind();

