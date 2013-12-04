#!/usr/bin/perl
#
use warnings;
use lib 'lib';
use strict;
use LinWin::Schema;
## begin user documentation stuff
use Getopt::Long;
use Pod::Usage;
my $admin_statuses_VER = '0.1';


our $opt_debug;
my ($opt_help, $opt_man, $opt_versions, $dbfile);

GetOptions(
    'debug'   =>  \$opt_debug,
    'help!'     =>  \$opt_help,
    'man!'      =>  \$opt_man,
    'versions!' =>  \$opt_versions,
    'dbfile=s' =>  \$dbfile,
) or pod2usage(-verbose => 1) && exit;

pod2usage(-verbose => 1) && exit if defined $opt_help;
pod2usage(-verbose => 2) && exit if defined $opt_man;
print
    "\nModules, Perl, OS, Program info:\n",
    "  DBIx::Class          $DBIx::Class::VERSION\n",
    "  Pod::Usage            $Pod::Usage::VERSION\n",
    "  Getopt::Long          $Getopt::Long::VERSION\n",
    "  strict                $strict::VERSION\n",
    "  Perl                  $]\n",
    "  OS                    $^O\n",
    "  admin_statuses.pl            $admin_statuses_VER\n",
    "  $0\n",
    "\n\n"
    && exit if defined $opt_versions;;
## end user documentation stuff

# we are going to create some statuses:
#
my $schema = LinWin::Schema->connect("dbi:SQLite:$dbfile");

while (<>) {

    chomp (my $line = $_);
    $line =~ s/"//g;

    my (
       $status_name,
       $ad_enabled,
       $ad_passwd,
       $trust_allowed,
       $unix_passwd,
       $unix_enabled,
       $automounter,
       $prop_teach,
       $prop_mail,
       $prop_diva,     
       $prop_divb,
       $prop_divf,
       $prop_fluid,
       $prop_struct,
       $prop_whittle,
       $prop_works,
       $prop_test
    ) = split( /,/, $line );


    # Just some debugging to make sure we're putting the right data in:
    #printf("uid:%15d gid:%10d engid: %20s home: %20s gecos: %20s\n", $uid, $gid, $engid, $home, $gecos);
    my $status = $schema->resultset('Status')->update_or_create(
        {
            STATUS_NAME     => $status_name,
            AD_ENABLED      => $ad_enabled,
            AD_PASSWORD     => $ad_passwd,
            TRUST_ALLOWED   => $trust_allowed,
            UNIX_PASSWD     => $unix_passwd,
            UNIX_ENABLED    => $unix_enabled,
            AUTOMOUNTER     => $automounter,
            PROP_TEACH       => $prop_teach,
            PROP_MAIL       => $prop_mail,
            PROP_DIVA       => $prop_diva,
            PROP_DIVB       => $prop_divb,
            PROP_DIVF       => $prop_divf,
            PROP_FLUID      => $prop_fluid,
            PROP_STRUCT     => $prop_struct,
            PROP_WHITTLE    => $prop_whittle,
            PROP_WORKS      => $prop_works,
            PROP_TEST       => $prop_test
        }
    );
}



END{
  if(defined $opt_versions){
    print
      "\nModules, Perl, OS, Program info:\n",
      "  DBIx::Class          $DBIx::Class::VERSION\n",
      "  Pod::Usage            $Pod::Usage::VERSION\n",
      "  Getopt::Long          $Getopt::Long::VERSION\n",
      "  strict                $strict::VERSION\n",
      "  Perl                  $]\n",
      "  OS                    $^O\n",
      "  admin_statuses.pl            $admin_statuses_VER\n",
      "  $0\n",
      "\n\n";
  }
}


=head1 NAME

 admin_statuses.pl

=head1 SYNOPSIS

 admin_statuses.pl ./statuses.csv

=head1 DESCRIPTION

 Import a statuses file into the new Engdatabase

 Ensure that it is just pure csv (remove all double quotation marks)
 Perl doesn't need no quotation marks

 Switches that don't define a value can be done in long or short form.
 eg:
   admin_statuses.pl --man
   admin_statuses.pl -m

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
