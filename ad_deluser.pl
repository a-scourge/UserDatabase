#!/usr/bin/perl
#
use warnings;
use strict;
use Net::LDAP;

## begin user documentation stuff
use Getopt::Long;
use Pod::Usage;
my $adduser_VER = '0.1';


my $opt_debug   =   0;
my ($crsid, $password, $opt_help, $opt_man, $opt_versions);
GetOptions(
    'debug=i'   =>  \$opt_debug,
    'help!'     =>  \$opt_help,
    'man!'      =>  \$opt_man,
    'versions!' =>  \$opt_versions,
    'crsid=s'    => \$crsid,
) or pod2usage(-verbose => 1) && exit;
pod2usage(-verbose => 1) && exit if !defined $crsid;
pod2usage(-verbose => 1) && exit if ($opt_debug !~ /^[10]$/);
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
    "  ad_deluser.pl            $adduser_VER\n",
    "  $0\n",
    "\n\n"
    && exit if defined $opt_versions;;
## end user documentation stuff

my $ad = Net::LDAP->new( 'ldaps://colada.eng.cam.ac.uk',
    ) or die "$@";

my $result = $ad->bind( 'AD\gmj33',
    password    =>  'stihl123'
);
# Enable this to get some LDAP language for debugging
#$ad->debug(12);

my $domain_name = "DC=ad,DC=eng,DC=cam,DC=ac,DC=uk";
my $email = $crsid . "@" . "eng.cam.ac.uk";
my $dn = "CN=" . $crsid . ",CN=Users,DC=ad,DC=eng,DC=cam,DC=ac,DC=uk";
$result = $ad->delete( $dn,
);
if ($result->code) {
    die "failed to delete entry: ", $result->error
} else {
    print "Deleted user $crsid\n";
}


$ad->unbind();





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
      "  ad_deluser.pl            $adduser_VER\n",
      "  $0\n",
      "\n\n";
  }
}


=head1 NAME

 ad_deluser.pl

=head1 SYNOPSIS

 ad_deluser.pl --crsid=someone

=head1 DESCRIPTION

 Add a single use to AD

 Simply provide a crsid.

 Switches that don't define a value can be done in long or short form.
 eg:
   ad_deluser.pl --man
   ad_deluser.pl -m

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
  ad_deluser.pl            0.1
  ./ad_deluser.pl

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
