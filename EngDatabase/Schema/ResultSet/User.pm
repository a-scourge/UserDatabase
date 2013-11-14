package EngDatabase::Schema::ResultSet::User;
use strict;
use warnings;
use base qw/DBIx::Class::ResultSet DBIx::Class::ResultSet::RecursiveUpdate/;

sub ad_enabled {
    my $self = shift;
    
    return $self->search(
        { 'capabilities.AD_ENABLED' => '1' },
        { join  =>  'capabilities', order_by => 'UID' }
    );
}



1;
