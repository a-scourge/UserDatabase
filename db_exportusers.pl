#!/usr/bin/perl
#
use warnings;
use strict;
use LinWin::Schema;
## begin user documentation stuff
use Getopt::Long;
use Pod::Usage;
use Data::Dumper;
my $db_export_groups_VER = '0.1';

my $opt_debug = 0;
my ( $status_name, $opt_help, $opt_man, $opt_versions );

GetOptions(
    'debug=i'   => \$opt_debug,
    'help!'     => \$opt_help,
    'man!'      => \$opt_man,
    'versions!' => \$opt_versions,
) or pod2usage( -verbose => 1 ) && exit;

pod2usage( -verbose => 1 ) && exit if ( $opt_debug !~ /^[10]$/ );
pod2usage( -verbose => 1 ) && exit if defined $opt_help;
pod2usage( -verbose => 2 ) && exit if defined $opt_man;
print
  "\nModules, Perl, OS, Program info:\n",
  "  DBIx::Class          $DBIx::Class::VERSION\n",
  "  Pod::Usage            $Pod::Usage::VERSION\n",
  "  Getopt::Long          $Getopt::Long::VERSION\n",
  "  strict                $strict::VERSION\n",
  "  Perl                  $]\n",
  "  OS                    $^O\n",
  "  db_export_groups.pl            $db_export_groups_VER\n", "  $0\n", "\n\n"
  && exit
  if defined $opt_versions;
## end user documentation stuff

print "Please enter a username:\n";
chomp (my $username = <STDIN>);
my $schema = LinWin::Schema->connect('dbi:SQLite:db/test.db');
$schema->storage->debug(1) if $opt_debug;

my $users_rs = $schema->resultset('User')->search(
      { -or=>[
          { 'CRSID' => $username }, { 'ENGID' => $username }
     ]}
  );

while ( my $user = $users_rs->next) {
    #my $groups_rs =
    my $pri_group = $user->search_related('usergroups',
        { PRIMARY_GROUP => 1}
    )->single;
    print "Primary group: " .  $pri_group->mygroup->GROUP_NAME . "\n";
    print "Status: " . $user->status->STATUS_NAME . "\n";
    my %capabilities = $user->capabilities->get_columns;
    print "Capabilities: ";
    print Dumper \%capabilities;
    print "\n";
    my $groups_rs = $user->usergroups;
    while ( my $group = $groups_rs->next) {
        print "Primary?: " . $group->PRIMARY_GROUP . " ";
        print "Affiliation?: "  . $group->AFFILIATION_GROUP . " ";
        print $group->mygroup->GID;
        print " " . $group->mygroup->GROUP_NAME . "\n";
    }
    &print_passwd($user);
    print "\n";
}



sub print_passwd {
    my $user = $_[0];
    print $user->CRSID || $user->ENGID;
    print ":x:";
    print $user->UID;
    print ":";
}

