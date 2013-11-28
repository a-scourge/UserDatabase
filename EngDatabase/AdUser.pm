package EngDatabase::AdUser;
use lib './lib/';
use base qw( Net::LDAP::Entry );
use Net::LDAP::RootDSE qw( root_dse );
use Net::LDAP::Extra qw(AD);

use strict;
use warnings;
use Exporter 'import';
our @EXPORT_OK =
  qw( ad_set_password ad_update_or_create_user ad_unbind ad_finduser);

my $pwenc = "/usr/local/sbin/pwenc" unless $::pwenc;

my $domain_name = "DC=ad,DC=eng,DC=cam,DC=ac,DC=uk";

#sub decode_password { my $crypt = shift;
#    chomp( my $password = `$::pwenc -d $crypt` );
#    return $password;
#}
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
        $user_obj->setpassword($password) if $password;
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
    $self->replace( userAccountControl => 512 );
}

sub setgecos {

    #my ( $ad, $result ) = &get_ad_prod();
    my ( $self, $gecos ) = @_;
    my $username = $self->get_value('sAMAccountName');
    my $olddn    = $self->get_value('distinguishedName');
    $gecos =~ /^([\w\-\.]*)\s*?([\w\-]*?)$/;
    my ( $first, $last ) = ( $1, $2 );
    my $middle;
    if ( $first =~ /^(\w)\.(\w\.?)*\.$/ ) {
        ( $first, $middle ) = ( $1, $2 );
    }
    else { $first =~ s/\.// }

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

1;
