package EngDatabase::Schema::Result::User;
use strict;
use warnings;
use base qw/DBIx::Class::Core/;
use Data::Dumper;
__PACKAGE__->table('PP_USERS');
__PACKAGE__->add_columns(
    'USER_ID' => { data_type => 'integer',  size => '11', },
    'CRSID'   => { data_type => 'varchar2', size => '10' },
    'ENGID'   => { data_type => 'text',     size => '10', is_nullable => 1 },
    'UID'     => { data_type => 'integer',  size => '11', is_nullable => '1',  },
    'GECOS'   => { data_type => 'varchar2', size => '100', is_nullable => 1 },
    'HOMEDIR' => { data_type => 'varchar2', size => '100', is_nullable => 1 },
    'PASSWORD_EXPIRY_DATE' =>
        { data_type => 'varchar2', size => '100', is_nullable => 1 },
    'PROPAGATION' =>
        { data_type => 'varchar2', size => '100', is_nullable => 1 },
    'STATUS_ID'   => { data_type => 'integer', size        => '11',
        is_nullable => '1', },
    'STATUS_DATE' => { data_type => 'date',    is_nullable => 1 },
);

__PACKAGE__->set_primary_key('USER_ID');
__PACKAGE__->add_unique_constraints(
    both  => [qw/ENGID CRSID/],
    ENGID => [qw/ENGID/],
    CRSID => [qw/CRSID/],
);
__PACKAGE__->has_many(
    'usergroups' => 'EngDatabase::Schema::Result::GroupMembership',
    'USER_ID'
);
__PACKAGE__->has_one(
    'primarygroup' => 'EngDatabase::Schema::Result::GroupMembership',
    {'foreign.USER_ID' => 'self.USER_ID' },
    { where => { PRIMARY_GROUP => '1' }},
    
);
__PACKAGE__->has_one(
    'affiliationgroup' => 'EngDatabase::Schema::Result::GroupMembership',
    {'foreign.USER_ID' => 'self.USER_ID' },
    { where => { AFFILIATION_GROUP => '1' }},
);

__PACKAGE__->many_to_many( 'groups' => 'usergroups', 'group' );
## Statuses have many users. The other side to PP_STATUSES has_many is this belongs_to:
__PACKAGE__->belongs_to(
    status => 'EngDatabase::Schema::Result::Status',
    { 'foreign.STATUS_ID' => 'self.STATUS_ID' },
    {   cascade_delete => 0, # don't delete the status when you delete a user!
        cascade_copy   => 1,
    },
);

## Each user has a row in the capabilities table. A one-to-one relationship
__PACKAGE__->has_one(        # we should be able to change this to a has_one
    capabilities => 'EngDatabase::Schema::Result::Capabilities',
    { 'foreign.USER_ID' => 'self.USER_ID' },
    {   cascade_delete => 1,    # do delete the cap when you delete a user!
        cascade_copy   => 1,
    }
);
## Each user can have many many attributes added
# see the belongs_to relationship in UserAttributes
__PACKAGE__->has_many(
    userattributes => 'EngDatabase::Schema::Result::UserAttribute',
    { 'foreign.USER_ID' => 'self.USER_ID' },
    {   cascade_delete => 1,    # do delete the attr when you delete a user!
        cascade_copy   => 1,
    }
);
__PACKAGE__->many_to_many( attributes => 'userattributes', 'attribute' );
__PACKAGE__->has_one(
    'passwordchanged' => 'EngDatabase::Schema::Result::UserAttribute',
    { 'foreign.USER_ID' => 'self.USER_ID' },
    { where => { ATTRIBUTE_ID => 1 } },
);


sub _dumper_hook {
  $_[0] = bless {
    %{ $_[0] },
    result_source => undef,
  }, ref($_[0]);
}

# these subroutines return resultsets

sub primarygroup {
    my ($self) = @_;
    return $self->find(
        { 'usergroups.PRIMARY_GROUP' => '1' },
        { prefetch                   => [ { usergroups => 'mygroup' } ] }
    );
}

sub mygroups {
    my ($self) = @_;
    return $self->usergroups(
        {},
        {   order_by => 'GID',
            prefetch => ['mygroup']
        }
    );
}

sub myattributes {
    my ($self) = @_;
    return $self->userattributes(
        {},
        {   order_by => 'ATTRIBUTE_NAME',
            prefetch => ['attribute']
        }
    );
}

