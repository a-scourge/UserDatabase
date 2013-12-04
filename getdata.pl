#!/usr/bin/perl
#
use warnings;
use strict;

use LinWin::Schema;

my $schema = LinWin::Schema->connect('dbi:SQLite:db/example.db');

my $username_rs = $schema->resultset('User')->get_column('ENGID');

while ( my $c = $username_rs->next ) {
    print "$c\n";
}


## Select a row, then access a record from it:
my $test = $schema->resultset('User')->find(27);
my $print = $test->GECOS;
print "Tada: $print\n";


## Ok that was easy, now let's do it, but after giving a list of uids and asking for a choice
# Note: this while loop doesn't work because it seems like you can't select the primary key row?
# need to ask on IRC
my $uid_rs = $schema->resultset('User')->get_column('UID');

while ( my $c = $uid_rs->next ) {
    print "$c\n";
}
print "Please enter a userid from the list above\n";
# This works!!! | But of course you'll have to guess at the UID because the above doesn't work
chomp(my $uid_entered = <STDIN>);
my $search_rs = $schema->resultset('User')->find("$uid_entered");

my $username = $search_rs->ENGID;

print "The username for this uid is $username\n";
