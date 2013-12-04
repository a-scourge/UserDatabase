#!/usr/bin/perl
#
use warnings;
use strict;
use lib 'lib';
use LinWin::Schema;
use LinWin::Format qw(print_changes compare_hash add_propagation parse_tcb);
use LinWin::AdUser qw(ad_update_or_create_user);
#use DBIx::Class::ResultClass::HashRefInflator;
## begin user documentation stuff
use Data::Dumper;
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

my $schema = LinWin::Schema->connect('dbi:SQLite:db/testgroups.db', {
        quote_names => 1 });
print @ARGV . "\n" if $opt_debug;
my @poparray;
$schema->storage->debug(1) if $opt_debug;
#while ( my $status = $statuses_rs->next ) {
#    print $status->STATUS_NAME;
#    my %status_hash = $status->get_columns;
#    foreach my $key ( keys %status_hash ) {
#        print "$key => $status_hash{$key}\n";
#    }
#    print "\n";
#}
#print "Please press enter to start processing the tcb file:\n";
my $prefetch_aref = [
            'capabilities',
            #'status',
            {'userattributes' => 'attribute'},
            {'usergroups' => 'mygroup'},
        ];

my $users_rs = $schema->resultset('User')->search(undef,
    { 
        prefetch => $prefetch_aref,
        #cache   => '1',
    }
);

print "Proposed changes:\n" unless $makechanges;
my @populate_array;

my $guard = $schema->txn_scope_guard;


#statuses is used by parse_tcb to fill in capabilities
our $statuses_rs = $schema->resultset('Status')->search( undef, { cache => 1} );
my $groups_rs = $schema->resultset('Group')->search( undef, { cache => 1} );
my $attributes_rs = $schema->resultset('Attribute')->search( undef, { cache => 1} );


while ( my $line = <>) {
    next unless (my ($input_href, $password) = &parse_tcb( $line )); # parse may return null
    my $username = $input_href->{CRSID} || $input_href->{ENGID};
    #print Dumper $input_href;
    #my $wait = <STDIN>;


    #if ($input_href->{capabilities}{AD_ENABLED} == 1 && $makechanges) {
    #    ad_update_or_create_user($username, $password, $input_href->{GECOS});
    #}
    if (my $db_user = $users_rs->find(
            $input_href,
                #{ CRSID => $input_href->{CRSID}, ENGID => $input_href->{ENGID} },
            {
                #where => {
                #    -or => [
                #        CRSID => $input_href->{CRSID},
                #        ENGID => $input_href->{ENGID},
                #    ],
                #},
                #result_class => 'DBIx::Class::ResultClass::HashRefInflator',
                key => 'both',
                #prefetch => $prefetch_aref,
            },
        )) {
        print "Changes for $username: ";

        $input_href->{status} = $statuses_rs->find_or_new({
                STATUS_NAME =>  delete $input_href->{status}{STATUS_NAME}
        });

        foreach my $usergroup_href ( @{delete $input_href->{usergroups}}) {
            $usergroup_href->{mygroup} = $groups_rs->update_or_create(
                delete $usergroup_href->{mygroup},
                { key => 'GID'},
            );
            my $usergroup_obj = $db_user->update_or_create_related('usergroups',
                $usergroup_href,
                {key => 'both' }
            );
        }

        foreach my $userattribute_href ( @{delete $input_href->{userattributes}}) {
            $userattribute_href->{attribute} = $attributes_rs->find_or_create(
                delete $userattribute_href->{attribute},
                { key => 'name'},
            );
            my $usergroup_obj =
            $db_user->find_or_create_related('userattributes',
                $userattribute_href,
                {key => 'both' }
            );
        }
        #$db_user->capabilities->update( delete $input_href->{capabilities} );
        $db_user->update_or_create_related('capabilities', delete
            $input_href->{capabilities});
        #print Dumper $input_href;
        #my $wait = <STDIN>;
        $db_user->update($input_href);
        print "\n";

    }
    else {
        print "$username add record\n";
        #$input_href->{STATUS_ID} = $input_href->{status}->STATUS_ID;
        #print Dumper $input_href;
        #delete $input_href->{capabilities};
        push (@populate_array, $input_href);
    }

}

if ($makechanges) {
    $guard->commit if $makechanges;
    $schema->resultset('User')->populate(\@populate_array) if $makechanges;
}
else {
    print "\nNot making any changes to the database. Please use --makechanges if you're happy with the above changes\n" unless $makechanges; 
}

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
