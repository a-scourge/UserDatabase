#!/usr/bin/perl
#
use warnings;
use Net::LDAP;
use Net::LDAP::Bind;
use Net::LDAP::Extra qw(AD);

$ad = Net::LDAP->new( 'ldaps://kdc.eng.cam.ac.uk',
    ) or die "$@";

$result = $ad->bind( 'AD\gmj33',
    password    =>  'etherline'
);

$ad->debug(12);

sub LDAPsearch
{
    my ($ldap,$searchString,$attrs,$base) = @_;
    # if they don't pass a base, set it for them
    if (!$base ) { $base = "dc=ad,dc=eng,dc=cam,dc=ac,dc=uk"; }

    # if they don't pass an array of attributes... 
    # set up something for them

    if (!$attrs ) { $attrs = [ 'cn', 'uidNumber' ]; }
    
    my $result = $ldap->search (
        base    =>      "$base",
        scope   =>      "sub",
        filter  =>      "$searchString",
        attrs   =>      $attrs
    );
}

my @Attrs = ( );

$result = LDAPsearch( $ad, "sn=Sloan test", \@Attrs );
$result->code && die $result->error;
if ($result->entries != 1 ) { die "ERROR: User not found in AD: " };
 
my $entry = $result->entry(0); # there can be only one
my $dn = $entry->get_value('distinguishedName');

$result = $ad->modify(
    $dn,
    replace => {
        givenName   =>  'testname2',
    }
);

$result->code && die $result->error;
print "AD   : SUCCESS: ${dn} name changes.\n";

$ad->unbind();



