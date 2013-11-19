package EngDatabase::Schema::Result::GroupMembership;
use base qw/DBIx::Class::Core/;
__PACKAGE__->load_components(qw/ +EngDatabase::EngDatabaseBase/);
__PACKAGE__->table('PP_GROUP_MEMBERSHIPS');
__PACKAGE__->add_columns(
    'GROUP_MEMBERSHIP_ID' => { data_type => 'integer', size => '11', },
    'USER_ID'             => { data_type => 'integer', size => '11', },
    'GROUP_ID'            => { data_type => 'integer', size => '11', },
    'PRIMARY_GROUP'       => { data_type => 'integer', size => '1',
        is_nullable => '1', },
    'AFFILIATION_GROUP'   => { data_type => 'integer', size => '1',
        is_nullable => '1', }
);
__PACKAGE__->set_primary_key('GROUP_MEMBERSHIP_ID');
__PACKAGE__->add_unique_constraints(
#    primarygroup     => [qw/GROUP_MEMBERSHIP_ID PRIMARY_GROUP/],
#    affiliationgroup => [qw/GROUP_MEMBERSHIP_ID AFFILIATION_GROUP/],
    both             => [qw/AFFILIATION_GROUP PRIMARY_GROUP/],
);
__PACKAGE__->belongs_to(
    'myuser',
    'EngDatabase::Schema::Result::User',
    { 'foreign.USER_ID' => 'self.USER_ID' },
    #{   proxy => [
    #        qw/ USER_ID ENGID CRSID UID GECOS HOMEDIR
    #            PASSWORD_EXPIRY_DATE PROPAGATION STATUS_ID STATUS_DATE/
    #    ]
    #}
);
__PACKAGE__->belongs_to(
    'mygroup',
    'EngDatabase::Schema::Result::Group',
    { 'foreign.GROUP_ID' => 'self.GROUP_ID' },
    {   
        cascade_update => 1,
    }
);

1;
