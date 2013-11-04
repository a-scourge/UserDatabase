#!/usr/bin/perl
#
#
use strict;
use warnings;

use EngDatabase::Schema;

my $schema = EngDatabase::Schema->connect('dbi:SQLite:db/example.db');

my $rs = $schema->resultset('Group')->search_like({ GID => '%' });
#while (my $thing = $rs->next) {
#    print $thing->USER_ID . "\n";
#}
#
while (my $group = $rs->next) {
    print $group->GROUP_NAME . ' - ' . $group->GID . "and the users are:" . $group->users .  "\n";
}

#while (my $person = $rs->next) {
#    print $person->CRSID . ' - ' . $person->GECOS .  ' - ' . $person->groups . "\n";
#}
