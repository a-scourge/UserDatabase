package EngDatabase::AdUser;
use lib './lib/';
use base qw( Net::LDAP::Entry );
use Net::LDAP::RootDSE qw( root_dse );
use Net::LDAP::Extra qw(AD);

use strict;
use warnings;
use Exporter 'import';
our @EXPORT_OK = qw( ad_set_password ad_update_or_create_user ad_unbind ad_finduser);

my $pwenc = "/usr/local/sbin/pwenc" unless $::pwenc;

my $domain_name = "DC=ad,DC=eng,DC=cam,DC=ac,DC=uk";

sub decode_password { my $crypt = shift;
    chomp( my $password = `$::pwenc -d $crypt` );
    return $password;
}

sub ad_finduser {
    my $self = shift;
    my ( $ad, $result ) = &get_ad_prod();
    my ($username, $user_obj);
    if (ref($self) eq 'EngDatabase::AdUser') {
            $username = $self->get_value('sAMAccountName');
            $user_obj = $self;
    }
    else {
        $username = $self;
        $result = $ad->search(    # perform a search
            base   => $domain_name,
            filter => "(&(objectClass=person)(sAMAccountName=$username))",
        );
        if ($result->code ) {
            warn "Cannot search for user $username: ", $result->error;
        }
        die "More than one AD entry for $username\n" if $result->count() > 1;
        my $count = $result->count();
        return if $result->count() == 0;
        $user_obj = $result->shift_entry();
        bless $user_obj, 'EngDatabase::AdUser';
    }
    return ($user_obj, $username);
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
            $result = $ad->bind( 'AD\ad_admin', password => 'Stihl123' );
            if ( $result->code ) {
                warn "Can't connect:", $result->error;
            }
        }
        print "Debugging\n" if $::opt_debug;
        $ad->debug(12) if $::opt_debug;
        return $ad;
    }

    sub ad_unbind {
        $ad->unbind;
    }
}

sub ad_deluser {
    my ( $ad, $result ) = &get_ad_prod();
    my $self = shift;
    my ($user_obj, $username) = &ad_finduser($self);
    $user_obj->delete;
    return $user_obj;
}


sub print_attrs {
    my $self = shift;
    my ($user_obj, $username) = &ad_finduser($self);
    my @attributes =  $user_obj->attributes();
    foreach my $attribute (@attributes) {
        print "$attribute =>   ";
        print $user_obj->get_value($attribute);
        print "\n";
    }
}

sub ad_update_or_create_user {
    my ( $ad, $result ) = &get_ad_prod();
    my ( $self, $password, $gecos ) = @_;
    if (my ($user_obj, $username) = &ad_finduser($self)) {
        #$user_obj->setpassword($password) if $password;
        $user_obj->setgecos($gecos) if $gecos;
        $user_obj->update($ad);
    }
    else {
        &ad_adduser($username, $password, $gecos);
    }
}

sub setgecos {
    my ($self, $gecos) = @_;
    my ($user_obj, $username) = &ad_finduser($self);
    my $dn    = "CN=$gecos,CN=Users,$domain_name";
    $user_obj->replace( displayName => $gecos );
    #$user_obj->dn($dn);
    #$user_obj->replace( cn => $gecos );
    #$user_obj->replace( name => $gecos );
    $gecos =~ /^([\w\-\.]*)\s*?([\w\-]*?)$/;
    my ($first, $last) = ($1, $2);
    my $middle;
    if ($first =~ /^(\w)\.(\w\.?)*\.$/) {
        ($first, $middle) = ($1, $2) 
    }
    else { $first =~ s/\.// }
    $user_obj->replace( givenName => $first ) if $first;
    $user_obj->replace( initials => $middle ) if $middle;
    $user_obj->replace( sn => $last ) if $last;
    return $user_obj;
}

sub setpassword {
    my ($self, $password) = @_;
    my $username = $self->get_value('sAMAccountName');
    my $dn    = "CN=$username,CN=Users,$domain_name";
    my ($ad, $result) = get_ad_prod();
    $password = "password123"; # remove this later!!! debugging!!
    if ($password && $password ne "" && $ad->is_AD && $ad->is_ADAM ) {
        $ad->reset_ADpassword($dn, $password);
        $ad->modify(
            $dn,
            replace => {
                userAccountControl =>
                    512,    # enable the account
                }
        );
        if ( $result->code ) {
            warn "Failed to set the password for $username\n";
        }
        else {
            print "Changed password for $username in AD\n" if $::opt_debug;
        }
    }
}


sub ad_adduser {
        my ( $ad, $result ) = get_ad_prod();
        my ( $self, $password, $gecos ) = @_;
        my ($user_obj, $username) = &ad_finduser($self);
        my $email = $username . "@" . "ad.eng.cam.ac.uk";
        my $dn    = "CN=$username,CN=Users,$domain_name";
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
            $self->setpassword;
        }
        return $user_obj;
    }

1;
