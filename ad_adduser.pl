#!/usr/bin/perl
#
use lib './lib/';
use warnings;
use strict;
use LinWin::AD qw(ad_unbind ad_adduser);

## begin user documentation stuff
use Getopt::Long;
use Pod::Usage;
my $ad_adduser_VER = '0.1';
our $opt_debug;

my ($username, $password, $opt_help, $opt_man, $opt_versions);
my $gecos = "No full name given";
GetOptions(
    'debug'   =>  \$opt_debug,
    'help!'     =>  \$opt_help,
    'man!'      =>  \$opt_man,
    'versions!' =>  \$opt_versions,
    'username=s'    => \$username,
    'password=s'    =>  \$password,
    'gecos=s'       => \$gecos,
) or pod2usage(-verbose => 1) && exit;
pod2usage(-verbose => 1) && exit if !defined $username;
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
    "  ad_adduser.pl            $ad_adduser_VER\n",
    "  $0\n",
    "\n\n"
    && exit if defined $opt_versions;;
## end user documentation stuff
print "Debugging\n" if $opt_debug;

&ad_adduser($username, $password, $gecos);

&ad_unbind;




END{
  if(defined $opt_versions){
    print
      "\nModules, Perl, OS, Program info:\n",
      "  Net::LDAP             $Net::LDAP::VERSION\n",
      "  Pod::Usage            $Pod::Usage::VERSION\n",
      "  Getopt::Long          $Getopt::Long::VERSION\n",
      "  strict                $strict::VERSION\n",
      "  Perl                  $]\n",
      "  OS                    $^O\n",
      "  ad_adduser.pl            $ad_adduser_VER\n",
      "  $0\n",
      "\n\n";
  }
}


=head1 NAME

 ad_adduser.pl

=head1 SYNOPSIS

 ad_adduser.pl --username=someone [--password=theirpassword --gecos=" "]

=head1 DESCRIPTION

 Add a single use to AD

 Simply provide a username and optionally password and/or gecos

 Switches that don't define a value can be done in long or short form.
 eg:
   ad_adduser.pl --man
   ad_adduser.pl -m

=head1 ARGUMENTS

 File
 --help      print Options and Arguments instead of adding a user
 --man       print complete man page instead of adding a user



=head1 OPTIONS

 --versions   print Modules, Perl, OS, Program info
 --debug 0    don't print debugging information (default)
 --debug 1    print debugging information

=head1 AUTHOR

  Gavin Rogers

=head1 CREDITS



=head1 TESTED

  Net::LDAP             0.57
  Pod::Usage            1.36
  Getopt::Long          2.41
  strict                1.04
  Perl                  5.010001
  OS                    linux
  ad_adduser.pl            0.1
  ./ad_adduser.pl

=head1 BUGS

None that I know of.

=head1 TODO

  Set the password while we're at it (saves having to do a search).

=head1 UPDATES

 2013-08-21   
   Added user documentation

 2013-08-19   
   Initial working code

=cut
