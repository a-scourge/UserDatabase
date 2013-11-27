package EngDatabase::EngDatabaseBase;
use base qw(DBIx::Class);
use Data::Dumper;

sub hello {
    print "Hello\n";
}

sub update {
    my ($self, $upd) = @_;
    #print Dumper $upd;
    $self->set_inflated_columns($upd);
    my %oldvalues = $self->get_columns if $::opt_verbose;
    if ( my %changes = $self->get_dirty_columns ) {
        my $name = $self->result_source->name; # if %changes;
        print "$name ";
        print "was: " if %oldvalues;
        while ( my ($key, $value) = each %oldvalues) {
            print "$key => $value, ";
        }
        print "change: ";
        while ( my ($key, $value) = each %changes) {
            print "$key => $value, ";
        }
    }
    return $self->next::method( );
}


sub insert {
    my ($self) = @_;
    #$self->set_inflated_columns($upd);
    my %changes = $self->get_columns;
    my $name = $self->result_source->name;
    print "Creating $name:" if %changes;
    while ( my ($key, $value) = each %changes) {
        print "$key => $value, ";
    }
    return $self->next::method( $upd );
}

1;
