
use strict;
package Mebius::Upload;
use Mebius::Image;

#-----------------------------------------------------------
# �I�u�W�F�N�g�֘A�t��
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

# �Y�t�t�@�C����������
open($FILE,">",$upload_file) || die("Can't upload file.");
binmode($FILE);
while(read($file_body,$buffer, 1024)){ print $FILE $buffer; }
close ($FILE);

chmod(0604,$upload_file);

}


1;
