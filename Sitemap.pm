
use strict;
use Mebius::Time;
package Mebius::Sitemap;
use Mebius::Export;

#-----------------------------------------------------------
# オブジェクト関連付け
#-----------------------------------------------------------
sub new {
my $self = shift;
bless {} , $self;
}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub print_sitemap_index{

my $self = shift;
my $array = shift;
my $use = shift || {};
my $times = new Mebius::Time;
my($line,$body);

	foreach my $hash (@$array){

			if(!$hash->{'url'}){ next; }

		$line .= qq(<sitemap>);
		$line .= qq(<loc>);
		$line .= e($hash->{'url'});
		$line .= qq(</loc>);
		$line .= qq(</sitemap>);
		$line .= "\n";

	}

my($gzip_type) = Mebius::Device::accept_gzip_type();
	if($gzip_type){
		print "Content-Encoding: $gzip_type\n";
	}

print "Vary: Accept-Encoding\n";
print "Content-type:text/xml; charset=utf-8\n";
print "\n";

$body .= qq(<?xml version="1.0" encoding="UTF-8"?>);
$body .= qq(<sitemapindex xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n);
$body .= $line;
$body .= qq(</sitemapindex>\n);

my $gzip = Compress::Zlib::memGzip( $body );

print $gzip;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub print_sitemap{

my $self = shift;
$self->array_to_print(@_);

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub array_to_print{

my $self = shift;
my $array = shift;
my $use = shift || {};
my $times = new Mebius::Time;
my($line,$body);

	foreach my $hash (@$array){

			if($hash->{'url'}){ 

				$line .= qq(<url>);

				$line .= qq(<loc>);
				$line .= e($hash->{'url'});
				$line .= qq(</loc>);

					if($hash->{'lastmod'}){
						$line .= qq(<lastmod>);
						$line .= $times->localtime_to_gmt_date($hash->{'lastmod'});
						$line .= qq(</lastmod>);
					}

				$line .= qq(</url>);
			}

		$line .= "\n";

	}


my($gzip_type) = Mebius::Device::accept_gzip_type();
	if($gzip_type){
		print "Content-Encoding: $gzip_type\n";
	}

print "Vary: Accept-Encoding\n";
print "Content-type:text/xml; charset=utf-8\n";
print "\n";

$body .= qq(<?xml version="1.0" encoding="UTF-8"?>);
$body .= qq(<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n);
$body .= $line;
$body .= qq(</urlset>\n);

my $gzip = Compress::Zlib::memGzip( $body );

print $gzip;

}


1;
