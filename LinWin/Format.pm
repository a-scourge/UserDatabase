package LinWin::Format;
use strict;
use warnings;
#use Data::Dumper;

=head1 NAME

LinWin::Format - parses input files into hashrefs

=head1 SYNOPSIS

  use LinWin::Format qw(parse_tcb parse_grp);
  my $user_href = parse_tcb($line);
  my $group_href = parse_grp($line);

=head1 DESCRIPTION

This module is just a catch-all for some messy parsing logic.


=cut

use Exporter qw(import);

our @EXPORT_OK = qw(print_changes compare_hash parse_tcb parse_reg
  parse_grp get_capabilities_from_propagation add_propagation);

sub parse_grp {
    my $line = $_[0];
    chomp $line;
    ( my @grp ) = split( /:/, $line );

    my $group_name = $grp[0];
    my $gid        = $grp[2];
    my @users      = sort split( /,/, $grp[3] ) if $grp[3];
    my @usergroups;
    #@users = sort @users;
    while (my $user = shift @users) {
        my $crsid = $user;
        my $engid = $user;

        my @aliases;
        #if ( my @aliases = map{s/^($engid\d+)$//; $crsid = $1} @users) {
        #    print "Aliases: @aliases\n";
        #    print "CRSID: $crsid\n";
        #    #$crsid = shift @aliases;
        #}
        for (@users) {
            if (/^$engid\d+$/) {
                push @aliases, $_;
                $crsid = $_;
            }
        }
        #$crsid = shift @aliases;
        # now we have crsid, delete all other mentions:
        @users = grep ! /$engid/, @users; 
        #print "Found $crsid from @users\n";
        #my $wait = <STDIN>;
        my $usergroup = {
            myuser => {
                ENGID => $engid,
                CRSID => $crsid,
            }
        };
        push( @usergroups, $usergroup );
    }
    my %data = (
        'GROUP_NAME' => $group_name,
        'GID'        => $gid,
        'usergroups' => \@usergroups,
    );

    return ( \%data );
}

sub parse_tcb {
    my %data;
    chomp( my $line = shift );
    $line =~ s/"//g;

    # The following line is good for csv file made by John
    ( my @tcb ) = split( /,/, $line );
    my $gid   = $tcb[5];            # the tcb GID field
    my $crsid = $tcb[1];
    my $engid = $tcb[0];
    my $id    = $crsid || $engid;
    return
      if ( $gid < 1000
        && $id !~ m/^(webadmin|webuser|dnsmaint|cvsuser|eximuser)$/ );

    my $encpw       = $tcb[8];
    my $status      = $tcb[12];
    my $uid         = $tcb[4];
    my $propagation = $tcb[26];
    ## now to get capabilities:
    my $capabilities = {};
    if ($::statuses_rs) {
        my $status_obj =
          $::statuses_rs->find_or_new( { STATUS_NAME => $status, } );

        $capabilities = $status_obj->get_capabilities;
        if ( my $propstring_capabilities =
            &get_capabilities_from_propagation($propagation) )
        {
            $capabilities = { %$capabilities, %$propstring_capabilities };
        }
    }

    # we're going to determine these variables:
    my $aff_gid;
    my $pri_gid = $gid;
    my $primary_groupname;

    ## and now to determine them:
    #first, system accounts uid == gid:
    if ( $uid == $gid ) {
        $primary_groupname = $id;
    }

    #otherwise, between 4k and 200k, add 100k
    else {
        if ( ( $gid >= 4000 ) && ( $uid < 200_000 ) ) {
            $aff_gid = $gid;
            $pri_gid = $uid + 100_000;
        }

        #but if above 200k, don't add 100k
        if ( $uid >= 200_000 ) {
            $aff_gid = $gid;
            $pri_gid = $uid;
        }
    }

    if ( $pri_gid > 100_000 ) {
        $primary_groupname = $id;
    }
    else { $primary_groupname = "not in groups file"; }

    %data = (
        ENGID                => $engid,
        CRSID                => $crsid,
        UID                  => $uid,
        GECOS                => $tcb[6],
        HOMEDIR              => $tcb[7],
        PASSWORD_EXPIRY_DATE => ( $tcb[13] + 129600000 ),
        PROPAGATION          => $propagation,
        capabilities         => $capabilities,
        status               => { STATUS_NAME => $tcb[12], },
        userattributes       => [
            {
                ATTRIBUTE_VALUE          => "tcb import",
                ATTRIBUTE_EFFECTIVE_DATE => $tcb[13],
                ATTRIBUTE_EXPIRY_DATE    => ( $tcb[13] + 129600000 ),
                attribute => { ATTRIBUTE_NAME => "password_changed", },
            },
        ],
    );
    if ( defined $pri_gid ) {
        push(
            @{ $data{usergroups} },
            {
                PRIMARY_GROUP     => 1,
                AFFILIATION_GROUP => 0,
                mygroup           => {
                    GID        => $pri_gid,
                    GROUP_NAME => $primary_groupname,
                }
            }
        );
    }
    if ( defined $aff_gid ) {
        push(
            @{ $data{usergroups} },
            {
                PRIMARY_GROUP     => 0,
                AFFILIATION_GROUP => 1,
                mygroup           => { GID => $aff_gid, },
            }
        );
    }
    if ( defined $data{status}{STATUS_NAME}
        && $data{status}{STATUS_NAME} =~ /(^\w*)-(\d{8})/ )
    {
        $data{status}{STATUS_NAME} = $1;
        $data{STATUS_DATE} = $2;
    }
    return ( \%data, $encpw );
}

