package EngDatabase::Schema::Result::GroupMembership;
use base qw/DBIx::Class::Core/;
__PACKAGE__->table('PP_GROUP_MEMBERSHIPS');
__PACKAGE__->add_columns(
    'GROUP_MEMBERSHIP_ID' => { data_type => 'integer' },
    'USER_ID' => { data_type => 'integer' },
    'GROUP_ID' => { data_type => 'integer' },
    'PRIMARY_GROUP'  => { data_type => 'integer' },
    'AFFILIATION_GROUP'  => { data_type  => 'integer' }
);
__PACKAGE__->set_primary_key('USER_ID');
__PACKAGE__->add_unique_constraints(
    both => [ qw/USER_ID PRIMARY_GROUP AFFILIATION_GROUP/ ],
    primarygroup => [ qw/USER_ID PRIMARY_GROUP/ ],
    affiliationgroup => [ qw/USER_ID AFFILIATION_GROUP/ ]
);
__PACKAGE__->set_primary_key('GROUP_MEMBERSHIP_ID');
__PACKAGE__->belongs_to('myuser',
    'EngDatabase::Schema::Result::User',
    { 'foreign.USER_ID' => 'self.USER_ID' },
    { proxy =>
        [ qw/ USER_ID ENGID CRSID UID GECOS HOMEDIR
        PASSWORD_EXPIRY_DATE PROPAGATION STATUS_ID STATUS_DATE/ ]
    }
);
__PACKAGE__->belongs_to('mygroup',
    'EngDatabase::Schema::Result::Group',
    { 'foreign.GROUP_ID' => 'self.GROUP_ID' },
    { proxy =>
        [ qw/ GROUP_NAME GID GROUP_DESC/ ],
        cascade_update => 1,
    }
);

1;
