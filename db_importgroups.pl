#!/usr/bin/perl
#
use warnings;
use strict;
use EngDatabase::Schema;
use EngDatabase::Format qw(parse_grp);
## begin user documentation stuff
use Getopt::Long;
use Pod::Usage;
use Data::Dumper;
my $db_importgroups_VER = '0.1';

my $opt_debug = 0;
my $do_users = 0;
my ( $opt_help, $opt_man, $opt_versions );
my $format = "grp";

GetOptions(
    'debug=i'   => \$opt_debug,
    'help!'     => \$opt_help,
    'man!'      => \$opt_man,
    'versions!' => \$opt_versions,
    'format=s'  => \$format,
    'do_users=i' => \$do_users
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
  "  db_importgroups.pl            $db_importgroups_VER\n", "  $0\n", "\n\n"
  && exit
  if defined $opt_versions;
## end user documentation stuff

my $schema = EngDatabase::Schema->connect('dbi:SQLite:db/test.db');
print @ARGV . "\n" if $opt_debug;
$schema->storage->debug(1) if $opt_debug;

my $users_rs = $schema->resultset('User')->search( undef, { cache => 1 } );
my %engids;
my %crsids;
while ( my $user = $users_rs->next ) {
    $engids{ $user->ENGID } = 1;
    $crsids{ $user->CRSID } = 1;
}

my %grouphashes;
while (<>) {
    chomp( my $line = $_ );
    print "The input line is: $line\n" if $opt_debug;
    my $RHgroup = parse_grp($line);
    my $gid           = $RHgroup->{GID};
    delete $RHgroup->{users};

    $grouphashes{$gid} = $RHgroup;
    #print "The big hash is: \n";
    print Dumper( \%grouphashes ) if $opt_debug;
    my $wait = <STDIN> if $opt_debug;
}

my @poparray = values %grouphashes;
my $count    = @poparray;

print "The number of records is $count\n Populating DB... \n";

$schema->resultset('Group')->populate( \@poparray );


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
          "  db_importgroups.pl            $db_importgroups_VER\n",
          "  $0\n",
          "\n\n";
    }
}

=head1 NAME

 db_importgroupsgroups.pl

=head1 SYNOPSIS

 db_importgroups.pl ./groups

=head1 DESCRIPTION

 Import groups from a groups file.
 This doesn't handle users. If you want the users in a groups file to be added
 to the group, then ensure the users are alread in the database, and then use
 the db_adduserstogroups.pl
 Default is to import a tcbfile

 Ensure that it is just pure csv (remove all double quotation marks)
 Perl doesn't need no quotation marks

 Switches that don't define a value can be done in long or short form.
 eg:
   db_importgroups.pl --man
   db_importgroups.pl -m

=head1 ARGUMENTS

 File
 
 --format=fmt Format types are grp (default)

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
