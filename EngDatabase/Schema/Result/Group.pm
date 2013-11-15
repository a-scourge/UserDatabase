package EngDatabase::Schema::Result::Group;
use base qw/DBIx::Class::Core/;
__PACKAGE__->table('PP_GROUPS');
__PACKAGE__->add_columns(
    'GROUP_ID'   => { data_type => 'integer', size => '11', },
    'GID'        => { data_type => 'integer', size => '11', },
    'GROUP_NAME' => {
        data_type   => 'varchar2',
        size        => '50',
        is_nullable => 1,
    },
    'GROUP_DESC' =>
        { data_type => 'varchar2', size => '100', is_nullable => 1 },
);
__PACKAGE__->set_primary_key('GROUP_ID');
__PACKAGE__->add_unique_constraints( GID => [qw/GID/] );
__PACKAGE__->has_many(
    'usergroups',
    'EngDatabase::Schema::Result::GroupMembership',
    { 'foreign.GROUP_ID' => 'self.GROUP_ID' }
);
__PACKAGE__->many_to_many( 'users' => 'usergroups', 'user' );

1;
