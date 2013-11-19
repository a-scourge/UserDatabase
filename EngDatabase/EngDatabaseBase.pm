package EngDatabase::EngDatabaseBase;
use base qw(DBIx::Class);

sub update {
    my $self = shift;
    my @data = @_;
    $self->set_inflated_columns(@data);
    my %changes = $self->get_dirty_columns;
    my $name = $self->result_source->name;
    print "$name:" if %changes;
    while ( my ($key, $value) = each %changes) {
        print "$key => $value, ";
    }
    return $self->next::method( @data );
}

1;
