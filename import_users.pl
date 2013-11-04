#!/usr/bin/perl
#
use warnings;
use strict;
use lib 'lib';
use EngDatabase::Schema;
use EngDatabase::Format qw(print_changes compare_hash add_propagation parse_tcb);
use EngDatabase::AD qw(ad_adduser);
#use DBIx::Class::ResultClass::HashRefInflator;
## begin user documentation stuff
use Getopt::Long;
use Pod::Usage;
my $db_import_VER = '0.1';

our $opt_debug;
our $opt_verbose;
my ( $opt_help, $opt_man, $opt_versions );
my $format = "tcb";
my $makechanges = '';

GetOptions(
    'debug'   => \$opt_debug,
    'verbose'   => \$opt_verbose,
    'help!'     => \$opt_help,
    'man!'      => \$opt_man,
    'versions!' => \$opt_versions,
    'format=s'  => \$format,
    'makechanges'  => \$makechanges,
) or pod2usage( -verbose => 1 ) && exit;

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
  "  db_import.pl            $db_import_VER\n", "  $0\n", "\n\n"
  && exit
  if defined $opt_versions;
## end user documentation stuff

my $schema = EngDatabase::Schema->connect('dbi:SQLite:db/testovernight.db');
print @ARGV . "\n" if $opt_debug;
my @poparray;
$schema->storage->debug(1) if $opt_debug;

my $statuses_rs = $schema->resultset('Status')->search( undef, { cache => 1} );
my $groups_rs = $schema->resultset('Group')->search( undef, { cache => 1} );
#while ( my $status = $statuses_rs->next ) {
#    print $status->STATUS_NAME;
#    my %status_hash = $status->get_columns;
#    foreach my $key ( keys %status_hash ) {
#        print "$key => $status_hash{$key}\n";
#    }
#    print "\n";
#}
#print "Please press enter to start processing the tcb file:\n";
my $users_rs = $schema->resultset('User')->search(undef,
    { 
        cache   => '1',
    }
);

print "Proposed changes:\n" unless $makechanges;
my @populate_array;


while ( my $line = <>) {
    next unless (my $db_href = &parse_tcb( $line )); # parse may return null
    my $password = $db_href->{password};
    delete $db_href->{password};
    my $username = $db_href->{CRSID} || $db_href->{ENGID};
    next if not defined $db_href;
    # This section finds the status and sets capabilities 
    my $status_obj = $statuses_rs->find({
            STATUS_NAME =>  $db_href->{STATUS_NAME}
        });
    delete $db_href->{STATUS_NAME};
    $db_href->{capabilities}  = $status_obj->get_capabilities_columns;
    $db_href = &add_propagation($db_href);

    # Ok now to deal with the primary group:
    # If it already exists, add the user to it:
    my $user_obj = $users_rs->find_or_new($db_href,
        prefetch => [ 'capabilities',
                    'status',
                        { usergroups => 'mygroup',
                  },
            ],
    );
    &ad_adduser($username, $password, $db_href->{GECOS}) if $makechanges;
    if ($user_obj->in_storage) {

        #since we can't use populate, convert the data into objects:
        my $usergroup_objs = $user_obj->get_group_objects(delete $db_href->{usergroups});
        my $userattribute_objs =
        $user_obj->get_attribute_objects(delete $db_href->{userattributes});
        my $capabilities = delete $db_href->{capabilities};
        my $capabilities_obj = $user_obj->find_or_new_related('capabilities',
            $capabilities);
       if ($capabilities_obj->in_storage) {
           $capabilities_obj->set_columns($capabilities);
       }
       $user_obj->set_columns($db_href);
       #$user_obj->status($status_obj);


        my @objects = (@{$usergroup_objs}, @{$userattribute_objs}, $user_obj,
            $capabilities_obj);


        foreach my $object (@objects) {
            if ( my $changeline = &print_changes($object)) {
                print "\nChanges for user $username: $changeline";
            }
        }

        if ($makechanges) {
            my $changes_made = "no";
            foreach my $object (@objects) {
                if ($object->is_changed) {
                    $changes_made = "";
                }
                $object->insert_or_update;
            }
            print "\n$username $changes_made changes made\n" if $opt_verbose;
        }


    }
    else {
        print "$username add record\n";
        $db_href->{STATUS_ID} = $status_obj->STATUS_ID;
        #delete $db_href->{capabilities};
        push (@populate_array, $db_href);
    }

}

