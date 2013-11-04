package EngDatabase::Schema::Result::Status;
use base qw/DBIx::Class::Core/;
__PACKAGE__->table('PP_STATUSES');
__PACKAGE__->add_column(
    'STATUS_ID'     => { data_type   => 'integer' },
    'STATUS_NAME'   => { is_nullable => 1 },
    'AD_PASSWORD'   => { is_nullable => 1 },
    'AUTOMOUNTER'   => { is_nullable => 1 },
    'AD_ENABLED'    => { is_nullable => 1 },
    'TRUST_ALLOWED' => { is_nullable => 1 },
    'UNIX_PASSWD'   => { is_nullable => 1 },
    'UNIX_ENABLED'  => { is_nullable => 1 },
    'PROP_TEACH'     => { is_nullable => 1 },
    'PROP_MAIL'     => { is_nullable => 1 },
    'PROP_DIVA'     => { is_nullable => 1 },
    'PROP_DIVB'     => { is_nullable => 1 },
    'PROP_DIVF'     => { is_nullable => 1 },
    'PROP_FLUID'    => { is_nullable => 1 },
    'PROP_STRUCT'   => { is_nullable => 1 },
    'PROP_WHITTLE'  => { is_nullable => 1 },
    'PROP_WORKS'    => { is_nullable => 1 },
    'PROP_TEST'     => { is_nullable => 1 },
);
__PACKAGE__->set_primary_key('STATUS_ID');
__PACKAGE__->add_unique_constraints( [qw/STATUS_NAME/] );

__PACKAGE__->has_many(
    users => 'EngDatabase::Schema::Result::User',
    { 'foreign.STATUS_ID' => 'self.STATUS_ID' }
);


sub get_capabilities_columns {
    my $self         = shift;
    my %capabilities = $self->get_columns;
    delete $capabilities{STATUS_NAME};
    delete $capabilities{STATUS_ID};
    delete $capabilities{PROP_DEPT};
    delete $capabilities{PROP_MAIL};
    delete $capabilities{PROP_DIVA};
    delete $capabilities{PROP_DIVB};
    delete $capabilities{PROP_DIVF};
    delete $capabilities{PROP_FLUID};
    delete $capabilities{PROP_STRUCT};
    delete $capabilities{PROP_WHITTLE};
    delete $capabilities{PROP_WORKS};
    delete $capabilities{PROP_TEST};
    return \%capabilities;

}

1;
