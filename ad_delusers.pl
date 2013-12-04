#!/usr/bin/perl
#
use warnings;
use strict;
use Net::LDAP;
use LinWin::Format qw(parse_tcb);

## begin user documentation stuff
use Getopt::Long;
use Pod::Usage;
my $ad_delusers_VER = '0.1';

my $opt_debug = 0;
my ( $opt_help, $opt_man, $opt_versions );
my $format = "tcb";
GetOptions(
    'debug=i'   => \$opt_debug,
    'help!'     => \$opt_help,
    'man!'      => \$opt_man,
    'versions!' => \$opt_versions,
    'format=s'  =>  \$format
) or pod2usage( -verbose => 1 ) && exit;

pod2usage( -verbose => 1 ) && exit if ( $opt_debug !~ /^[10]$/ );
pod2usage( -verbose => 1 ) && exit if defined $opt_help;
pod2usage( -verbose => 2 ) && exit if defined $opt_man;
print
  "\nModules, Perl, OS, Program info:\n",
  "  Net::LDAP          $Net::LDAP::VERSION\n",
  "  Pod::Usage            $Pod::Usage::VERSION\n",
  "  Getopt::Long          $Getopt::Long::VERSION\n",
  "  strict                $strict::VERSION\n",
  "  Perl                  $]\n",
  "  OS                    $^O\n",
  "  ad_delusers.pl            $ad_delusers_VER\n", "  $0\n", "\n\n"
  && exit
  if defined $opt_versions;
## end user documentation stuff
# give a message if no argument was provided:
if ( !defined $ARGV[0] ) {
    warn "No filename provided\n";
    pod2usage( -verbose => 1 ) && exit;
}

my $ad = Net::LDAP->new( 'ldaps://colada.eng.cam.ac.uk', ) or die "$@";

my $mesg = $ad->bind( 'AD\gmj33', password => 'stihl123' );

$ad->debug(12);

while (<>) {

    my ($db_href)  = &parse_tcb( $_ );
    print "The engid is $db_href->{ENGID} . \n" if $opt_debug;
    my $username;
    if ($db_href->{CRSID} && $db_href->{CRSID} ne "" ) {
        $username = $db_href->{CRSID};
    }
    else {
        $username = $db_href->{ENGID};
    }
    my $domain_name = "DC=ad,DC=eng,DC=cam,DC=ac,DC=uk";
    my $email       = $username . "@" . "eng.cam.ac.uk";
    my $dn = "CN=" . $username . ",CN=Users,DC=ad,DC=eng,DC=cam,DC=ac,DC=uk";
    $mesg = $ad->delete( $dn );
    $mesg->code && warn "failed to delete entry: ", $mesg->error;
    print "Deleted user $username\n";
}

$ad->unbind();

END {
    if ( defined $opt_versions ) {
        print
          "\nModules, Perl, OS, Program info:\n",
          "  Net::LDAP          $Net::LDAP::VERSION\n",
          "  Pod::Usage            $Pod::Usage::VERSION\n",
          "  Getopt::Long          $Getopt::Long::VERSION\n",
          "  strict                $strict::VERSION\n",
          "  Perl                  $]\n",
          "  OS                    $^O\n",
          "  ad_delusers.pl            $ad_delusers_VER\n",
          "  $0\n",
          "\n\n";
    }
}

=head1 NAME

 ad_delusers.pl

=head1 SYNOPSIS

 ad_delusers.pl ./userlist.txt

=head1 DESCRIPTION

 Delete a list of users

 Arguments are files which contain usernames on separate lines

 Switches that don't define a value can be done in long or short form.
 eg:
   ad_delusers.pl --man
   ad_delusers.pl -m

=head1 ARGUMENTS

 File
 --help      print Options and Arguments instead of deleting users.
 --man       print complete man page instead of deleting users.



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
