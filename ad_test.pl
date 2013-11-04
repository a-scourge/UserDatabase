#!/usr/bin/perl
#
use warnings;
use Net::LDAP;
use Net::LDAP::Bind;
use Net::LDAP::Extra qw(AD);

$ldap = Net::LDAP->new( 'ldaps://colada.eng.cam.ac.uk',
    ) or die "$@";

$mesg = $ldap->bind( 'AD\gmj33',
    password    =>  'stihl123'
);

#$ldap->debug(12);

#@entries = $result->entries;
#print $entries[1] . "\n";
#foreach $entry (@entries) { $entry->dump; }

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

#my $result = LDAPsearch( $ldap, "sn=*", \@Attrs );
$result = $ldap->search( # perform a search
    base    =>      "dc=ad,dc=eng,dc=cam,dc=ac,dc=uk",
    filter  =>      "(&(objectClass=person)(uidNumber=*))"
);

$mesg->code && die $mesg->error;
#------------
#
# Accessing the data as if in a structure
#  i.e. Using the "as_struct" method
#
my $href = $result->as_struct;
# get an array of the DN names
my @arrayOfDNs = keys %$href;   # use DN hashes
# process each DN using it as a key
#
foreach ( @arrayOfDNs ) {
    print $_, "\n";
    my $valref = $$href{$_};
    # get an array of the attribute names
    # passed for this one DN
    my @arrayOfAttrs = sort keys %$valref; # use Attr hashes

    my $attrName;
    foreach $attrName (@arrayOfAttrs) {

        # skip any binary data: yuck!
        next if ($attrName =~ /;binary$/ );

        # get the attribute value (pointer) using the
        # attribute name as the hash
        my $attrVal = @$valref{$attrName};
        print "\t $attrName: @$attrVal \n";
    }
    print "#--------------------------\n";
    #en of that DN
}
#
#
# en of as_struct method
#
# ----------------
# ----
# handle each of the results independently
# .... i.e. using the walk through method
#
my @entries = $result->entries;

my $entr;
foreach $entr (@entries) {
    print "DN: ", $entr->dn, "\n";

    my $attr;
    foreach $attr ( sort $entr->attributes ) {
        # skip binary we can't handle
        next if ( $attr =~ /;binary$/ );
        print " $attr : ", $entr->get_value ( $attr ), "\n";
    }
    print "#-----------------------\n";
}
#
#
# end of walk through method
# ---------------
#
#Doe
if ( $result->code ) {
  #
  # if we've got an error... record it
  #
  LDAPerror ( "Searching", $result );
}
 
sub LDAPerror
{
  my ($from, $mesg) = @_;
  print "Return code: ", $mesg->code;
  print "\tMessage: ", $mesg->error_name;
  print " :",          $mesg->error_text;
  print "MessageID: ", $mesg->mesg_id;
  print "\tDN: ", $mesg->dn;
 
  #---
  # Programmer note:
  #
  #  "$mesg->error" DOESN'T work!!!
  #
  #print "\tMessage: ", $mesg->error;
  #-----
}

if ( $result->count != 1 ) { exit; } # Nope, exit

my $dn = $entries[0]->dn;
my $old_password = "etherline";
my $new_password = "test123";

$ldap->change_ADpassword($dn, $old_password, $new_password);

#####
# Modify using a HASH
#

my %replaceHash = ( keyword => "x", proxy => "x" );

$result = LDAPmodifyUsingHash ( $ldap, $dn, \%replaceHash );

sub LDAPmodifyUsingHash
{
    my ($ldap, $dn, $whatToChange ) = @_;
    my $result = $ldap->modify ( $dn,
        replace =>  {%$whatToChange }
    );
    return $result;
}

$mesg = $ldap->unbind;
