#!/usr/bin/perl
#
use warnings;
use Net::LDAP;
use Net::LDAP::Bind;
use Net::LDAP::Extra qw(AD);

my $ad = Net::LDAP->new( 'ldaps://kdc.eng.cam.ac.uk',
    ) or die "$@";

my $result = $ad->bind( 'AD\gmj33',
    password    =>  'stihl123'
);


$schema = $ad->schema ( );

#
# Get the attributes
#

@attributes = $schema->all_attributes ( );

#
# Display the attributes
#

foreach $ar ( @attributes ) {
  print "attributeType: ", $ar->{name}, "\n";

  #
  # Print all the details
  #

  foreach $key ( keys %{$ar} ) {
    print join ( "\n\t\t", "\t$key:",
                 ref ( $ar->{$key} ) ? @{$ar->{$key}} : $ar->{$key}
               ), "\n";
  }
}

END{
  if(defined $opt_versions){
    print
      "\nModules, Perl, OS, Program info:\n",
      "  DBIx::Class          $DBIx::Class::VERSION\n",
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

 ad_addusers.pl ./userlist.txt

=head1 DESCRIPTION

 Import a tcb file into the new Engdatabase

 Ensure that it is just pure csv (remove all double quotation marks)
 Perl doesn't need no quotation marks

 Switches that don't define a value can be done in long or short form.
 eg:
   ad_addusers.pl --man
   ad_addusers.pl -m

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
