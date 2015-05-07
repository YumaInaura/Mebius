
use strict;
package Mebius::Gzip;
use Archive::Zip;

#-----------------------------------------------------------
# ひとつのファイルのコピーを作成し、そのディレクトリ内のファイルを gzip 圧縮する
#-----------------------------------------------------------
sub gzip_files_in_directory{

my($from_dir,$to_dir) = @_;

	if(!-d $from_dir){ "$from_dir is not directory"; }
	if(!-d $to_dir){ "$from_dir is not directory"; }

my $time = time;
`mv -f $to_dir /trash/trashed_css_directory_$time`;

`cp -raf $from_dir $to_dir`;

`gzip -rf $to_dir`;

print "ziped.\n";

}




1;
