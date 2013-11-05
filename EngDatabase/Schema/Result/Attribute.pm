package EngDatabase::Schema::Result::Attribute;
use base qw/DBIx::Class::Core/;
__PACKAGE__->table('PP_ATTRIBUTES');
__PACKAGE__->add_column(
    'ATTRIBUTE_ID'   => { data_type => 'integer',  size => '11', },
    'ATTRIBUTE_NAME' => { data_type => 'varchar2', size => '100', },
);
__PACKAGE__->set_primary_key('ATTRIBUTE_ID');
__PACKAGE__->add_unique_constraints( name => [qw/ATTRIBUTE_NAME/] );

__PACKAGE__->has_many(
    userattributes => 'EngDatabase::Schema::Result::Attribute',
    { 'foreign.ATTRIBUTE_ID' => 'self.ATTRIBUTE_ID' }
);
__PACKAGE__->many_to_many( users => 'userattributes', 'user' );

1;