print "\nNot making any changes to the database. Please use --makechanges if
you're happy with the above changes\n" unless $makechanges;

#print Dumper(\@populate_array);
#my @newusers = $schema->resultset('User')->populate(\@populate_array);
#calling in void context is much faster.... see documentation:
$schema->resultset('User')->populate(\@populate_array) if $makechanges;

#
#foreach my $user (@newusers) {
#
#    next if $user->capabilities->AD_ENABLED eq '1'
#    && print $user->CRSID . "doesn't\n";
#    my $username = $user->CRSID || $user->ENGID;
#    print "User $username has AD enabled\n";
#}



# What follows is the slow way to do it!
#
#
#
#
#
# 
#    #print "Eng: $userhash_ref->{$engid}, password exp date: $linedata->{password_exp_date}\n";
#
#
#    my $group_obj = $schema->resultset('Group')->update_or_create(
#        {
#            GROUP_NAME => $userhash_ref->{gid},
#            GID        => $userhash_ref->{gid},
#            GROUP_DESC => "test$userhash_ref->{gid}",
#        }
#    );
#
#    print "The groupID is: " if $opt_debug;
#    print $group_obj->GID if $opt_debug;
#    print
#    my $status_obj =
#      $schema->resultset('Status')->search( { STATUS_NAME => $userhash_ref->{status} } )
#      ->single;
#    my $status_name = $status_obj->STATUS_NAME;
#    print "The name of this status is $status_name\n" if $opt_debug;
#    my $n
#    my $newguy = $schema->resultset('User')->update_or_create(
#        {
#            UID                  => $userhash_ref->{uid},
#            ENGID                => $userhash_ref->{engid},
#            CRSID                => $userhash_ref->{crsid},
#            HOMEDIR              => $userhash_ref->{homedir},
#            UID                  => $userhash_ref->{uid},
#            GECOS                => $userhash_ref->{gecos},
#            PASSWORD_EXPIRY_DATE => $userhash_ref->{password_exp_date},
#            PROPAGATION          => $userhash_ref->{propagation},
#            STATUS_EFFECTIVE_DATE => $userhash_ref->{statusdate}
#
##groups  => [ # this works to do one side of rel, but is uneeded thanks to add_to_$rel below
##    { USER_ID => $userhash_ref->{uid} },
##    ],
#        },
#        { key => 'PP_USERS_ENGID_CRSID_UID', }
#    );
#    $newguy->add_to_attributes(
#        { ATTRIBUTE_NAME => "password_changed", },
#        {
#            ATTRIBUTE_VALUE          => "Bulk import",
#            ATTRIBUTE_EFFECTIVE_DATE => $userhash_ref->{password_changed_date},
#            ATTRIBUTE_EXPIRY_DATE    => $userhash_ref->{password_exp_date}
#        }
#    );
#    #$newguy->status($status_obj);
#    my $status = $newguy->update_or_create_related('status', { STATUS_NAME => $userhash_ref->{status} });
#
#    #$newguy->insert;
#    #$newguy->update;
#    $newguy->add_to_group($group_obj);
#
#    #$newguy->add_to_primarygroup($group);
#}

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
          "  db_import.pl            $db_import_VER\n",
          "  $0\n",
          "\n\n";
    }
}

=head1 NAME

 db_import.pl

=head1 SYNOPSIS

 db_import.pl ./tcbfile.csv

=head1 DESCRIPTION

 Import a file into the new Engdatabase
 Default is to import a tcbfile

 Ensure that it is just pure csv (remove all double quotation marks)
 Perl doesn't need no quotation marks

 Switches that don't define a value can be done in long or short form.
 eg:
   db_import.pl --man
   db_import.pl -m

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
