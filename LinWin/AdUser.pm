package EngDatabase::AdUser;
use lib './lib/';
use base qw( Net::LDAP::Entry );
use Net::LDAP::RootDSE qw( root_dse );
use Net::LDAP::Extra qw(AD);

use strict;
use warnings;

=head1 NAME

LinWin::AdUser - class represents a user in AD

=head1 SYNOPSIS

  use lib 'lib';
  use EngDatabase::AdUser qw(ad_unbind ad_update_or_create_user ad_finduser);

  $aduser = ad_finduser($username);
  $aduser->setpassword($password);
  $aduser->setgecos($gecos);
  $display_name = $aduser->get_value('displayName');

=head1 DESCRIPTION

A class which represents a AD user. Uses Net::LDAP::Search to find a user
based on sAMAccountName (the authenticaltion username). Inherits methods from Net::LDAP::Entry

Configuration is set in a hashref in $RHcfg. Also, set $pwenc for a local
pwdecrypt program.

=head1 CONSTRUCTORS

=head2 ad_finduser

  my $aduser = ad_finduser($username);

Searches the AD server for a user record, where $username matches the
sAMAccountname on the AD server. This is the AD authentication name. Returns a
Net::LDAP::Entry object re-blessed as a AdUser

head2 ad_adduser

  my $aduser = ad_adduser($username,$password,$gecos);

Creates a new object, sets the gecos (using the method described below), saves
it to the server (as a disabled user), then sets the password, which then
allows it to enable it (AD requires this little dance).

=head2 ad_update_or_create_user

  my $aduser = ad_update_or_create_user($username,$password,$gecos);

Calls ad_finduser, if an object is returned it calls the setgecos, setpassword
and save methods. Otherwise, calls ad_adduser. This is just a convenience
constructor.

=head1 METHODS

=head2 save

  $aduser->save;

Saves the object using the current Net::LDAP connection.

=head2 rmuser

  $aduser->rmuser;

Deletes the user and also updates the server.

=head2 print_attrs

  $aduser->print_attrs;

iterates through the attributes and prints them. useful for debugging. TODO
make a get_attrs version of this which returns a hashref of key => value pairs

=head2 enable

  $aduser->enable;

enables the user. Changes are not made to server, call ->save to enable on
server

=head2 disable

  $aduser->disable;

disables the user. Changes are not made to server, call ->save to disable on
server

=head2 setgecos

  $aduser->setgecos($gecos);

Sets the dn, rdn, cn, initials, sn, givenName etc on the server. Changes are
not made to server, call ->save to update the server.

=head2 setpassword

  $aduser->setpassword

Sets the password on the server. Changes are not made to server, call ->save
to update the server.

=cut 


use Exporter 'import';
our @EXPORT_OK =
  qw( ad_set_password ad_update_or_create_user ad_unbind ad_finduser);

my $pwenc = "/usr/local/sbin/pwenc" unless $::pwenc;

my $RHcfg = readcfg('./ad.conf');

my $domain_name = $$RHcfg{ldap}{domain};
my $ldapstr = "ldaps://$$RHcfg{ldap}{server}";
my $ldapuser = $$RHcfg{ldap}{admin};
my $ldappw = $$RHcfg{ldap}{password};

my $ad;
my $result;

sub get_ad_prod {
    unless ( defined $ad ) {
        $ad = Net::LDAP->new( $ldapstr )
          or die "$@";
    }
    unless ( defined $result ) {
        $result = $ad->bind( $ldapuser, password => $ldappw );
        if ( $result->code ) {
            warn "Can't connect:", $result->error;
        }
    }
    print "Debugging\n" if $::opt_debug;
    $ad->debug(12) if $::opt_debug;
    return $ad;
}

sub ad_unbind {
    $ad->unbind if $ad;
}

# three constructors, ad_finduser, ad_adduser and
# ad_update_or_create_user
sub ad_finduser {
    get_ad_prod unless $ad;
    my $username = shift;
    $result = $ad->search(    # perform a search
        base   => $domain_name,
        filter => "(&(objectClass=person)(sAMAccountName=$username))",
    );
    if ( $result->code ) {
        warn "Cannot search for user $username: ", $result->error;
    }
    die "More than one AD entry for $username\n" if $result->count() > 1;

    # return nothing if no user found:
    return if $result->count() == 0;

    #otherwise, get the entry and return it:
    my $user_obj = $result->shift_entry();
    bless $user_obj, 'EngDatabase::AdUser';
    return $user_obj;
}

