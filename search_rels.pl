#!/usr/bin/perl
#
use warnings;
use strict;
use LinWin::Schema;


my $schema = LinWin::Schema->connect('dbi:SQLite:db/example.db');


my $guy_rs = $schema->resultset('User')->find(9);

#my $usergroups_rs = $guy_rs->usergroups;
#
#my $group = $usergroups_rs->first;
#print $group->GROUP_ID;
#
my $rs = $guy_rs->groups();

print $guy_rs->GECOS . "\n";

while (my $group = $rs->next) {
    print $group->GID . "< member of that group\n";
}
#my $group = $guy_rs->add_to_groups(
#
#    {
#        GROUP_NAME  => 'goodguys2',
#        GID         =>  '98',
#        GROUP_DESC  =>  'They\'re the good guys',
#        }
#        );
#
#
my $group_rs = $schema->resultset('Group')->search({ GID => 16000 });
my $group = $group_rs->single;
print "The GID for group 16000 is: " . $group->GID . "\n";

my $users_rs = $group->users();

while (my $user = $users_rs->next) {
    print $user->GECOS . "  -  " . $user->ENGID . "is a member of " . $group->GID . "\n";
}

#my $users_ingroup_rs = $schema->resultset('Group')->search_related('groups', { GID => 16000 });
#
#while (my $user = $users_ingroup_rs->next) {
#    print $user->GECOS . "  -  " . $user->ENGID . "is a member of group 16000\n";
#}
