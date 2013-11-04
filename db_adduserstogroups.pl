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
my $do_users  = 0;
my ( $opt_help, $opt_man, $opt_versions );
my $format = "grp";

GetOptions(
    'debug=i'    => \$opt_debug,
    'help!'      => \$opt_help,
    'man!'       => \$opt_man,
    'versions!'  => \$opt_versions,
    'format=s'   => \$format,
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

## The groups file has normal entries
my %groups;    # use a hash because the groups file can have "dups"
while (<>) {
    chomp( my $line = $_ );
    #my $is_aff =  ( $line =~ /\+$/ ) ? 1 : 0;    # affiliate group if line ends with +
    my $RHgroup = parse_grp($line);
    my @users   = @{ $RHgroup->{users} };
    my $gid     = $RHgroup->{GID};
    #$groups{$gid}{is_aff} = $is_aff;    #, users => @users };
         #$groups{$gid}{users} = []; # unless $groups{$gid}{users};
    foreach my $user (@users) {
        next if $user =~ /\+/;
        push( @{ $groups{$gid}{users} }, $user );
    }
}

my @gids = keys %groups;
my @usernames;
foreach my $gid (@gids) {
    foreach my $username ( @{ $groups{$gid}{users} } ) {
        push @usernames, $username;
    }
}
my $count = @usernames;
print "The number of users in the file is: $count \n";
my $groupcount = @gids;
print "The number of groups in the file is : $groupcount\n";

my $groups_rs = $schema->resultset('Group')->search( { GID => \@gids }, { cache => 1 } );
my $db_group_count = $groups_rs->count;
print "The number of groups found is $db_group_count\n";
my $users_rs = $schema->resultset('User');
my $db_user_count = $users_rs->count;
print "The number of users in the database is $db_user_count \n";



foreach my $gid ( sort {$a <=> $b} keys %groups ) {
    print "Processing $gid\n" if $opt_debug;
    my $is_aff = 0;
    my $is_prim =  0;
    my $group_obj = $groups_rs->search( { GID => $gid } )->single;
    print "Found a group!" . $group_obj->GROUP_NAME . "\n" if $opt_debug;
    foreach my $username ( @{ $groups{$gid}{users} } ) {
        print "Username $username\n" if $opt_debug;
        if (
            $group_obj->search_related('usergroups')->search_related(
                'myuser',
                { -or=>[
                    { 'CRSID' => $username }, { 'ENGID' => $username }
               ]}
            )->count()>0
          )
        {
            print "Username $username is already a member of ";
            print $group_obj->GROUP_NAME;
            print "\n";
            next;
        }
        elsif (
            my $user_obj = $users_rs->search(
                [ { CRSID => $username }, { ENGID => $username }, ],
                { cache => 1 } )->single
          )
        {
            print "Found a user for "  . $user_obj->CRSID. "!\n" if $opt_debug;
            $group_obj->add_to_users(
                $user_obj,
                {
                    AFFILIATION_GROUP => $is_aff,
                    PRIMARY_GROUP     => $is_prim
                }
            );
            print "Added user: $username\n to " . $group_obj->GROUP_NAME . "\n";
        }
        else {
            print "Username $username not found!\n";
        }
    }
    my $wait = <STDIN> if $opt_debug;

}

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

 Import a file into the new Engdatabase
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
