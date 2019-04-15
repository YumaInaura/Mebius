
use strict;
package Mebius;

#-----------------------------------------------------------
# タグを HTMLに
#-----------------------------------------------------------
sub users_tag_to_html{

my(@value) = @_;
my(@self);

	foreach my $value (@value){
		$value =~ s/\[br\]/<br>/g;
		push(@self,$value);
	}

@self;


}

#-----------------------------------------------------------
# textareaからの入力など、改行ありのデータを整形
#-----------------------------------------------------------
sub format_query_with_paragraph{

my(@value) = @_;
my(@self);

	foreach my $value (@value){
		($value) = delete_users_tag($value);
		$value =~ s/[\r\n]/[br]/g;
		push(@self,$value);
	}

@self;

}

#-----------------------------------------------------------
# タグの任意の入力を削除
#-----------------------------------------------------------
sub delete_users_tag{

my(@value) = @_;
my(@self);

	foreach my $value (@value){
		$value =~ s/\[([a-zA-Z0-9_=:;,!?\.\-\s\*\@]+?)\]//g;
		push(@self,$value);
	}

@self;

}

1;
