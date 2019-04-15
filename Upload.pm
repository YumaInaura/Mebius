
use strict;
package Mebius::Upload;
use Mebius::Image;

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
sub upload{

my $self = shift;
my $upload_file = shift || return();
my $file_body = shift || return();
my($buffer,$FILE);

	if(-f $upload_file){
		return();
	}

# 添付ファイル書き込み
open($FILE,">",$upload_file) || die("Can't upload file.");
binmode($FILE);
while(read($file_body,$buffer, 1024)){ print $FILE $buffer; }
close ($FILE);

chmod(0604,$upload_file);

}


1;
