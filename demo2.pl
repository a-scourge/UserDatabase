#!/usr/bin/perl
#
use warnings;
use strict;

use LinWin::Schema;

my $schema = LinWin::Schema->connect('dbi:SQLite:db/example.db');

## Select a row, then access a record from it:
print "We're going to look for the username for uid 27:\n";
my $test = $schema->resultset('User')->find(27);
my $print = $test->ENGID;
print "Tada: $print\n";

#Does a get_column and prints that column out
my $username_rs = $schema->resultset('User')->get_column('ENGID');
while ( my $c = $username_rs->next ) {
    print "$c\n";
}


print "Please enter a username from the list above\n";
# Does a search using what you enter:
chomp(my $username_entered = <STDIN>);
my $search_rs = $schema->resultset('User')->search({ ENGID => "$username_entered" });

my $home = $search_rs->first;
print "The home directory for this user is ";
print $home->HOMEDIR;
print ", I hope this helps\n";


# Just wanting to print out the columns for my own benefit:
my $comment_rs = $schema->resultset('User')->get_column('GECOS');
while ( my $comment = $comment_rs->next ) {
    print "$comment\n";
}

# Ok nvm let me do a search?
#
print "Please search from the above names:\n";
chomp(my $string = <STDIN>);
my $searchvar_rs = $schema->resultset('User')->search({ GECOS => { -like => "%$string%" } });
while (my $foundvar = $searchvar_rs->next) {
    print $foundvar->GECOS . ' - ' . $foundvar->ENGID . "\n";
}
print "You might find it interesting, this search: \n";
my $groups = $searchvar_rs->search_related('usergroups', { GID => 2600 , });
while (my $groups = $groups->next) {
    print $groups->GID;
}

