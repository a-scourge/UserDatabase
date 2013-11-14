package EngDatabase::Schema;
use warnings;
use strict;

use base qw/DBIx::Class::Schema/;
our $VERSION = '0.23';
__PACKAGE__->load_namespaces( default_resultset_class =>
    '+DBIx::Class::ResultSet::RecursiveUpdate' );

1;