sub ad_adduser {
    get_ad_prod unless $ad;
    my ( $username, $password, $gecos ) = @_;
    my $email    = $username . "@" . "ad.eng.cam.ac.uk";
    my $dn       = "CN=$gecos($username),CN=Users,$domain_name";
    my $user_obj = Net::LDAP::Entry->new(
        $dn,
        objectClass => [ "top", "person", "organizationalPerson", "user" ],

        #cn                => $gecos,
        #distinguishedName => $dn,
        sAMAccountName => $username,
        displayName    => $gecos,

        #name              => $gecos,
        userPrincipalName => $email,
        objectCategory =>
"CN=Person,CN=Schema,CN=Configuration,dc=ad,dc=eng,dc=cam,dc=ac,dc=uk",
        userAccountControl => 2    #disable the regular user, use 512 to enable
    );
    bless( $user_obj, 'EngDatabase::AdUser' );
    $user_obj->setgecos($gecos);
    $user_obj->save;

    #$user_obj->setpassword($password);
    #$user_obj->enable;
    $user_obj->save;

    return $user_obj;
}

sub ad_update_or_create_user {
    get_ad_prod unless $ad;

    my ( $username, $password, $gecos ) = @_;
    my $user_obj;
    if ( $user_obj = &ad_finduser($username) ) {

        $user_obj->setgecos($gecos) if $gecos;
        #$user_obj->setpassword($password) if $password;
        $user_obj->update($ad);
    }
    else {
        $user_obj = &ad_adduser( $username, $password, $gecos );
    }
    return $user_obj;
}

#various methods

sub save {
    my $self = shift;
    $self->update($ad);
    return $self;
}

sub rmuser {
    my $self = shift;
    $self->delete;
    $self->update($ad);
    return $self;
}

sub print_attrs {
    my $self = shift;

    #my ($user_obj, $username) = &ad_finduser($self);
    my @attributes = $self->attributes();
    foreach my $attribute (@attributes) {
        print "$attribute =>   ";
        print $self->get_value($attribute);
        print "\n";
    }
    return $self;
}

sub enable {
    my $self = shift;
    $self->replace( userAccountControl => 512 );
}
sub disable {
    my $self = shift;
    $self->replace( userAccountControl => 2 );
}

sub setgecos {

    #my ( $ad, $result ) = &get_ad_prod();
    my ( $self, $gecos ) = @_;
    my $username = $self->get_value('sAMAccountName');
    my $olddn    = $self->get_value('distinguishedName');
    $gecos =~ /^([\w\-\.]*)\s*?([\w\-]*?)$/;
    my ( $first, $last ) = ( $1, $2 );
    my $middle;
    if ( $first ) {
        if ( $first =~ /^(\w)\.(\w\.?)*\.$/ ) {
            ( $first, $middle ) = ( $1, $2 );
        }
        else { $first =~ s/\.// }
    }

    #$gecos .= "(${username})";
    my $rdn = "CN=$gecos($username)";
    my $dn  = "CN=$username,CN=Users,$domain_name";
    $result = $ad->modrdn(
        $olddn,
        newrdn       => $rdn,
        deleteoldrdn => '1',
        name         => $gecos,
    );
    $self->replace( givenName => $first )  if $first;
    $self->replace( initials  => $middle ) if $middle;
    $self->replace( sn        => $last )   if $last;
    $self->replace(

        #name => $gecos, # don't touch 'name', must match the RDN
        #cn => $gecos, # this also has to match the RDN
        displayName => $gecos,
    );
    return $self;
}

sub setpassword {
    my ( $self, $password ) = @_;
    #my $username = $self->get_value('sAMAccountName');
    my $dn       = $self->get_value('distinguishedName');

    #my ($ad, $result) = get_ad_prod();
    chomp( $password = `$::pwenc -d $password` );
    if ( $password && $password ne "" and $ad->is_AD || $ad->is_ADAM ) {
        $ad->reset_ADpassword( $dn, $password );
    }
}

sub readcfg {
	my ($file) = @_;

        # Process the contents of the config file
	my $RHcfg = do($file);
	# Check for errors
	die "ERROR: Can't compile $file: $@\n" if $@;
	die "ERROR: Can't read $file: $!\n" unless defined $RHcfg;
	die "ERROR: Can't process $file\n" unless $RHcfg;

	return $RHcfg;
}

1;
