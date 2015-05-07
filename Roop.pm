
# 宣言
use strict;
package Mebius::Roop;

#-----------------------------------------------------------
# ループがある場合は die
#-----------------------------------------------------------
sub block{

# 宣言
my($PackageName,$RoopName,$RoopKey) = @_;
our(%roop);

	# 必須項目をチェック
	if(!defined $PackageName){ die("Perl Die! Package key is empty."); }
	if(!defined $RoopName){ die("Perl Die! Name key is empty."); }
	if(!defined $RoopKey){ die("Perl Die! Key key is empty."); }

	if($roop{$PackageName}{$RoopName}{$RoopKey}){ return("Perl Die ! Block roop."); }
	else{ return(); }

}

#-----------------------------------------------------------
# フラグを消す
#-----------------------------------------------------------
sub relese{

# 宣言
my($PackageName,$RoopName,$RoopKey) = @_;
our(%roop);

	# 必須項目をチェック
	if(!defined $PackageName){ die("Perl Die! Package key is empty"); }
	if(!defined $RoopName){ die("Perl Die! Name key is empty"); }
	if(!defined $RoopKey){ die("Perl Die! Key key is empty."); }

$roop{$PackageName}{$RoopName}{$RoopKey} = undef;

}

#-----------------------------------------------------------
# フラグを立てる
#-----------------------------------------------------------
sub set{

# 宣言
my($PackageName,$RoopName,$RoopKey) = @_;
our(%roop);

	# 必須項目をチェック
	if(!defined $PackageName){ die("Perl Die! Package key is empty"); }
	if(!defined $RoopName){ die("Perl Die! Name key is empty"); }
	if(!defined $RoopKey){ die("Perl Die! Key key is empty."); }

$roop{$PackageName}{$RoopName}{$RoopKey} = 1;

}

#-----------------------------------------------------------
# 変数をリセット
#-----------------------------------------------------------
sub all_reset{
undef(our %roop);
}


1;
