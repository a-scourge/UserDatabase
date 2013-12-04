package LinWin::Schema::Result::UserAttribute;
use base qw/DBIx::Class::Core/;
__PACKAGE__->load_components(qw/ +LinWin::LinWinBase/);
__PACKAGE__->table('PP_USER_ATTRIBUTES');
__PACKAGE__->add_columns(
    'USER_ATTRIBUTE_ID' => { data_type => 'integer', size => '11', },
    'USER_ID'           => { data_type => 'integer', size => '11', },
    'ATTRIBUTE_ID'      => { data_type => 'integer', size => '11', },
    'ATTRIBUTE_VALUE' =>
        { is_nullable => 1, data_type => varchar2, size => '100' },
    'ATTRIBUTE_EFFECTIVE_DATE' => { is_nullable => 1, data_type => 'date' },
    'ATTRIBUTE_EXPIRY_DATE'    => { is_nullable => 1, data_type => 'date' },
);
__PACKAGE__->set_primary_key('USER_ATTRIBUTE_ID');
__PACKAGE__->add_unique_constraints(
    effective => [qw/USER_ID ATTRIBUTE_EFFECTIVE_DATE/],
    expiry    => [qw/USER_ID ATTRIBUTE_EXPIRY_DATE/],
    both      => [
        qw/USER_ID ATTRIBUTE_EFFECTIVE_DATE
            ATTRIBUTE_EXPIRY_DATE/
    ],
);

## Each entry in this table  belongs to a user.
#See User.pm, they can have many attributes
__PACKAGE__->belongs_to(
    user => 'LinWin::Schema::Result::User',
    { 'foreign.USER_ID' => 'self.USER_ID' },
    { cascade_delete    => 0 },
);

## Each entry in this table also has an attribute.
# See Attribute.pm: each one can have many UserAttributes
__PACKAGE__->belongs_to(
    attribute => 'LinWin::Schema::Result::Attribute',
    { 'foreign.ATTRIBUTE_ID' => 'self.ATTRIBUTE_ID' },
    {   cascade_delete => 0,
        proxy          => [qw/ ATTRIBUTE_ID ATTRIBUTE_NAME/]
    },
);

1;
