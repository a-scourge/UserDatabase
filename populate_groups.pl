#!/usr/bin/perl
#
use warnings;
use strict;

use EngDatabase::Schema;

my $schema = EngDatabase::Schema->connect('dbi:SQLite:db/example.db');

while (<>) {
    chomp;
    # The following is for my groups file:
    my ( $groupname, $gpassword, $gid, $members ) = split( /:/, $_ );
    $schema->resultset('Group')->create(
        {
            GROUP_NAME => $groupname,
            GID        => $gid,
            GROUP_DESC => $members
        }
    );
    print "\n Group $groupname has the following members:" if ($members);

    my @members = split( /,/, $members );
    foreach (@members) {
        #Just trying to debug what goes where
        print $_ . " ";
        # First, let's go and get the UID that we need to put in here:
        my $user_rs = $schema->resultset('User')->search( { ENGID => $_ } );
        my $user    = $user_rs->first;
        my $uid     = $user->UID;
        # Now we have to go and get the GID from
        $schema->resultset('GroupMembership')->create(
            {
                USER_ID  => $uid,
                GROUP_ID => $gid
            }
        );
    }
}

