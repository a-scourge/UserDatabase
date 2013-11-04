#!/usr/bin/perl
#
use warnings;
use strict;
use EngDatabase::Format qw(parse);
## begin user documentation stuff
use Getopt::Long;
use Pod::Usage;
my $db_importgroups_VER = '0.1';

my $opt_debug = 0;
my ( $opt_help, $opt_man, $opt_versions );
my $format = "grp";

GetOptions(
    'debug=i'   => \$opt_debug,
    'help!'     => \$opt_help,
    'man!'      => \$opt_man,
    'versions!' => \$opt_versions,
    'format=s'  => \$format,
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

print @ARGV . "\n" if $opt_debug;

while (<>) {
    chomp( my $line = $_ );
    print "The input line is: $line\n" if $opt_debug;
    print "Format: $format\n"          if $opt_debug;
    my ($linedata) = parse( $format, $line );

    if ($format eq "tcb") {
        print "ENGID: >$linedata->{engid}< CRSID: >$linedata->{crsid}<";
        print "Status: >$linedata->{status}< StatusDate: >$linedata->{statusdate}<\n";
        my $test = <STDIN>;
    }
}

