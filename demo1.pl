#!/usr/bin/perl
#
use warnings;
use strict;

use EngDatabase::Schema;

my $schema = EngDatabase::Schema->connect('dbi:SQLite:db/example.db');

#my $username_rs = $schema->resultset('Users')->get_column('acctname');
#
#while ( my $c = $username_rs->next ) {
#    print "$c\n";
#}
#
#
### Select a row, then access a record from it:
#my $test = $schema->resultset('Users')->find(27);
#my $print = $test->acctname;
#print "Tada: $print\n";
#
#
## Find all usernames which have a home in /var
#print "We're now going to find all users who have a home in /var\n";
#my $findvar_rs = $schema->resultset('Users')->search_like({ home => '/var%' });
#while (my $listthem = $findvar_rs->next) {
#    print $listthem->home . ' aha we found one here, belonging to '  . $listthem->acctname . "\n";
#    $listthem->userinfo('Has a home in /var');
#    $listthem->update;
#}
#
### Ok that was easy, now let's do it, but after giving a list of uids and asking for a choice
## Note: this while loop doesn't work because it seems like you can't select the primary key row?
## need to ask on IRC
#my $uid_rs = $schema->resultset('Users')->get_column("acctid");
#
#while ( my $c = $uid_rs->next ) {
#    print "$c\n";
#}
#
#print "Please enter a userid from the list above\n";
## This works!!! | But of course you'll have to guess at the UID because the above doesn't work
#chomp(my $uid_entered = <STDIN>);
#my $search_rs = $schema->resultset('Users')->find("$uid_entered");
#
#my $username = $search_rs->acctname;
#
#print "The username for this uid is $username\n";


my @all_users = $schema->resultset('User')->all;

foreach my $user (@all_users) {
    print $user->ENGID . ": statusid is: " . $user->STATUS_ID . ", status is: " . $user->status->STATUS_NAME . "\n";
}

