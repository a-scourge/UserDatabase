package EngDatabase::Schema::Result::Capabilities;
use base qw/DBIx::Class::Core/;
__PACKAGE__->table('PP_USER_CAPABILITIES');
__PACKAGE__->add_column(
    'CAPABILITIES_ID' => { data_type   => 'integer' },
      'USER_ID'       => { data_type   => 'integer' },
      'AD_ENABLED'    => { data_type => 'integer', is_nullable => 1 },
      'AD_PASSWORD'   => { data_type => 'integer', is_nullable => 1 },
      'AUTOMOUNTER'   => { data_type => 'integer', is_nullable => 1 },
      'TRUST_ALLOWED' => { data_type => 'integer', is_nullable => 1 },
      'UNIX_PASSWD'   => { data_type => 'integer', is_nullable => 1 },
      'UNIX_ENABLED'  => { data_type => 'integer', is_nullable => 1 },
      'PROP_TEACH'     => { data_type => 'integer', is_nullable => 1 },
      'PROP_MAIL'     => { data_type => 'integer', is_nullable => 1 },
      'PROP_DIVA'     => { data_type => 'integer', is_nullable => 1 },
      'PROP_DIVB'     => { data_type => 'integer', is_nullable => 1 },
      'PROP_DIVF'     => { data_type => 'integer', is_nullable => 1 },
      'PROP_FLUID'    => { data_type => 'integer', is_nullable => 1 },
      'PROP_STRUCT'   => { data_type => 'integer', is_nullable => 1 },
      'PROP_WHITTLE'  => { data_type => 'integer', is_nullable => 1 },
      'PROP_WORKS'    => { data_type => 'integer', is_nullable => 1 },
      'PROP_TEST'     => { data_type => 'integer', is_nullable => 1 },
);
__PACKAGE__->set_primary_key('CAPABILITIES_ID');
__PACKAGE__->add_unique_constraints([ qw/CAPABILITIES_ID USER_ID/ ]);
__PACKAGE__->belongs_to(
    user => 'EngDatabase::Schema::Result::User',
    { 'foreign.USER_ID' => 'self.USER_ID' }
);


1;
