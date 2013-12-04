#!/usr/bin/perl
#
use lib 'lib';
use warnings;
use strict;
use LinWin::AdUser qw(ad_unbind ad_update_or_create_user ad_finduser);
use LinWin::Format qw(parse_tcb);
#use LinWin::Schema;
use Data::Dumper;

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

#my $schema = LinWin::Schema->connect('dbi:SQLite:db/testfixed2.db');
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
#    my ($RHrecord, $encpw) = &parse_tcb($line);
#    unless ($RHrecord) {
#	warn "Unable to parse $line\n";
#	next;
#    }
    # strip off quotes.
    $line =~ s/"//g;
    my @tcb = split ',', $line;
    my $engid = $tcb[0];
    next if $engid eq 'Engid';
    my $crsid = $tcb[1];
    my $gecos = $tcb[6];
    my $encpw = $tcb[8];
    my $status = $tcb[12];
    my $pwdtime = $tcb[13];
    my $username = $crsid || $engid;

#    print Dumper $RHrecord;
#    my $username = $RHrecord->{CRSID} || $RHrecord->{ENGID}; 
#unless ($username) {
#	print "crsid ", $RHrecord->{CRSID}, "\n";
#	print "engid ", $RHrecord->{ENGID}, "\n";
#	die "No username in $line\n" unless $username;
#}
#    my $gecos = $RHrecord->{GECOS};
#    my $password = $RHrecord->{password};
#    my $status = $RHrecord->{status}->{STATUS_NAME};
    ##my $user_obj = $users_rs->find($RHrecord,
    ##    { key => 'both'},
    ##);
    my $aduser = ad_finduser($username);
    my @notlive =
    ("purge-noshow","purge-wait","expected",
        "returning","reinstated","suspended",
        "disabled","placeholder","not-set",
        "rhosts-only","setuid-only","group-web");
    my $match_string = join ("|",@notlive);
#print "Username => $username\n";
#print "Password => $encpw\n";
#print "Status => $status\n";
    if ( $status =~ m/^($match_string)/) {
	# If user is not live and not in AD, nothing to do.
	next unless $aduser;
	# Otherwise we should delete the user from AD
        printf ("%-10s not live - deleting from AD\n", $username);
	next unless $makechanges;
	$aduser->rmuser;
	next;
    }
    if ($aduser) {
	# Update existing AD user record as required.
	# DisplayName
	my $displayname = $aduser->get_value('displayName');
	unless ($displayname eq $gecos) {
	    print "Setting AD displayname for $username to $gecos\n";
	    $aduser->setgecos($gecos) if $makechanges;
	}

	# Password
	my $pwdlastset = $aduser->get_value('pwdLastSet');
	# http://support.citrix.com/article/CTX109645
	my $adpwdtime = int ($pwdlastset/10000000 - 11644473600);
	# recover password last changed timestamp.
#	my $pwdtime = 
#		$RHrecord->{userattributes}[0]->{ATTRIBUTE_EFFECTIVE_DATE};
	if ($pwdtime > $adpwdtime) {
	    print "Setting AD password for $username\n";
	    $aduser->setpassword($encpw) if $makechanges;
	}
	next;
    } 
    printf ("Adding to AD %-10s %-10s\n", $username, $gecos);
    &ad_update_or_create_user($username, $encpw, $gecos) if $makechanges;
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
