package EngDatabase::AD;
use lib './lib/';
use Net::LDAP;
use Net::LDAP::Extra qw(AD);
use strict;
use warnings;

use Exporter qw(import);
my $pwenc = "/usr/local/sbin/pwenc" unless $::pwenc;

our @EXPORT_OK = qw(ad_unbind ad_adduser get_ad_prod ad_finduser);

#my $opt_debug=1;

my $domain_name = "DC=ad,DC=eng,DC=cam,DC=ac,DC=uk";

sub decode_password {
    my $crypt = shift;
    chomp( my $password = `$::pwenc -d $crypt` );
    return $password;
}

{
    my $ad;
    my $result;

    sub get_ad_prod {
        unless ( defined $ad ) {
            $ad = Net::LDAP->new( 'ldaps://colada.eng.cam.ac.uk', )
                or die "$@";
        }
        unless ( defined $result ) {
            $result = $ad->bind( 'AD\gmj33', password => 'stihl123' );
            if ( $result->code ) {
                warn "Can't connect:", $result->error;
            }
        }
        print "Debugging\n" if $::opt_debug;
        $ad->debug(12) if $::opt_debug;
        return ( $ad, $result );
    }

    sub ad_unbind {
        $ad->unbind;
    }
}

sub ad_deluser {
    my ( $ad, $result ) = &get_ad_prod();
    my ($username) = shift;
    my $email      = $username . "@" . "ad.eng.cam.ac.uk";
    my $dn         = "CN=$username,CN=Users,$domain_name";
    $result = $ad->delete($dn);
    if ( $result->code ) {
        warn "Failed to delete user $username: ", $result->error;
    }
    else {
        print "Deleted user $username\n" if $::opt_debug;
    }
}

sub ad_update_or_create {
    my ( $ad, $result ) = &get_ad_prod();
    my ( $username, $password, $gecos ) = @_;
    my $email = $username . "@" . "ad.eng.cam.ac.uk";
    my $dn    = "CN=$username,CN=Users,$domain_name";
    $result = $ad->delete($dn);
    if ( $result->code ) {
        warn "Failed to delete user $username: ", $result->error;
    }
    $result = $ad->add(
        $dn,
        attrs => [
            objectClass =>
                [ "top", "person", "organizationalPerson", "user" ],
            cn                => $username,
            sn                => 'User',
            distinguishedName => $dn,
            sAMAccountName    => $username,
            displayName       => $gecos,
            userPrincipalName => $email,
            objectCategory =>
                "CN=Person,CN=Schema,CN=Configuration,dc=ad,dc=eng,dc=cam,dc=ac,dc=uk",
            userAccountControl =>
                2    #disable the regular user, use 512 to enable
        ]
    );
    if ( $result->code ) {
        warn "failed to add entry: ", $result->error;
    }
    else {
        print "Added user $username to AD\n" if $::opt_debug;
    }

    if ( $password && $password ne "" && $ad->is_AD || $ad->is_ADAM ) {
        $ad->reset_ADpassword( $dn, $password );
        $result = $ad->modify(
            $dn,
            replace => {
                userAccountControl =>
                    512,    # ahhh finally we get to enable the account!!!
            }
        );
    }
    if ( $result->code ) {
        warn "Failed to set the password for $username\n";
    }
    else {
        print "Changed password for $username in AD\n" if $::opt_debug;
    }
}

sub ad_finduser {
    my $username = shift;
    my ( $ad, $result ) = &get_ad_prod();
    $result = $ad->search(    # perform a search
        base   => "dc=ad,dc=eng,dc=cam,dc=ac,dc=uk",
        filter => "(&(objectClass=person)(sAMAccountName=$username))",
    );
    die "More than on AD entry for $username\n" if $result->count() > 1;
    print "The count is: " . $result->count();
    return if $result->count() == 0;
    return $result->shift_entry();
}

sub ad_adduser {
    my ( $ad, $result ) = &get_ad_prod();
    my ( $username, $password, $gecos ) = @_;
    my $email = $username . "@" . "ad.eng.cam.ac.uk";
    my $dn    = "CN=$username,CN=Users,$domain_name";
    if ( $result = $ad->search($dn) ) {
        print "$username is already in AD!!\n";
        print $result->count();
    }
    $result = $ad->delete($dn);
    if ( $result->code ) {
        warn "Failed to delete user $username: ", $result->error;
    }
    $result = $ad->add(
        $dn,
        attrs => [
            objectClass =>
                [ "top", "person", "organizationalPerson", "user" ],
            cn                => $username,
            sn                => 'User',
            distinguishedName => $dn,
            sAMAccountName    => $username,
            displayName       => $gecos,
            userPrincipalName => $email,
            objectCategory =>
                "CN=Person,CN=Schema,CN=Configuration,dc=ad,dc=eng,dc=cam,dc=ac,dc=uk",
            userAccountControl =>
                2    #disable the regular user, use 512 to enable
        ]
    );
    if ( $result->code ) {
        warn "failed to add entry: ", $result->error;
    }
    else {
        print "Added user $username to AD\n" if $::opt_debug;
    }

    if ( $password && $password ne "" && $ad->is_AD || $ad->is_ADAM ) {
        chomp( $password = &decode_password($password) );
        $password = "password123";
        $ad->reset_ADpassword( $dn, $password );
        $result = $ad->modify(
            $dn,
            replace => {
                userAccountControl =>
                    512,    # ahhh finally we get to enable the account!!!
            }
        );
    }
    if ( $result->code ) {
        warn "Failed to set the password for $username\n";
    }
    else {
        print "Changed password for $username in AD\n" if $::opt_debug;
    }
}

1;
