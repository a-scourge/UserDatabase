#!/usr/bin/perl
#
use warnings;
use strict;
use LinWin::Schema;

my $schema = LinWin::Schema->connect('dbi:SQLite:db/example.db');

while (<>) {
    # The following line is good for bog-standard passwd file:
    my ($username, $password, $uid, $gid, $comment, $home, $shell) = split(/:/, $_);
    # Just some debugging to make sure we're putting the right data in:
    print "We're populating userid: $uid, username: $username, home: $home\n";
    $schema->resultset('User')->create({
            UID      =>  $uid,
            ENGID    =>  $username,
            CRSID    =>  $username,
            HOMEDIR        =>  $home,
            #GROUP_ID     =>  $gid
        });
}

