#!/usr/bin/perl
#
use warnings;
use strict;
use LinWin::Schema;
## begin user documentation stuff
use Getopt::Long;
use Pod::Usage;
my $db_fixcapabilities_VER = '0.1';

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
  "  db_fixcapabilities.pl            $db_fixcapabilities_VER\n", "  $0\n", "\n\n"
  && exit
  if defined $opt_versions;
## end user documentation stuff

my $schema = LinWin::Schema->connect('dbi:SQLite:db/rand.db');
$schema->storage->debug(1) if $opt_debug;

#my $ad_enabled_rs = $schema->resultset('User')->search(                                                            
#    { 'capabilities.AD_ENABLED'  => 1 },                                                                           
#    { join  =>  'capabilities' }                                                                                   
#);

#my $statuses_rs = $schema->resultset('Status')->search( undef, { cache => 1} );

print "Press enter to see the users\n";
my $wait = <STDIN>; 
my $users_rs = $schema->resultset('User')->search(undef,
    {order_by => 'USER_ID'});


while ( my $user = $users_rs->next ) {
    #print $user_cap_obj->AD_ENABLED . "\n";
    my $username = $user->CRSID || $user->ENGID;
    print "$username: ";
    my %mygroup = $user->mygroups->get_columns;
    foreach  my $key  ( sort keys %capabilities ) {
        print "$key => $capabilities{$key}\n";
    }
}



END {
    if ( defined $opt_versions ) {
        print
          "\nModules, Perl, OS, Program info:\n",
          "  DBIx::Class          $DBIx::Class::VERSION\n",
          "  Pod::Usage            $Pod::Usage::VERSION\n",
          "  Getopt::Long          $Getopt::Long::VERSION\n",
          "  strict                $strict::VERSION\n",
          "  Perl                  $]\n",
          "  OS                    $^O\n",
          "  db_fixcapabilities.pl            $db_fixcapabilities_VER\n",
          "  $0\n",
          "\n\n";
    }
}

=head1 NAME

 db_fixcapabilities.pl

=head1 SYNOPSIS

 db_fixcapabilities.pl ./tcbfile.csv

=head1 DESCRIPTION

 Import a file into the new Engdatabase
 Default is to import a tcbfile

 Ensure that it is just pure csv (remove all double quotation marks)
 Perl doesn't need no quotation marks

 Switches that don't define a value can be done in long or short form.
 eg:
   db_fixcapabilities.pl --man
   db_fixcapabilities.pl -m

=head1 ARGUMENTS

 File
 --help      print Options and Arguments instead of importing into db
 --man       print complete man page instead of importing into db



=head1 OPTIONS

 --versions   print Modules, Perl, OS, Program info
 --debug 0    don't print debugging information (default)
 --debug 1    print debugging information

=head1 AUTHOR

  Gavin Rogers

=head1 CREDITS



=head1 TESTED

  DBIx::Class          0.08250
  Pod::Usage            1.36
  Getopt::Long          2.41
  strict                1.04
  Perl                  5.010001
  OS                    linux

=head1 BUGS

None that I know of.

=head1 TODO

  Map some dark magic to proper statuses? Find out what the dark
  magic is?

=head1 UPDATES

 2013-08-21   
   Added user documentation

 2013-08-19   
   Initial working code

=cut

## Please see file perltidy.ERR
