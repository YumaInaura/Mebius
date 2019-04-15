
use strict;
use Mebius::Basic;
package Mebius;

#-----------------------------------------------------------
#-----------------------------------------------------------
sub join_files_histories{


}

#-----------------------------------------------------------
# ファイル同士を結合
#-----------------------------------------------------------
sub join_files{

my $use = shift if(ref $_[0] eq "HASH");
my(@files) = @_;
my(@renew_line,$out_file);

	foreach(@files){
		my($FILE);
		open($FILE,"<",$_);
		flock($FILE,1);
			my $top = <$FILE>;
			while(<$FILE>){
				push(@renew_line,$_);
			}
		close($FILE);
	}

	# 配列をソート
	if($use->{'sort_number'} =~ /^\d+$/){
		@renew_line = sort { (split(/<>/,$b))[$use->{'sort_number'}] <=> (split(/<>/,$use->{'sort_number'}))[0] } @renew_line;
	}

	# ● 書き込み
	{
		Mebius::Fileout(undef,$out_file,@renew_line);
	}

}

1;
