#!/usr/bin/perl
#
use warnings;
use strict;
use LinWin::Schema;
## begin user documentation stuff
use Getopt::Long;
use Pod::Usage;
my $db_import_VER = '0.1';

my $opt_debug = 0;
my ( $gid, $opt_help, $opt_man, $opt_versions );

GetOptions(
    'debug=i'   => \$opt_debug,
    'help!'     => \$opt_help,
    'man!'      => \$opt_man,
    'versions!' => \$opt_versions,
    'gid=s'    => \$gid,
) or pod2usage( -verbose => 1 ) && exit;

pod2usage( -verbose => 1 ) && exit if ( $opt_debug !~ /^[10]$/ );
pod2usage( -verbose => 1 ) && exit if defined $opt_help;
pod2usage( -verbose => 2 ) && exit if defined $opt_man;
pod2usage( -verbose => 2 ) && exit if !defined $gid;
print
  "\nModules, Perl, OS, Program info:\n",
  "  DBIx::Class          $DBIx::Class::VERSION\n",
  "  Pod::Usage            $Pod::Usage::VERSION\n",
  "  Getopt::Long          $Getopt::Long::VERSION\n",
  "  strict                $strict::VERSION\n",
  "  Perl                  $]\n",
  "  OS                    $^O\n",
  "  db_import.pl            $db_import_VER\n", "  $0\n", "\n\n"
  && exit
  if defined $opt_versions;
## end user documentation stuff

my $schema = LinWin::Schema->connect('dbi:SQLite:db/test.db');
print @ARGV . "\n" if $opt_debug;

my $group_obj = $schema->resultset('Group')->search({ GID => $gid })->single;
print $group_obj->GROUP_NAME . "\n";
$group_obj->delete;
print "The group $gid has been deleted\n";



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
          "  db_import.pl            $db_import_VER\n",
          "  $0\n",
          "\n\n";
    }
}

=head1 NAME

 db_import.pl

=head1 SYNOPSIS

 db_import.pl ./tcbfile.csv

=head1 DESCRIPTION

 Import a file into the new Engdatabase
 Default is to import a tcbfile

 Ensure that it is just pure csv (remove all double quotation marks)
 Perl doesn't need no quotation marks

 Switches that don't define a value can be done in long or short form.
 eg:
   db_import.pl --man
   db_import.pl -m

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
