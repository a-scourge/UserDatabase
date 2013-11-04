#!/usr/bin/perl
#
use warnings;
use strict;
use Net::LDAP;
use Net::LDAP::Extra qw(AD);

## begin user documentation stuff
use Getopt::Long;
use Pod::Usage;
my $ad_addusers_VER = '0.1';


my $opt_debug   =   0;
my ($username, $opt_help, $opt_man, $opt_versions);

GetOptions(
    'debug=i'   =>  \$opt_debug,
    'username=s'  =>  \$username,
    'help!'     =>  \$opt_help,
    'man!'      =>  \$opt_man,
    'versions!' =>  \$opt_versions,
) or pod2usage(-verbose => 1) && exit;

pod2usage(-verbose => 1) && exit if ($opt_debug !~ /^[10]$/);
pod2usage(-verbose => 1) && exit if defined $opt_help;
pod2usage(-verbose => 2) && exit if defined $opt_man;
pod2usage(-verbose => 1) && exit if !defined $username;

print
    "\nModules, Perl, OS, Program info:\n",
    "  Net::LDAP          $Net::LDAP::VERSION\n",
    "  Pod::Usage            $Pod::Usage::VERSION\n",
    "  Getopt::Long          $Getopt::Long::VERSION\n",
    "  strict                $strict::VERSION\n",
    "  Perl                  $]\n",
    "  OS                    $^O\n",
    "  ad_addusers.pl            $ad_addusers_VER\n",
    "  $0\n",
    "\n\n"
    && exit if defined $opt_versions;;
## end user documentation stuff

#check that there is an file provided (with users in it):
my $ad = Net::LDAP->new( 'ldaps://colada.eng.cam.ac.uk',
    ) or die "$@";

my $result = $ad->bind( 'AD\gmj33',
    password    =>  'stihl123'
);

# Enable this to get to the bottom of AD issues
$ad->debug(12);

print "the username is >$username< . \n";

print "Please enter a password:\n";
chomp( my $password = <STDIN> );

    my $domain_name = "DC=ad,DC=eng,DC=cam,DC=ac,DC=uk";
    my $dn = "CN=$username,CN=Users,$domain_name";
    my $email       = $username . "@" . "ad.eng.cam.ac.uk";
    if ($ad->is_AD || $ad->is_ADAM) {
        $ad->reset_ADpassword( $dn, $password);
        }
    $result = $ad->modify( $dn,
        replace =>  {
            userAccountControl  => 512,  # ahhh finally we get to enable the account!!!
        }
    );

$ad->unbind();

END{
  if(defined $opt_versions){
    print
      "\nModules, Perl, OS, Program info:\n",
      "  Net::LDAP          $Net::LDAP::VERSION\n",
      "  Pod::Usage            $Pod::Usage::VERSION\n",
      "  Getopt::Long          $Getopt::Long::VERSION\n",
      "  strict                $strict::VERSION\n",
      "  Perl                  $]\n",
      "  OS                    $^O\n",
      "  ad_addusers.pl            $ad_addusers_VER\n",
      "  $0\n",
      "\n\n";
  }
}



=head1 NAME

 ad_addusers.pl

=head1 SYNOPSIS

 ad_addusers.pl ./userlist.txt

=head1 DESCRIPTION

 Add a list of users to AD. If user doesn't exist, a warning will
 be given and the program will move to the next user.

 Switches that don't define a value can be done in long or short form.
 eg:
   ad_addusers.pl --man
   ad_addusers.pl -m

=head1 ARGUMENTS

 File
 --help      print Options and Arguments instead of adding users
 --man       print complete man page instead of adding users



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

=head1 BUGS

None that I know of.

=head1 TODO

  Change the password in the same loop as the add

=head1 UPDATES

 2013-08-29   
   Added user documentation

 2013-08-22   
   Initial working code

=cut
