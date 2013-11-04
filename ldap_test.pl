#!/usr/bin/perl
#
#
#


use Net::LDAP;
$ldap = Net::LDAP->new("colada.eng.cam.ac.uk") or die "$@";
$mesg = $ldap->bind( version => 3 );    # use for searches

#$mesg = $ldap->bind(
#    "$userToAuthenticate",
#    password => "$passwd",
#    version  => 3
#);                                      # use for changes/edits

# see your LDAP administrator for information concerning the
# user authentication setup at your site.
sub LDAPsearch {
    my ( $ldap, $searchString, $attrs, $base ) = @_;

    # if they don't pass a base... set it for them

    if ( !$base ) { $base = "dc=ad,dc=eng,dc=cam,dc=ac,dc=uk"; }

    # if they don't pass an array of attributes...
    # set up something for them

    if ( !$attrs ) { $attrs = [ 'cn', 'Users' ]; }

    my $result = $ldap->search(
        base   => "$base",
        scope  => "sub",
        filter => "$searchString",
        attrs  => $attrs
    );
}
my @Attrs = ();    # request all available attributes
                   # to be returned.

my $result = LDAPsearch( $ldap, "sn=*", \@Attrs );

#------------
#
# Accessing the data as if in a structure
#  i.e. Using the "as_struct"  method
#

my $href = $result->as_struct;

# get an array of the DN names

my @arrayOfDNs = keys %$href;    # use DN hashes

# process each DN using it as a key

foreach (@arrayOfDNs) {
    print $_, "\n";
    my $valref = $$href{$_};

    # get an array of the attribute names
    # passed for this one DN.
    my @arrayOfAttrs = sort keys %$valref;    #use Attr hashes

    my $attrName;
    foreach $attrName (@arrayOfAttrs) {

        # skip any binary data: yuck!
        next if ( $attrName =~ /;binary$/ );

        # get the attribute value (pointer) using the
        # attribute name as the hash
        my $attrVal = @$valref{$attrName};
        print "\t $attrName: @$attrVal \n";
    }
    print "#-------------------------------\n";

    # End of that DN
}

#
#  end of as_struct method
#
#--------

#------------
#
# handle each of the results independently
# ... i.e. using the walk through method
#
my @entries = $result->entries;

my $entr;
foreach $entr (@entries) {
    print "DN: ", $entr->dn, "\n";

    my $attr;
    foreach $attr ( sort $entr->attributes ) {

        # skip binary we can't handle
        next if ( $attr =~ /;binary$/ );
        print "  $attr : ", $entr->get_value($attr), "\n";
    }

    print "#-------------------------------\n";
}

#
# end of walk through method
#------------
