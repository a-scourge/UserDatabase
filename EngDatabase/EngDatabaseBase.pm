package DBIx::Class::EngDatabaseBase;
use base qw(DBIx::Class);

sub update {
    my $self = shift;
    my $data = shift;
    $self->set_inflated_columns($data);
    my %changes = $self->get_dirty_columns;
    return $self->next::method;
}

1;
