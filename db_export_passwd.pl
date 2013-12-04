#!/usr/bin/perl
#
use warnings;
use strict;
use LinWin::Schema;
## begin user documentation stuff
use Getopt::Long;
use Pod::Usage;
use Data::Dumper;
use autodie;
my $db_export_passwd_VER = '0.1';

my $opt_debug = 0;
my ( $opt_help, $opt_man, $opt_versions );
my $dir = './passwd';

GetOptions(
    'debug=i'   => \$opt_debug,
    'help!'     => \$opt_help,
    'man!'      => \$opt_man,
    'versions!' => \$opt_versions,
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
  "  db_export_passwd.pl            $db_export_passwd_VER\n", "  $0\n", "\n\n"
  && exit
  if defined $opt_versions;
## end user documentation stuff

my $schema = LinWin::Schema->connect('dbi:SQLite:db/test.db');
$schema->storage->debug(1) if $opt_debug;

# This program produces a passwd file for each propagation group. Therefore we
# are going to get an array of the capability names starting with PROP and
# then for each one, produce a file using the other flags in the table
# (UNIX_ENABLED etc).

my @capabilities = $schema->resultset('Capabilities')->result_source->columns;
@capabilities = grep {/^PROP_/} @capabilities;
print Dumper \@capabilities;

foreach my $capability ( sort @capabilities) {
    my $filehandle = uc $capability;
    open PASSWD, '>', "./passwd/passwd_$capability";
    print PASSWD "Password file for propagation $capability\n";
    my $capability_rs = $schema->resultset('Capabilities')->search(
        { $capability => '1' }
    );
    while (my $user_cap = $capability_rs->next) {
        my $user = $user_cap->user;
        my $username = $user->CRSID || $user->ENGID;
        # prepend an x- to the username if it isn't live:
        substr($username, 0, 0, 'x-') if $user_cap->UNIX_PASSWD != '1';
        my $uid = $user->UID;
        my $gecos = $user->GECOS;
        my $home = $user->HOMEDIR;
        # if UNIX_ENABLED, set the shell. Otherwise, /bin/nologin
        my $shell=$user_cap->UNIX_ENABLED == '1' ? '/bin/bash' : '/bin/nologin';
        my $pri_gid = $user->usergroups->search({PRIMARY_GROUP =>
                '1'})->single->mygroup->GID;
        my $line = "$username:*:$uid:$pri_gid:$gecos:$home:$shell";
        print PASSWD "$line\n";
        #my $wait = <STDIN>;
    }
    close PASSWD;
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

## Please see file perltidy.ERR
