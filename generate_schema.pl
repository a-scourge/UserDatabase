#!/usr/bin/perl
use strict;
use warnings;
use lib 'lib/lib/perl5';


use Pod::Usage;
use Getopt::Long;
use EngDatabase::Schema;

my ( $preversion, $help );
GetOptions(
        'p|preversion:s'  => \$preversion,
        ) or die pod2usage;


my $schema = EngDatabase::Schema->connect('dbi:SQLite:db/example.db');
my $version = $schema->schema_version();

if ($version && $preversion) {
    print "creating diff between version $version and $preversion\n";
} elsif ($version && !$preversion) {
    print "creating full dump for version $version\n";
} elsif (!$version) {
    print "creating unversioned full dump\n";
}

my $sql_dir = './db';
$schema->create_ddl_dir( ['MySQL', 'SQLite', 'Oracle'], $version, $sql_dir, $preversion );
