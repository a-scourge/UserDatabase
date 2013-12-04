#!/usr/bin/perl
#
use warnings;
use strict;
use LinWin::Schema;

my $schema = LinWin::Schema->connect('dbi:SQLite:db/example.db');

$schema->storage->debug(1);

$schema->storage->create_ddl_dir();
