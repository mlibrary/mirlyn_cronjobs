#!/usr/bin/perl

use strict;
use LWP::Simple qw(get);
use File::Temp;

my $mailaddr = "vufind-solr-down\@umich.edu";
my $host = `hostname`;
chomp $host;
my %VUFIND = (
"bibclass" => 8028
	      );

my %CORES = (
  'bibclass' => 'bas',
	     );

while (my ($name, $port) = each %VUFIND) {
    my $core = $CORES{$name};
    my $url = "http://localhost:$port/solr/$core/admin/ping";
    my $problem = solr_problem($url);
    if ($problem) {
	restart_solr($name);
	sleep 20;
	my $newproblem = solr_problem($url);
        my $body;
	if ($newproblem) {
	    $body = "$host: Solr '$name' on port $port was $problem; after restart it is still $newproblem.";
            my $tmp = new File::Temp;
            print $tmp $body;
	    `mail -s "$host Solr '$name' ($port) unavailable"  $mailaddr < $tmp`
	} else {
	    $body = "$host: Solr '$name' on port $port was $problem; after restart it is ok.";
            my $tmp = new File::Temp;
            print $tmp $body;
	    `mail -s  "$host Solr '$name' ($port) restarted" $mailaddr < $tmp`
	}

    }
}

sub solr_problem {
    my $url = shift;
    my $f = get($url);
    unless ($f) {
	return "DOWN";
    }
    unless ($f =~ m|<str name="status">OK</str>|) {
        return "NOT_OK"
    }
    return 0;
}

        

sub restart_solr {
    my $name = shift;

    `/l/solr-vufind/solrs/solr.sh $name restart`;
}
    