sub print_changes {
    my $object = shift;
    my $name   = $object->result_source->name;
    my $changeline;
    if ( $object->in_storage ) {
        if ( my %changes = $object->get_dirty_columns ) {
            $changeline .= " $name : ";
            while ( my ( $key, $value ) = each %changes ) {
                $changeline .= " $key => $value ";
            }
        }
    }
    else {
        $changeline .= "Adding $name: ";
        my %fields = $object->get_columns;
        while ( my ( $key, $value ) = each %fields ) {
            $changeline .= " $key => $value ";
        }
    }
    return $changeline;
}

sub compare_hash {
    my ( $db_href, $input_href, $username ) = @_;
    my $changed;
    foreach my $key ( sort keys %$input_href ) {
        next if ( $key =~ m/^\w+?_ID$/ );
        next if ( $key eq 'PROP_DEPT' );

        #print "Looking at $key\n";
        if ( ref( $input_href->{$key} ) eq 'ARRAY' ) {
            &compare_array( $db_href->{$key}, $input_href->{$key}, $username );
        }
        elsif ( ref( $input_href->{$key} ) eq 'HASH' ) {
            &compare_hash( $db_href->{$key}, $input_href->{$key}, $username );
        }
        else {
            if ( $db_href->{$key} ne $input_href->{$key} ) {
                my ( $old_rec, $new_rec ) =
                  ( $db_href->{$key}, $input_href->{$key} );

                #$changes->{$key} = "$old_rec, $new_rec";
                printf "%-10s Change %-15s from %10s to %10s\n", $username,
                  $key, $old_rec, $new_rec
                  and $changed = 1;
            }
        }

        sub compare_array {
            my ( $old, $new, $username ) = @_;

            if ( $new->[0]{ATTRIBUTE_EFFECTIVE_DATE} ) {
                @{$new} = sort {
                    $a->{ATTRIBUTE_EFFECTIVE_DATE} <=>
                      $b->{ATTRIBUTE_EFFECTIVE_DATE}
                } @{$new};
                @{$old} = sort {
                    $a->{ATTRIBUTE_EFFECTIVE_DATE} <=>
                      $b->{ATTRIBUTE_EFFECTIVE_DATE}
                } @{$old};
            }
            if ( $new->[0]{PRIMARY_GROUP} ) {
                @{$new} =
                  sort { $a->{PRIMARY_GROUP} <=> $b->{group}{GID} } @{$new};
                @{$old} =
                  sort { $a->{PRIMARY_GROUP} <=> $b->{group}{GID} } @{$old};
            }
            for my $i ( 0 .. $#{$new} ) {
                &compare_hash( $old->[$i], $new->[$i], $username );
            }
        }
    }

    #my $diff = Data::Diff->new($db_href, $db_href);
    #my $changes = $diff->raw();

    #print Dumper $changes->{diff};
    return $changed;
}

sub get_capabilities_from_propagation {
    $_ = shift @_;

    return unless $_;

    my $capabilities = {};
    $capabilities->{PROP_TEACH}   = /T/ ? 1 : 0;
    $capabilities->{PROP_MAIL}    = /M/ ? 1 : 0;
    $capabilities->{PROP_DIVA}    = /a/ ? 1 : 0;
    $capabilities->{PROP_DIVB}    = /b/ ? 1 : 0;
    $capabilities->{PROP_DIVF}    = /F/ ? 1 : 0;
    $capabilities->{PROP_FLUID}   = /f/ ? 1 : 0;
    $capabilities->{PROP_STRUCT}  = /s/ ? 1 : 0;
    $capabilities->{PROP_WHITTLE} = /w/ ? 1 : 0;
    $capabilities->{PROP_WORKS}   = /k/ ? 1 : 0;
    $capabilities->{PROP_TEST}    = /X/ ? 1 : 0;

    #print $user->CRSID || $user->ENGID;
    #print ": \n";
    #print Dumper $RHcapabilities;

    #$capabilities_obj->set_columns($RHcapabilities);
    #$user->update_or_create_related('capabilities', $RHcapabilities);
    return $capabilities;

}

