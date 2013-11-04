#!/usr/bin/perl
#
use warnings;
use strict;
use EngDatabase::Schema;

my $schema = EngDatabase::Schema->connect('dbi:SQLite:db/example.db');

$schema->storage->debug(1);

$schema->storage->create_ddl_dir();
