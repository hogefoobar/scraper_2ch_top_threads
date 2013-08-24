#!/usr/bin/env perl
# get popular 2ch threads
use strict;
use warnings;
use URI;
use AnyEvent;
use Web::Scraper;
use Encode;


my $cv = AE::cv;

my $uri = URI->new("http://azlucky.s25.xrea.com/2chboard/bbsmenu2.html");
my $scraper = scraper { process 'a', 'list[]' => '@href'; };
my $result = $scraper->scrape($uri);

for my $url ( @{$result->{list}} ) {
	$cv->begin;
	$url = $url . 'subback.html';
	# print $url, "\n";
	&dl($url);
	$cv->end;
}
$cv->recv;

sub dl {
	my $ita = shift;
	my $uri = URI->new($ita);
	my $scraper = scraper {
		process 'a',
				'links[]' => {'title' => 'TEXT', 'link' => '@href' };
		};
	my $result = $scraper->scrape($uri);
	for ( @{$result->{links}} ) {
		if ($_->{title} =~ /^[01]?[0-9]:/) {
			my $link = $_->{link};
			my $text = encode('utf8', $_->{title});
			print qq|<a href="$link">$text</a><br />|;
			print "\n";
		}
	}
}