# this subroutine returns true or false:
sub ad_enabled {
    my $self = shift;
    return $self->capabilities->AD_ENABLED;
}

# these ones do things to the user obj
sub set_tcb {
    my ( $self, $input_href, $relationship ) = @_;
    while (my ($key, $value) = each %{$input_href->{$relationship}}) {
        if (ref($value) eq 'HASH') {
            $self->$relationship->set_tcb($value, $key);
            delete $input_href->{$key};
        }
        else {
            $self->set_column({$key => $value});
        }
    }
    $self->set_columns($input_href);
    return $self;
}
sub overrideinsert {
  my ( $self, @args ) = @_;


  $self->next::method(@args);
  #$self->create_related ('cds', \%initial_cd_data );


  return $self
}
sub update_all {
    my ( $self, $prefetch_aref ) = @_;
    my $guard = $self->result_source->schema->txn_scope_guard;
    my $username = $self->CRSID || $self->ENGID;
    sub update_obj {
        my $object = shift;
        $object->update;
     }
     foreach my $relationship (@{$prefetch_aref}) {
         if (ref($relationship) eq 'HASH') {
            while ( my ( $key, $value ) = each %{$relationship} ) {
                &update_obj($self->$key);
                &update_obj($self->$key->$value);
            }
        }
        else {
            &update_obj($self->$relationship)
        }
    }
     &update_obj($self);
    $guard->commit;
    return $self;
}
sub get_all_dirty {
    my ( $self, $prefetch_aref ) = @_;
    my $changeline;
    sub check_obj {
        my $object = shift;
        my $name = $object->result_source->name;
        if ( my %changes = $object->get_dirty_columns ) {
             $changeline .= " $name : ";
             while ( my ( $key, $value ) = each %changes ) {
                 $changeline .= " $key => $value ";
             }
         }
     }
     foreach my $relationship (@{$prefetch_aref}) {
            &check_obj($self->$relationship)
    }
     &check_obj($self);
    return $changeline;
}


{
    my $groups_rs;

    sub get_group_objects {
        my ( $self, $usergroups_aref ) = @_;
        $groups_rs =
            $self->groups->result_source->resultset->search( undef,
            { cache => '1' } )
            unless defined $groups_rs;
        my $tmp_ugroups_aref = [];
        foreach my $usergroup ( @{$usergroups_aref} ) {
            my $mygroup_obj =
                $groups_rs->find_or_new( delete $usergroup->{mygroup},
                { key => 'GID' } );
            my $gid = $mygroup_obj->GID;
            if ( $mygroup_obj->in_storage ) {
                print "$gid group already exists\n" if $::opt_debug;
            }
            else {
                print "creating group $gid\n" if $::opt_debug;
                $mygroup_obj->insert;
            }
            my $usergroup_obj =
                $self->find_or_new_related( 'usergroups', $usergroup,
                { key => 'both' } );
            if ( $usergroup_obj->in_storage ) {

                #print "Found usergroup", $usergroup_obj->GID if $::opt_debug;
                $usergroup_obj->set_columns($usergroup);
            }
            $usergroup_obj->mygroup($mygroup_obj);
            push( @{$tmp_ugroups_aref}, $usergroup_obj );

            #$usergroup->{mygroup} =  $mygroup_obj;
        }
        $usergroups_aref = $tmp_ugroups_aref;
        return $usergroups_aref;
    }
}

{
    my $attributes_rs;

    sub get_attribute_objects {
        my ( $self, $userattributes_aref ) = @_;
        $attributes_rs =
            $self->attributes->result_source->resultset->search( undef,
            { cache => '1' } )
            unless defined $attributes_rs;
        my $tmp_uattributes_aref = [];
        foreach my $userattribute ( @{$userattributes_aref} ) {
            my $attribute_obj =
                $attributes_rs->find_or_new(
                delete $userattribute->{attribute},
                { key => 'name' } );
            my $attr_name = $attribute_obj->ATTRIBUTE_NAME;
            if ( $attribute_obj->in_storage ) {
            }
            else {
                print "Creating attribute $attr_name\n";
                $attribute_obj->insert;
            }
            my $userattribute_obj =
                $self->find_or_new_related( 'userattributes', $userattribute,
                { key => 'both' },
                );
            if ( $userattribute_obj->in_storage ) {
                $userattribute_obj->set_columns($userattribute);
            }

            $userattribute_obj->attribute($attribute_obj);
            $userattribute = \$userattribute_obj;
            push( @{$tmp_uattributes_aref}, $userattribute_obj );
        }
        $userattributes_aref = $tmp_uattributes_aref;
        return $userattributes_aref;
    }
}

