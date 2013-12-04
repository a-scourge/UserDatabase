package LinWin::Schema::Result::Status;
use base qw/DBIx::Class::Core/;
__PACKAGE__->table('PP_STATUSES');
__PACKAGE__->add_column(
    'STATUS_ID' => { data_type => 'integer', size => '11', },
    'STATUS_NAME' =>
        { data_type => 'varchar2', size => '100', is_nullable => 1 },
    'AD_PASSWORD' =>
        { data_type => 'integer', size => '1', is_nullable => 1 },
    'AUTOMOUNTER' =>
        { data_type => 'integer', size => '1', is_nullable => 1 },
    'AD_ENABLED' => { data_type => 'integer', size => '1', is_nullable => 1 },
    'TRUST_ALLOWED' =>
        { data_type => 'integer', size => '1', is_nullable => 1 },
    'UNIX_PASSWD' =>
        { data_type => 'integer', size => '1', is_nullable => 1 },
    'UNIX_ENABLED' =>
        { data_type => 'integer', size => '1', is_nullable => 1 },
    'PROP_TEACH' => { data_type => 'integer', size => '1', is_nullable => 1 },
    'PROP_MAIL'  => { data_type => 'integer', size => '1', is_nullable => 1 },
    'PROP_DIVA'  => { data_type => 'integer', size => '1', is_nullable => 1 },
    'PROP_DIVB'  => { data_type => 'integer', size => '1', is_nullable => 1 },
    'PROP_DIVF'  => { data_type => 'integer', size => '1', is_nullable => 1 },
    'PROP_FLUID' => { data_type => 'integer', size => '1', is_nullable => 1 },
    'PROP_STRUCT' =>
        { data_type => 'integer', size => '1', is_nullable => 1 },
    'PROP_WHITTLE' =>
        { data_type => 'integer', size => '1', is_nullable => 1 },
    'PROP_WORKS' => { data_type => 'integer', size => '1', is_nullable => 1 },
    'PROP_TEST'  => { data_type => 'integer', size => '1', is_nullable => 1 },
);
__PACKAGE__->set_primary_key('STATUS_ID');
__PACKAGE__->add_unique_constraints( [qw/STATUS_NAME/] );

__PACKAGE__->has_many(
    users => 'LinWin::Schema::Result::User',
    { 'foreign.STATUS_ID' => 'self.STATUS_ID' }
);

sub get_capabilities {
    my $self         = shift;
    my %capabilities = $self->get_columns;
    delete $capabilities{STATUS_NAME};
    delete $capabilities{STATUS_ID};
    #delete $capabilities{PROP_DEPT};
    #delete $capabilities{PROP_MAIL};
    #delete $capabilities{PROP_DIVA};
    #delete $capabilities{PROP_DIVB};
    #delete $capabilities{PROP_DIVF};
    #delete $capabilities{PROP_FLUID};
    #delete $capabilities{PROP_STRUCT};
    #delete $capabilities{PROP_WHITTLE};
    #delete $capabilities{PROP_WORKS};
    #delete $capabilities{PROP_TEST};
    return \%capabilities;

}

1;
