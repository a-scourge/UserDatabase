#!/usr/bin/perl
#
use warnings;
use strict;

use EngDatabase::Schema;

my $schema = EngDatabase::Schema->connect('dbi:SQLite:db/example.db');

my $buddy = $schema->resultset('User')->find(3);
print $buddy->ENGID;

my $guy_rs = $schema->resultset('User')->search_like({ ENGID => 'ey%' });
while (my $guys = $guy_rs->next) {
    print "We're looking for guys named ey:";
    print $guys->ENGID . "  whose name is  " .  $guys->GECOS . "\n";
   
}
print "\n";

my $chum_rs = $schema->resultset('User')->find(3);
print "\n\n\n And now for looking at groups\n";
print $chum_rs->ENGID;
print "\n\n";
my $chum_groups = $chum_rs->groups();
print $chum_groups;

while (my $ingroup = $chum_groups->next) {
        print "This guy is a member of: \n";
        print $ingroup->GROUP_NAME;
        print "\nand maybe more?\n";
    }

my $group_rs = $schema->resultset('Group')->search({ GID => '26000' });
my $huddle = $group_rs->first;

print "A quick test, if we found a group";
print $huddle->GROUP_NAME;
print "did that work?\n";

my $rs = $huddle->users();
my $user = $rs->first;
print $user->ENGID;
while (my $user = $rs->next) {
    print "The group has:";
    print $user->ENGID;
    print "in it.\n";
}
#my @people_rs = $schema->resultset('User')->search({
#        ENGID       => { 'like', 'c%' }.
#        HOMEDIR     =>  { 'like', '%purged%' },
#    });
#
#print @people_rs;
#
#while (my $people = $people_rs->next) {
#    print $people->HOMEDIR . "\n";
#}