sub update_single {
    my ( $self, $relationship, $rel_fields ) = @_;
    print "Doing $relationship\n";
    print Dumper $rel_fields;
    my $related_obj =
        $self->find_or_new_related( "$relationship", $rel_fields );
    foreach my $field ( keys %{$rel_fields} ) {
        next unless ref( $rel_fields->{$field} ) eq "HASH";
        print "Looking for $field\n";
        my $related_obj =
            $self->$relationship->$field->search( $rel_fields->{$field} );
    }
    $related_obj->set_columns($rel_fields);
    if ( $related_obj->in_storage ) {
        my @changes = $related_obj->get_dirty_columns;
        print "$relationship: @changes";
    }
}

sub update_multi {
    my ( $self, $rel_name, $rel_fields ) = @_;
    foreach my $fields ( @{$rel_fields} ) {
        $self->update_single( $rel_name, $fields );
    }
}

sub update_user_obj {
    my ( $self, $status_obj, $groups_rs, $db_href ) = @_;
    my $username = $db_href->{CRSID} || $db_href->{ENGID};

#my $cap_obj = $user_obj->capabilities, $db_href->{capabilities};
#my %cap_changes = $user_obj->get_dirty_columns;
#print "Caps:\n";
#print Dumper \%cap_changes;
#while  (my $mygroup_obj = $user_obj->mygroups->next ) {
#    my %hash = $mygroup_obj->get_columns;
#    print $mygroup_obj->GID;
#    print Dumper \%hash;
#    print "\n";
#}
#($db_href->{usergroups}, my $group_objects) = $self->get_group_objects($db_href->{usergroups});

    foreach my $rel_name ( keys %{$db_href} ) {
        next unless ref( $db_href->{$rel_name} );
        if ( ref( $db_href->{$rel_name} ) eq "ARRAY" ) {
            $self->update_multi( $rel_name, $db_href->{$rel_name} );
        }
        elsif ( ref( $db_href->{$rel_name} ) eq "HASH" ) {
            $self->update_single( $rel_name, $db_href->{$rel_name} );
        }
        delete $db_href->{$rel_name};
    }

    delete $db_href->{status};

    foreach my $usergroup ( @{ $db_href->{usergroups} } ) {
        my $usergroup_obj;
        my $grouptype;
        if ( $usergroup->{PRIMARY_GROUP} == 1 ) {
            $grouptype = 'primarygroup';
        }
        elsif ( $usergroup->{AFFILIATION_GROUP} == 1 ) {
            $grouptype = 'affiliationgroup';
        }

        $usergroup_obj =
            $self->find_or_new_related( "$grouptype", $usergroup, );
        if ( $usergroup_obj->in_storage ) {

            #print "$username found a $grouptype object\n";
            #print Dumper $usergroup->{mygroup};
            my $mygroup_obj =
                $groups_rs->find_or_new( $usergroup->{mygroup},
                { key => 'GID' } );

            if ( $mygroup_obj->in_storage ) {
                next if $usergroup_obj->GID == $usergroup->{mygroup}{GID};
                print "$username add to existing group: "
                    . $mygroup_obj->GID . "\n";

                #$usergroup_obj->set_from_related('mygroup',
                #    $mygroup_obj) if $makechanges ;
            }
            else {
                print "$username create group " . $mygroup_obj->GID . " ";

                #$mygroup_obj->insert if $makechanges;
                #$usergroup_obj->set_from_related('mygroup',
                #    $mygroup_obj) if $makechanges ;
            }
            delete $usergroup->{mygroup};

            #$usergroup_obj->set_columns($usergroup);
            #$usergroup_obj->update if $makechanges;
            #$usergroup_obj->mygroup->update if $makechanges;
        }
        else {

            #print "Adding group " .  $usergroup_obj->GID . "\n";
            $usergroup_obj->insert;
        }

    }
    delete $db_href->{usergroups};

    foreach my $userattribute ( @{ $db_href->{userattributes} } ) {

        #print Dumper $userattribute;
        my $userattribute_obj =
            $self->userattributes->find_or_new( $userattribute,
            { key => 'both' },
            );
        my $eff_date =
            scalar(
            localtime( $userattribute_obj->ATTRIBUTE_EFFECTIVE_DATE ) );
        if ( $userattribute_obj->in_storage ) {

            #print "$username found a userattribute!\n";
            delete $userattribute->{attribute};
            $userattribute_obj->set_columns($userattribute);
            if ( my @changes = $userattribute_obj->get_dirty_columns ) {
                print "$username attribute @changes";

                #$userattribute_obj->attribute->set_columns(
                #    $userattribute->{attribute}
                #);
            }
        }
        else {

            #my @fields = $userattribute_obj->get_columns;
            print "$username: new ",
                $userattribute_obj->attribute->ATTRIBUTE_NAME,
                " effective date: $eff_date";

            #$userattribute_obj->insert if $makechanges;
        }

        #my %changes = $userattribute_obj->get_dirty_columns;
        #print Dumper \%changes;
        #$userattribute_obj->update if $makechanges;
        #$userattribute_obj->attribute->update if $makechanges;
        #push (@{$db_href->{userattributes}}, $userattribute_obj);

    }
    delete $db_href->{userattributes};

    #my $pri_group;
    #if ( my $pri_group_obj = $groups_rs->search({ GID =>
    #            $db_href->{pri_gid}})->single) {
    #    print $pri_group_obj->GROUP_NAME;
    #    print "Found a group!!!!\n";
    #    $pri_group = $pri_group_obj;
    #    } else { # otherwise, create a new one
    #        $pri_group = {
    #                GID =>  $db_href->{pri_gid},
    #                GROUP_NAME  =>  $db_href->{primary_groupname},
    #                GROUP_DESC  =>  $db_href->{primary_groupname}
    #        };
    #    }
    #print $pri_group->GROUP_NAME. "\n";
    # $user_obj->add_to_groups($pri_group, {
    #         PRIMARY_GROUP   => 1,
    #         AFFILIATION_GROUP   => 0,
    #     }
    # );
    #delete $db_href->{capabilities};
    #print Dumper $db_href;
    $self->set_columns($db_href);
    if ( my @changes = $self->get_dirty_columns ) {
        print "$username change @changes";
    }

    #$self->update($db_href) if $makechanges;
    print "\n";
}

