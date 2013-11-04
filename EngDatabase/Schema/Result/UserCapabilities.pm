package EngDatabase::Schema::Result::UserCapabilities;
use base qw/DBIx::Class::Core/;
__PACKAGE__->table('PP_USER_CAPABILITIES');
__PACKAGE__->add_column(
    'CAPABILITIES_ID'     => { data_type => 'integer' },
    'USER_ID'       => { data_type => 'integer' },
    'STATUS_NAME'   => { is_nullable => 1},
    'AD_PASSWORD'   => { is_nullable => 1},
    'AUTOMOUNTER'   => { is_nullable => 1},
    'AD_ENABLED'   => { is_nullable => 1},
    'TRUST_ALLOWED'   => { is_nullable => 1},
    'UNIX_PASSWD'   => { is_nullable => 1},
    'UNIX_ENABLED'   => { is_nullable => 1},
    'PROP_DEPT'   => { is_nullable => 1},
    'PROP_MAIL'   => { is_nullable => 1},
    'PROP_DIVA'   => { is_nullable => 1},
    'PROP_DIVB'   => { is_nullable => 1},
    'PROP_DIVF'   => { is_nullable => 1},
    'PROP_FLUID'   => { is_nullable => 1},
    'PROP_STRUCT'   => { is_nullable => 1},
    'PROP_WHITTLE'   => { is_nullable => 1},
    'PROP_WORKS'   => { is_nullable => 1},
    'PROP_TEST'   => { is_nullable => 1},
);
__PACKAGE__->set_primary_key('CAPABILITIES_ID');
__PACKAGE__->add_unique_constraints([ qw/CAPABILITIES_ID USER_ID/ ]);
__PACKAGE__->belongs_to(
    user => 'EngDatabase::Schema::Result::User',
    { 'foreign.USER_ID' => 'self.USER_ID' }
);


1;
