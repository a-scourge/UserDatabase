#!/usr/bin/perl
#
use warnings;
use strict;
use EngDatabase::Schema;
## begin user documentation stuff
use Getopt::Long;
use Pod::Usage;
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

my $schema = EngDatabase::Schema->connect('dbi:SQLite:db/test.db');
$schema->storage->debug(1) if $opt_debug;

#my $ad_enabled_rs = $schema->resultset('User')->search(                                                            
#    { 'capabilities.AD_ENABLED'  => 1 },                                                                           
#    { join  =>  'capabilities' }                                                                                   
#);


my @groups = $schema->resultset('Group')->all();


foreach my $group (@groups) {
    print $group->GROUP_NAME . "\n"; 
    my @userids;
    foreach my $user ($group->users()) {
        my $user_id = $user->USER_ID;
        push (@userids, $user_id);
    }
    my %seen = ();
    my @dup = map { 1==$seen{$_}++ ? $_ : () } @userids;
    print "Duplicates:\n@dup\n"; 
    foreach my $user_id (@dup) {
        my $user = $schema->resultset('User')->find($user_id);
        $user->remove_from_groups($group);
        print "Removed " . $user->CRSID || $user->ENGID;
        print "from group: " . $group->GROUP_NAME . "\n";
    }
}

    my $wait = <STDIN>;
