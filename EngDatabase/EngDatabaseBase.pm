package EngDatabase::EngDatabaseBase;
use base qw(DBIx::Class);
use Data::Dumper;

sub update {
    my ($self, $upd) = @_;
    $self->set_inflated_columns($upd);
    if ( my %changes = $self->get_dirty_columns ) {
        my $name = $self->result_source->name; # if %changes;
        print "$name:";
        while ( my ($key, $value) = each %changes) {
            print "$key => $value, ";
        }
    }
    return $self->next::method( );
}


sub insert {
    my ($self, $upd) = @_;
    $self->set_inflated_columns($upd);
    my %changes = $self->get_dirty_columns;
    my $name = $self->result_source->name;
    print "$name:" if %changes;
    while ( my ($key, $value) = each %changes) {
        print "$key => $value, ";
    }
    return $self->next::method( $upd );
}

1;
