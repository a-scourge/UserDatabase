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
use autodie;
use File::Temp qw/ tempfile /;
use File::Copy "cp";

my $db_export_passwd_VER = '0.1';

my $opt_debug = 0;
my ( $gids, $gnames, $uids, $opt_help, $opt_man, $opt_versions );
my $start = 0;
my $end = 100_000;
my $dir = './passwd';

GetOptions(
    'debug=i'   => \$opt_debug,
    'help!'     => \$opt_help,
    'man!'      => \$opt_man,
    'versions!' => \$opt_versions,
    'versions!' => \$opt_versions,
    'gids=s'     => \$gids,
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
  "  db_export_passwd.pl            $db_export_passwd_VER\n", "  $0\n", "\n\n"
  && exit
  if defined $opt_versions;
## end user documentation stuff

my $schema = EngDatabase::Schema->connect('dbi:SQLite:db/testediting.db');
$schema->storage->debug(1) if $opt_debug;
#get the range that we're interested in:
if ($gids) {
    $gids =~/^(\d+)-(\d+)$/;
    ($start, $end) = ($1, $2 );
}


print "start: $start, end: $end\n";

my ($FHworking_copy, $FNworking_copy) = &makefile();

seek $FHworking_copy, 0, 0;
my ($FHsnapshot, $FNsnapshot) = tempfile()
or die "Can't create temporary file!";
cp($FNworking_copy, $FNsnapshot);
seek $FHsnapshot, 0, 0;

my $editor = $ENV{'EDITOR'};
$editor = "vim" if $editor eq qq{};

system("$editor $FNworking_copy");

#Now we're going to lock the db and check no changes were made:
#$schema->dbh_do("LOCK TABLES blah");

my ($FHdb, $FNdb) = &makefile();
seek $FHdb, 0, 0;
seek $FHsnapshot, 0, 0;
while (defined( my $backup = <$FHsnapshot>) and defined (my $db = <$FHdb>)) {
    next if $backup eq $db;
    print "$backup\n doesn't match\n $db\n" and die "Exiting now\n";
}

seek $FHworking_copy, 0, 0;
seek $FHsnapshot, 0, 0;

#my %working_copy;
#while (my $line = <$FHworking_copy>) {
#    chomp $line;
#    my $grp_ref = &parse_grp($line);
#    my $gid = $grp_ref->{GID};
#    if (defined $working_copy{$gid} ) {
#        print "Warning: gid $gid appears twice:\n";
#        print "First:\n" && print Dumper $working_copy{$gid};
#        print "Second:\n" && print  Dumper $grp_ref;
#        print "You should try editing again\n" && die "Exiting now\n";
#    } 
#    else {
#        $working_copy{$gid} = $grp_ref;
#    }
#}
#

while (defined( my $edit = <$FHworking_copy>) and defined (my $copy = <$FHsnapshot>)) {
    next if $edit eq $copy;
    chomp $edit;
    chomp $copy;
    print "Edited:\n$edit";
    print "Backup copy:\n$copy\n";
    my $editgrp_ref = &parse_grp($edit);
    my $snapshotgrp_ref = &parse_grp($copy);
    print $editgrp_ref->{GID} . "\n";
    print $editgrp_ref->{GROUP_NAME} . "\n";
    print $snapshotgrp_ref->{GID} . "\n";
    print $snapshotgrp_ref->{GROUP_NAME} . "\n";
    my $samegroup = 1 if (($editgrp_ref->{GID} eq $snapshotgrp_ref->{GID})
            and ($editgrp_ref->{GROUP_NAME} eq $snapshotgrp_ref->{GROUP_NAME}));
    if ( $samegroup) {
        print "Only the users have changed!\n";
        &updateusers($editgrp_ref);
    }
    print Dumper \$editgrp_ref; 
    print "\n";
}



sub updateusers {
    my $editgrp_ref = $_[0];
    my $gid = $editgrp_ref->{GID};
    my $grp_name = $editgrp_ref->{GROUP_NAME};
    print "The gid is: $gid\n";
    my $users_ref = $editgrp_ref->{users};
    print Dumper \$users_ref;

    my $grp_obj = $schema->resultset('Group')->update_or_create(
        { GID => $gid,
        GROUP_NAME => $grp_name}
    );
    print $grp_obj->GID;
    print "<Group GID\n";
    my @user_objs = $schema->resultset('User')->search(
        { -or=> [
            { CRSID => $users_ref },
            { ENGID     =>  $users_ref }
            ]
            }
    );
    #foreach my $user (@{$users_ref}) {
    #    print "Going to add $user\n";
    #    push @{$grp_ref->{usergroups}}, 
    #    { AFFILIATION_GROUP => '1',
    #        PRIMARY_GROUP   => '0',
    #        myuser => 
    #}
    my $count = @user_objs;
    print "Adding $count users!\n";
    $grp_obj->set_users(\@user_objs, {
            AFFILIATION_GROUP => '1',
            PRIMARY_GROUP       => '0'
        }
    );
    my $wait = <STDIN>;
}
sub makefile {
    my $grps_rs = $schema->resultset('Group')->search(
        undef,
        {
            where => {
                PRIMARY_GROUP => { '!=', 1 },
                AFFILIATION_GROUP => { '!=', 1}
                },
              cache => '1',
              distinct => 1,
                join => 'usergroups'
            }
    );
    #while (my $usergroup = $users_rs->next) {
    #    print "The GID is :";
    #    print $usergroup->mygroup->GID;
    #    print "\n";
    #}
    print "Got the usergroups\n";
    my $wait = <STDIN>;
    #my $grps_rs = $schema->resultset('Group')->search(
    #    {
    #        GID   => {
    #           '>' => $start,
    #            '<' => $end,
    #        }
    #    },
    #        {
    #            'order_by'     => 'GID'
    #        }
    #);
    my ($fh, $filename) = tempfile()
    or die "Can't create temporary file!";
    print "Got the groups!\n";
    my $wait2 = <STDIN>;
    while ( my $group = $grps_rs->next ) {
        my $line = &makeline($group);
        print $fh "$line\n";
    }
    return ($fh, $filename);
}

sub makeline {
    my $group = $_[0];
    my $line;
     $line .= $group->GROUP_NAME . ":*:"; 
    $line .= $group->GID . ":";
    my @users;
    foreach my $user ($group->search_related('usergroups',
            #{   -not =>
            #    [
            #        'PRIMARY_GROUP' => '1',
            #        'AFFILIATION_GROUP' => '1'
            #    ]
            #}
        )->search_related('myuser', {})) {
        #next if $user->STATUS_ID == 3; # ignore expected
        #next if $user->STATUS_ID == 1; # ignore purge-noshow
        #next if $user->STATUS_ID == 2; # ignore purge-wait
        my $crsid = $user->CRSID;
        my $engid = $user->ENGID;
        #if ($user->STATUS_ID =~ m/^(1|2)$/) { #used to check the purge-*
        #    $crsid = "x-" . $crsid if $crsid;
        #    $engid = "x-" . $engid if $engid;
        #}
        push (@users, $crsid) if $crsid;
        push (@users, $engid) if $engid && $engid ne $crsid;
    }
    #print "The group " . $group->GROUP_NAME . " is affiliate?\n";
    #if (my $usergrp = $group->search_related('usergroups')->first) {
    #my $is_aff =  $usergrp->AFFILIATION_GROUP;
    #    if ($is_aff) {
    #        print "Group " . $group->GROUP_NAME . " is aff\n";
    #        my $wait = <STDIN>;
    #    }
    #}
    local $, = ',';
    my @sorted_users = sort { lc($a) cmp lc($b) } @users;
    my $users = join (',', @users);
    $line .=  $users;
    #print $line;
    #my $wait = <STDIN>;
    return $line;
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
          "  db_export_passwd.pl            $db_export_passwd_VER\n",
          "  $0\n",
          "\n\n";
    }
}

=head1 NAME

 db_export_passwd.pl

=head1 SYNOPSIS

 db_export_passwd.pl ./tcbfile.csv

=head1 DESCRIPTION

 Import a file into the new Engdatabase
 Default is to import a tcbfile

 Ensure that it is just pure csv (remove all double quotation marks)
 Perl doesn't need no quotation marks

 Switches that don't define a value can be done in long or short form.
 eg:
   db_export_passwd.pl --man
   db_export_passwd.pl -m

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

