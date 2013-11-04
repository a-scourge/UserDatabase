package EngDatabase::Schema::Result::Group;
use base qw/DBIx::Class::Core/;
__PACKAGE__->table('PP_GROUPS');
__PACKAGE__->add_columns(
    'GROUP_ID'    => { data_type => 'integer' },
    'GID'           => { data_type => 'integer' },
    'GROUP_NAME'     => { data_type => 'text' , is_nullable => 1 },
    'GROUP_DESC'    => { data_type => 'text', is_nullable => 1},
);
__PACKAGE__->set_primary_key('GROUP_ID');
__PACKAGE__->add_unique_constraints(
    GID     => [ qw/GID/ ]
);
__PACKAGE__->has_many('usergroups',
    'EngDatabase::Schema::Result::GroupMembership',
    { 'foreign.GROUP_ID' => 'self.GROUP_ID'}
);
__PACKAGE__->many_to_many('users' => 'usergroups', 'myuser');


1;
