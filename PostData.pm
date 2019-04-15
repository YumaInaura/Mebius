
use strict;
package Mebius;

#-----------------------------------------------------------
# ポストバッファを扱う
#-----------------------------------------------------------
sub PostBuf{

# 宣言
my($type,$postbuf) = @_;
my(undef,undef,@delete_key) = @_ if($type =~ /Delete-key/);
my($postbuf_split,%postbuf);

	# バッファを展開
	foreach $postbuf_split (split(/&/,$postbuf)){

		# 局所化
		my($delete_key,$delete_key_flag);

		# 分割
		my($key2,$value2) = split(/=/,$postbuf_split);

			# 除外する値
			if($type =~ /Delete-key/){
					foreach $delete_key (@delete_key){
						if($key2 eq $delete_key){ $delete_key_flag = 1; }
					}
					if($delete_key_flag){ next; }
			}

			# バッファを再追加
			if($postbuf{'body'}){ $postbuf{'body'} .= qq(&$key2=$value2); }
			else{ $postbuf{'body'} = qq($key2=$value2); }

	}

return(%postbuf);

}

1;
