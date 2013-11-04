#!/usr/bin/perl -w

use strict;

my $masterdir = '/var/opt/passwd.cued/master';

my $debug = 0;

my %engid2data;
my @fieldnames = qw /
u_name
ul_alias
u_id
ul_gid
ul_gecos
ul_physdir
ul_pwd
ul_dir
ul_shell
u_lock
u_pwd
u_succhg
u_unsucchg
u_pwchanger
u_auditid
u_auditflag
ul_pw_expire_warned
u_suclog
u_suctty
u_unsuclog
u_unsuctty
u_numunsuclog
ul_pin
ul_pinchg
ul_propagate
ul_authorised
ul_netpw
ul_netpwchg
/;
my %fnames;
foreach (@fieldnames) {
	$fnames{$_}=1;
}

opendir (MDIR, $masterdir) or die "Unable to readdir $masterdir: !$\n";
my @dirs = readdir (MDIR);
close (MDIR);

my %tcbrows;
foreach my $dir (@dirs) {
	next if $dir =~ /^\.{1,2}$/; 	# skip . and ..
	next unless $dir =~ /^.$/;
#	print "$masterdir/$dir\n";
	opendir (DIR, "$masterdir/$dir") or die
		"Unable to readdir $masterdir/$dir: $!\n";
	my @tcbs = readdir (DIR);
	close (DIR);
	foreach my $tcb (@tcbs) {
		next unless -f "$masterdir/$dir/$tcb";
#		print "$masterdir/$dir/$tcb\n";
		parsetcb ("$masterdir/$dir/$tcb");
	}
}

## check u_pwd fields
#my %pwds;
#foreach my $engid (keys %engid2data) {
#	$pwds{$engid2data{$engid}{'u_pwd'}}++;
#}
#foreach my $pwd (keys %pwds) {
#	next if $pwds{$pwd} < 2;
#	print "$pwd: $pwds{$pwd}\n";
#}
#exit 0;

print '"Engid","CRSid","', join '","',@fieldnames;
print '"', "\n";
foreach my $engid (sort keys %engid2data) {
	my @ofields = ($engid);
	foreach my $field ('crsid', @fieldnames) {
		my $value = $engid2data{$engid}{$field} || '';
#		$value = 'not shown' if $field eq 'ul_pwd';
		if ($field eq 'u_pwd') {
			$value = 'live' unless (	
				($value =~ /^expected/) ||
				($value =~ /^group-web/) ||
				($value =~ /^not-set/) ||
				($value =~ /^placeholder/) ||
				($value =~ /^purge/) ||
				($value =~ /^returning/) ||
				($value =~ /^rhosts/) ||
				($value =~ /^setuid/) ||
				($value =~ /^suspended/));
		}
		push @ofields, $value;
	}
	print '"';
	print join '","', @ofields;
	print '"', "\n";
}

exit 0;

# 
# Subroutines
#

sub parsetcb {
	my ($tcbfile) = @_;
	open (TCB, $tcbfile) or die "Unable to read $tcbfile: $!\n";
	my $tcbline = '';
	my $comments = '';
	my $chkent = 0;
	my $engid;
	my $crsid = '';
	my $fields;
	while (<TCB>) {
		next if /^\s*$/;	# skip blank lines
		chomp;
		$tcbline .= $_ unless $chkent;
		$comments .= "$_\n" if $chkent;
		$chkent = 1 if /chkent/;
	}
#	print "$tcbline\n";
#	print "Comments:\n$comments";
	my $rawt = $tcbline;
	$tcbline =~ s/:\\\s+:/:/g;
#	print "$tcbline\n";
	if ($tcbline =~ /^([\S^\,]+?):(.*)/) {
		$engid = $1;
		$fields = $2;
	}
	if ($tcbline =~ /^(\S+),(\S+?):(.*)/) {
		$engid = $1;
		$crsid = $2;
		$fields = $3;
	}
	print "E $engid " if $debug;
	print "C $crsid " if $crsid && $debug;
	$engid2data{$engid}{'crsid'} = $crsid;
	my @fields = split (/:/, $fields);
	foreach my $field (@fields) {
		if ($field =~ /^(.*)#(\d+)$/) {
			print "Numeric $1 $2\n" if $debug;
			unless ($fnames{$1}) {
				warn "Unknown field name $1 for $engid\n";
				next;
			}
			$engid2data{$engid}{$1}=$2;
			next;
		}
		if ($field =~ /^(.*)=(.*)$/) {
			print "Text $1 $2\n" if $debug;
			unless ($fnames{$1}) {
				warn "Unknown field name $1 for $engid\n";
				next;
			}
			$engid2data{$engid}{$1}=$2;
			next;
		}
		if ($field =~ /u_lock(.*)/) {
			print "Locked :$1:\n" if $debug;
			$engid2data{$engid}{'u_lock'}=$1;
			next;
		}
		next if $field =~ /chkent/;
		die "Didn't parse :$field: for $engid\n$fields\n$tcbline\n$rawt\n$comments\n$tcbfile\n";
	}
}