#if (my $user_obj = $users_rs->find($db_href)) {
#    print "It changed!\n";
#    #$user_obj->update($db_href) if $makechanges;
#}
#else {
#    print "No updates on this user\n";
#    next;
#}
#}
#if ($makechanges) {
#    print Dumper $db_href;
#    print $db_href;
#    foreach my $key (sort keys %{$db_href}) {
#        print "$key => $db_href->{$key}\n";
#    }
#    $users_rs->update_or_create($db_href);
#}
#else {
#    print "Not $action user $username, ";
#    print " Please use --makechanges\n";
#}

sub get_tcb_hash {
    my $self        = shift;
    my %user_record = $self->get_columns;

    #%{$user_record{status}} = $self->status->get_columns;
    #%{$user_record{capabilities}} = $self->status->get_columns;
    my @relationships = $self->result_source->relationships();
    foreach my $relationship (@relationships) {
        my $rel_info = $self->result_source->relationship_info($relationship);
        my $rel_type = $rel_info->{attrs}->{accessor};
        if ( $rel_type eq 'single' ) {
            my %relationship_hash = $self->$relationship->get_columns;
            $user_record{$relationship} = \%relationship_hash;
        }
        elsif ( $rel_type eq 'multi' ) {
            $user_record{$relationship} = [];
            foreach my $entry ( $self->$relationship ) {
                my %entry_cols = $entry->get_columns;
                if ( $relationship eq 'usergroups' ) {
                    %{ $entry_cols{mygroup} } = $entry->mygroup->get_columns;
                }
                else {
                    %{ $entry_cols{attribute} } =
                        $entry->attribute->get_columns;
                }
                push( @{ $user_record{$relationship} }, \%entry_cols );
            }
        }
        else {
            warn "Funny kind of relationship you got there!\n";
        }

    }
    return \%user_record;
}

#sub add_tcb_data {
#    my ($self, $db_href) = @_;
#    $self->find_or_new_related('capabilities', $capabilities_href);
#    $self->find_or_new_related('status', $capabilities_href);
#    delete $self->{capabilities};
#    $self->set_inflated_columns($db_href);
#    return $self;
#}

1;
