#!/usr/bin/perl
#
use warnings;
use Net::LDAP;

$ldap = Net::LDAP->new( 'tyr.eng.cam.ac.uk' ) or die "$@";

#$mesg = $ldap->bind; # an anonymous bind
$mesg = $ldap->bind( 'cn=Manager,dc=eng,dc=cam,dc=ac,dc=uk',
    password => 'test'
);

sub LDAPsearch
{
  my ($ldap,$searchString,$attrs,$base) = @_;
 
  # if they don't pass a base... set it for them
 
    if (!$base ) { $base = "dc=eng,dc=cam,dc=ac,dc=uk"; }
 
  # if they don't pass an array of attributes...
  # set up something for them
 
  if (!$attrs ) { $attrs = [ 'cn','mail' ]; }
 
  my $result = $ldap->search ( base    => "$base",
                               scope   => "sub",
                               filter  => "$searchString",
                               attrs   =>  $attrs
                             );
}

$ldap->debug(12);
my @Attrs = ( );

my $result = LDAPsearch ($ldap, "uid=*", \@Attrs );

my $href = $result->as_struct;

my @arrayOfDNs = keys %$href;

foreach ( @arrayOfDNs ) {
    print $_, "\n";
    my $valref = $$href{$_};
    my @arrayOfAttrs = sort keys %$valref; # use Attr hashes
    my $attrName;
    foreach $attrName (@arrayOfAttrs) {
        # skip any binary data: yuck!
        next if ( $attrName =~/;binary$/ );

        my $attrVal = @$valref{$attrName};
        print "\n $attrName: @$attrVal \n";
    }
    print "#-------------------------\n";
    #end of that DN
}

#$result = $ldap->add( 'cn=Rebecca Jarvis-Rogers, ou=Users,dc=eng,dc=cam,dc=ac,dc=uk',
#    attrs   =>  [
#        'cn'    => ['Rebecca Jarvis-Rogers', 'Babes'],
#        'uid' => '501',
#        'uidNumber'  => '501',
#        'gidNumber'  =>  '501',
#        'homeDirectory' => '/home/rebecca',
#        'loginShell'    =>  '/bin/bash',
#        #'gid' => '501',
#        'objectclass'   => ['account', 'posixAccount', 'top', 'shadowAccount' ],
#        ]
#    );
#
#$result->code && warn "failed to add entry: ", $result->error ;
#
#$mesg = $ldap->search(
#    base        =>  "dc=eng,dc=cam,dc=ac,dc=uk",
#    filter      =>  "(&(cn=Manager))"
#);
#
#$mesg->code && die $mesg->error;
#
#foreach $entry ($mesg->entries) { $entry->dump; }

$mesg = $ldap->unbind;


