#!/usr/bin/perl
#
use lib 'lib';
use warnings;
use strict;
use EngDatabase::AdUser qw(ad_unbind ad_update_or_create_user ad_finduser);
use EngDatabase::Format qw(parse_tcb);
#use EngDatabase::Schema;

## begin user documentation stuff
use Getopt::Long;
use Pod::Usage;
my $ad_addusers_VER = '0.1';

our $pwenc = "/usr/local/sbin/pwenc";

our $opt_debug;
our $makechanges;
our $verbose;


my $format    = "tcb";
my ( $opt_help, $opt_man, $opt_versions );

GetOptions(
    'debug'   => \$opt_debug,
    'verbose'   => \$verbose,
    'makechanges'   => \$makechanges,
    'format=s'  => \$format,
    'help!'     => \$opt_help,
    'man!'      => \$opt_man,
    'versions!' => \$opt_versions,
) or pod2usage( -verbose => 1 ) && exit;

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
  "  ad_addusers.pl            $ad_addusers_VER\n", "  $0\n", "\n\n"
  && exit
  if defined $opt_versions;
## end user documentation stuff

#my $schema = EngDatabase::Schema->connect('dbi:SQLite:db/testfixed2.db');
#my $users_rs = $schema->resultset('User')->search(undef,
#    {
#        prefetch => 'capabilities',
#    }
#);
#$schema->storage->debug(1) if $opt_debug;

my $FIELD_COUNT = 9;    # the ul_pwd is field 9

my $message = $makechanges ? "By pressing enter you will make changes to AD.
Please press enter to continue\n" :  "Not making any changes. Press enter to do a dry run. Run with
--makechanges to make changes\n";
print $message;
my $wait = <STDIN>;

while ( my $line = <> ) {
    chomp ( $line );
    #print "$line\n";
    my $record = &parse_tcb($line);
    unless ($record) {
	warn "Unable to parse $line\n";
	next;
    }
    my $username = $record->{CRSID} || $record->{ENGID}; 
#unless ($username) {
#	print "crsid ", $record->{CRSID}, "\n";
#	print "engid ", $record->{ENGID}, "\n";
#	die "No username in $line\n" unless $username;
#}
    my $gecos = $record->{GECOS};
    my $password = $record->{password};
    ##my $user_obj = $users_rs->find($record,
    ##    { key => 'both'},
    ##);
    my @notlive =
    ("purge-noshow","purge-wait","expected",
        "returning","reinstated","suspended",
        "disabled","placeholder","not-set",
        "rhosts-only","setuid-only","group-web");
    my $match_string = join ("|",@notlive);
    #print "Username => $username\n";
    #print "Password => $password\n";
    if ( $password =~ m/^($match_string)/) {
        printf ("%-10s not AD enabled\n", $username);
        next;
    }
    printf ("Added to AD %-10s %-10s\n", $username, $gecos);
    &ad_update_or_create_user($username, $password, $gecos) if $makechanges;
}


print "No changes were made. Please user --makechanges to allow changes to take effect\n" unless $makechanges;

&ad_unbind;

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
          "  ad_addusers.pl            $ad_addusers_VER\n",
          "  $0\n",
          "\n\n";
    }
}

=head1 NAME

 ad_addusers.pl

=head1 SYNOPSIS

 ad_addusers.pl --format=tcb ./tcb.csv
 ad_addusers.pl --format=reg ./reg.csv

=head1 DESCRIPTION

 Add a list of users to AD. If user can't be added, a warning will
 be given and the program will move to the next user.

 Switches that don't define a value can be done in long or short form.
 eg:
   ad_addusers.pl --man
   ad_addusers.pl -m
 
 Note that you currently need to edit the source code to hard-code
 the location of the pwenc command.

=head1 ARGUMENTS

 File
 --help      print Options and Arguments instead of adding users
 --man       print complete man page instead of adding users
 --format=   Specify the format that the input file is in. Default: tcb



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
