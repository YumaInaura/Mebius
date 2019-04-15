
package Mebius::TagOperate;
use strict;

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
sub text_to_tags{

my $self = shift;
my $text = shift;
my(@tag,%kind);

	while($text =~ s/(?:＃|#)([^\s#]+)//){
		my $tag = $1;
			if($kind{$tag}++){
				next;
			}
		push @tag , $tag;
	}

@tag;

}


#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub text_to_tags_with_marks{

my $self = shift;
my $text = shift;

my @tag = $self->text_to_tags($text);

@tag = map { $_ = "#$_"; } @tag;

my $print = join " " , @tag;

$print;

}



1;
