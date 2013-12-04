#!/usr/bin/perl
#
use warnings;
use strict;
use LinWin::Schema;
## begin user documentation stuff
use Getopt::Long;
use Pod::Usage;
use Data::Dumper;
my $db_nonuniqueUID_VER = '0.1';

my $opt_debug = 0;
my ( $status_name, $opt_help, $opt_man, $opt_versions );

GetOptions(
    'debug=i'   => \$opt_debug,
    'help!'     => \$opt_help,
    'man!'      => \$opt_man,
    'versions!' => \$opt_versions,
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
  "  db_nonuniqueUID.pl            $db_nonuniqueUID_VER\n", "  $0\n", "\n\n"
  && exit
  if defined $opt_versions;
## end user documentation stuff

my $schema = LinWin::Schema->connect('dbi:SQLite:db/test.db');
$schema->storage->debug(1) if $opt_debug;

my $users_rs = $schema->resultset('User');

my %users;
my @uids;
while ( my $user = $users_rs->next ) {
    my $uid = $user->UID;
    my $username = $user->CRSID || $user->ENGID;
    push (@uids, $uid) if $users{$uid}++;# {
}

my $notuniq_rs = $schema->resultset('User')->search(
    { UID   => \@uids },
    { cache =>  '1' }
);
my %notuniq;
while (my $user = $notuniq_rs->next) {
    my $username = $user->CRSID || $user->ENGID;
    my $uid = $user->UID;
    #$notuniq{$uid} = [];
    my %user = $user->get_columns;
    %{$user{password_changed}} = $user->find_related('user_attributes', {
        ATTRIBUTE_ID => '1',
    })->get_columns;
    $user{status_name} = $user->status->STATUS_NAME;
    push (@{$notuniq{$uid}}, \%user);
}

foreach my $uid ( sort keys %notuniq ) {
    print "The UID: $uid ------------\n";
    foreach my $user ( $notuniq{$uid} ) {
        print Dumper $user;
    }
    foreach my $user ( @{$notuniq{$uid}} ) {

        print "Crsid: $user->{CRSID} Engid $user->{ENGID}:\n";
        my $password_changed = $user->{password_changed}{ATTRIBUTE_EFFECTIVE_DATE};
        print "The password expire(s|d) " . scalar localtime($user->{PASSWORD_EXPIRY_DATE});
        print " and it was changed " . scalar localtime($password_changed) . "\n";
    }
    my $count;
    foreach my $user ( @{$notuniq{$uid}} ) {
        my $username = $user->{CRSID} || $user->{ENGID};
        print "Enter ".  $count++ . " to delete $username\n"
    }
    print "Which one do you want to delete?\n";
    chomp (my $choice = <STDIN>);
    my $user_obj = $schema->resultset('User')->search(
        { USER_ID   => $notuniq{$uid}[$choice]{USER_ID} }
    )->single;
    print Dumper $user_obj->get_columns;
}

#my @dups = grep { $_ > 1 } values %users{count};
#print Dumper \@dups;
#print Dumper \%uids;


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
          "  db_nonuniqueUID.pl            $db_nonuniqueUID_VER\n",
          "  $0\n",
          "\n\n";
    }
}

=head1 NAME

 db_nonuniqueUID.pl

=head1 SYNOPSIS

 db_nonuniqueUID.pl ./tcbfile.csv

=head1 DESCRIPTION

 Import a file into the new Engdatabase
 Default is to import a tcbfile

 Ensure that it is just pure csv (remove all double quotation marks)
 Perl doesn't need no quotation marks

 Switches that don't define a value can be done in long or short form.
 eg:
   db_nonuniqueUID.pl --man
   db_nonuniqueUID.pl -m

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