sub add_propagation {
    my $user_href = shift;
    $_ = $user_href->{PROPAGATION};

    return $user_href unless $_;

    $user_href->{capabilities}->{PROP_TEACH}   = /T/ ? 1 : 0;
    $user_href->{capabilities}->{PROP_MAIL}    = /M/ ? 1 : 0;
    $user_href->{capabilities}->{PROP_DIVA}    = /a/ ? 1 : 0;
    $user_href->{capabilities}->{PROP_DIVB}    = /b/ ? 1 : 0;
    $user_href->{capabilities}->{PROP_DIVF}    = /F/ ? 1 : 0;
    $user_href->{capabilities}->{PROP_FLUID}   = /f/ ? 1 : 0;
    $user_href->{capabilities}->{PROP_STRUCT}  = /s/ ? 1 : 0;
    $user_href->{capabilities}->{PROP_WHITTLE} = /w/ ? 1 : 0;
    $user_href->{capabilities}->{PROP_WORKS}   = /k/ ? 1 : 0;
    $user_href->{capabilities}->{PROP_TEST}    = /X/ ? 1 : 0;

    #print $user->CRSID || $user->ENGID;
    #print ": \n";
    #print Dumper $RHcapabilities;

    #$capabilities_obj->set_columns($RHcapabilities);
    #$user->update_or_create_related('capabilities', $RHcapabilities);
    return $user_href;

}

sub decode_password {
    my $crypt = shift;
    my $pwenc = "/usr/local/sbin/pwenc" unless $::pwenc;
    chomp( my $password = `$::pwenc -d $crypt` );
    return $password;
}

#sub hash_user {
#    my $user_href = ($@);
#
#    my %data = (
#        'ENGID' => $tcb[0],
#        'CRSID' => $tcb[1],
#
#        #"u_name"                => $tcb[2],
#        "UID"         => $tcb[4],
#        'user_groups' => [
#            {
#                'group' => {
#
#                    GROUP_NAME => "tcb_$tcb[5]",
#                    GID        => $tcb[5],
#                    GROUP_DESC => "tcb_$tcb[5]"
#                }
#            }
#
#        ],
#        "GECOS"           => $tcb[6],
#        "HOMEDIR"         => $tcb[7],
#        "status"          => { STATUS_NAME => $tcb[12], },
#        'userattributes' => [
#            {
#                ATTRIBUTE_VALUE          => "tcb import",
#                ATTRIBUTE_EFFECTIVE_DATE => $tcb[13],
#                ATTRIBUTE_EXPIRY_DATE    => ( $tcb[13] + 129600000 ),
#                attribute => { ATTRIBUTE_NAME => "password_changed", }
#            }
#        ],
#        "PROPAGATION" => $tcb[26]
#    );
#    if ( defined $data{status}{STATUS_NAME}
#        && $data{status}{STATUS_NAME} =~ /(^\w*)-(\d{8})/ )
#    {
#        $data{status}{STATUS_NAME} = $1;
#        $data{STATUS_DATE} = $2;
#    }
#
#    $data{'PASSWORD_EXPIRY_DATE'} =
#      $data{userattributes}[0]{ATTRIBUTE_EXPIRY_DATE};
#    return ( \%data, );
#
#}

sub parse_reg {
    my ( $format, $line ) = @_;
    my %data;
    my $handles;
    (
        $handles,       $data{"status"}, $data{"uid"},   $data{"gid"},
        $data{"gecos"}, $data{"home"},   $data{"shell"}, $data{"comment"}
    ) = split( /:/, $line );
    if ( defined $data{"comment"} ) {

        #print "You're using a new reg file format!!\n" if $opt_debug;
        $data{"capabilities"} = $data{"shell"};
        $data{"shell"}        = undef;

        #print "This should be a funny attrs string: " . $capabilities . "\n"
        #if $opt_debug;
    }
    ( $data{"engid"}, $data{"crsid"} ) = split( /,/, $handles );
    if ( defined $data{status}{STATUS_NAME}
        && $data{status}{STATUS_NAME} =~ /(^\w*)-(\d{8})/ )
    {
        $data{status}{STATUS_NAME} = $1;
        $data{STATUS_DATE} = $2;
    }

    $data{PASSWORD_EXPIRY_DATE} =
      $data{userattributes}[0]{ATTRIBUTE_EXPIRY_DATE};
    return ( \%data, );

}

1;
