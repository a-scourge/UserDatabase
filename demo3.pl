#!/usr/bin/perl
#
use warnings;
use strict;
use LinWin::Schema;


my $schema = LinWin::Schema->connect('dbi:SQLite:db/example.db');

## Get a resultset for users who have the word "purged" in homedir:
my $guys_rs = $schema->resultset('User')->search_like({ HOMEDIR => '%purged%' });
## Outside loop grabs one person at a time:
while (my $guy = $guys_rs->next) {
    print "\nThe guy: " . $guy->ENGID . " is a member of: ";
    my $guy_groups = $guy->groups();
    while (my $g = $guy_groups->next) { # this inside loop prints all the groups for each guy
        my $gid = $g->GID;
        print "$gid  ";
    }
}

#my $inside_rs = $schema->resultset('User')->search({
#        print "\n Looking for gmpc2 and ebg24\n";
#        ENGID => [ 'gmpc2', 'ebg24' ],
#    }
#);
#
#my $rs = $schema->resultset('GroupMembership')->search({
#        USER_ID => { -in => $inside_rs->get_column('USER_ID')->as_query },
#    }
#);
#
#while (my $column = $rs->next) {
#    print $column->GROUP_MEMBERSHIP_ID . " - " . $column->USER_ID . " - " . $column->GROUP_ID;
#    print "\n";
#}
##print $rs->next->GROUP_MEMBERSHIP_ID . " - " . $rs->next->USER_ID . " - " . $rs->next->GROUP_ID;
#
#
#
#my $guy = $schema->resultset('User')->search({ ENGID => 'glb33' });
#my $thisguy = $guy->single;
#my $guy_groups = $thisguy->groups();
#while (my $g = $guy_groups->next) {
#    my $gid = $g->GID;
#    print "gmr34 is in group $gid.\n";
#}
#

#my $group_id=26000;
#my $users = $schema->resultset('User')->in_group($group_id);
#while (my $u = $users->next) {
#    print "User: " . $u->ENGID . ", group: " . $u->get_column('PP_GROUP_MEMBERSHIPS.GROUP_ID');
#}
