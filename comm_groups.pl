#!/usr/bin/perl
#
use warnings;
use strict;
use LinWin::Format qw(parse_grp);
## begin user documentation stuff
use Getopt::Long;
use Pod::Usage;
use Data::Dumper;
my $comm_groups_VER = '0.1';

my $opt_debug = 0;
my ( $dbfile, $extantfile, $opt_help, $opt_man, $opt_versions );

GetOptions(
    'debug=i'   => \$opt_debug,
    'help!'     => \$opt_help,
    'man!'      => \$opt_man,
    'versions!' => \$opt_versions,
    'dbfile=s'  => \$dbfile,
    'extantfile=s'  => \$extantfile,
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
  "  comm_groups.pl            $comm_groups_VER\n", "  $0\n", "\n\n"
  && exit
  if defined $opt_versions;
## end user documentation stuff

open DBFILE, '<', "groupsdb";
my %dbfile;
while ( <DBFILE> ) {
    chomp( my $line = $_ );
    my $RHgroup = parse_grp($line);
    print Dumper $RHgroup;
    my $gid = $RHgroup->{GID};
    $dbfile{$gid} = $RHgroup;
    #print Dumper %dbfile;
    #my $wait = <STDIN>;
}
close DBFILE;

open PPFILE, '<', "groupcheck";
my %ppfile;
while ( <PPFILE> ) {
    chomp( my $line = $_ );
    my $RHgroup = parse_grp($line);
    print Dumper $RHgroup;
    my $gid = $RHgroup->{GID};
    $ppfile{$gid} = $RHgroup;
}
close PPFILE;

open GROUPSLIST, '>', "groupslist";

foreach my $gid ( sort { $a <=> $b } keys %ppfile ) {
    printf GROUPSLIST "%s%30s\n", $dbfile{$gid}->{GROUP_NAME},
    $ppfile{$gid}->{GROUP_NAME}; 
}

foreach my $gid ( sort { $a <=> $b } keys %dbfile ) {
    print "The group: $dbfile{$gid}->{GROUP_NAME} \n";
    #if ($dbfile{$gid}->{users} eq $ppfile{$gid}->{users}) {
    #    print "They have the same users\n";
    #}
    my @dbusers = sort @{$dbfile{$gid}->{users}};
    my @ppusers = sort @{$ppfile{$gid}->{users}};
    next if @dbusers ~~ @ppusers;
    print "dbusers = @dbusers\n";
    print "Only in db: ";
    my %onlydb;
    @onlydb{ @dbusers } = undef;
    delete @onlydb{ @ppusers };
    my @onlydb =  keys %onlydb;
    print "@onlydb\n";
    print "Only in pp: ";
    my %onlypp;
    @onlypp{ @ppusers } = undef;
    delete @onlypp{ @dbusers };
    my @onlypp = keys %onlypp;
    print "@onlypp\n";
    my $wait = <STDIN>;

}
