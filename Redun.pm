
package Mebius;
use strict;

#-----------------------------------------------------------
# �A�����M�`�F�b�N
#-----------------------------------------------------------
sub Redun{

# �Ǐ���
my($type,$file,$block_second,$maxline,$routin) = @_;
my($error_subroutin);
my($block_flag,$i,$next_time,$next_second,@line,$redun_handle);

# �G���[�T�u���[�`�����`
if($routin){ $error_subroutin = $routin; } else { $error_subroutin = "main::error"; }

# �t�@�C����`
$file =~ s/[^0-9a-zA-Z\-_]//g;
if($file eq ""){ return; }

# �ۑ�����s�����`
if(!$maxline){ $maxline = 50; }

# �A�����M���֎~����b
#if($main::alocal_mode){ $block_second = 5; }

# �҂����Ԃ��w�肳��Ă��Ȃ��ꍇ�́A�����}��
if(!$block_second){ $block_second = 5*60; }
if($main::alocal_mode){ $block_second = 5; }

my $directory = "${main::int_dir}_backup/_redun/";

# �t�@�C�����J��
open($redun_handle,"${directory}${file}_redun.log");
	while(<$redun_handle>){
		chomp;
		my($lasttime,$date2,$addr2,$age2,$number2,$account2) = split(/<>/);
		my($flag);
			if($main::time < $lasttime + $block_second){
				if($addr2 && $addr2 eq $main::addr){ $flag = 1; }
				if($age2 && $age2 eq $main::agent && ($main::kaccess_one || $main::k_access)){ $flag = 2; }
				if($number2 && $number2 eq $main::cnumber){ $flag = 3; }
				if($account2 && $account2 eq $main::pmfile){ $flag = 4; }
				if($flag){
					$next_second = $lasttime + $block_second - $main::time;
					$block_flag = qq(�A�����M�͏o���܂���B���� $next_second�b �قǌ�ő��M���Ă��������B[ $flag ]);
				}
			}
		$i++;
		if($i < $maxline){ push(@line,"$_\n"); }
	}
close($redun_handle);

	# �c��b�����v�Z
	if($next_second){
		if($next_second >= 1*60){ $next_time = int($next_second/60)+1 . qq(��); }
		else{ $next_time = $next_second . qq(�b); }
	}

	# �f�[�^�擾�݂̂ŋA��ꍇ
	if($type =~ /Get-only|Read-only/){ return($block_flag); }

	# �G���[��\������
	if($block_flag && $type !~ /Renew-only/){
		eval "&$error_subroutin($block_flag)";
	}

# �ǉ�����s
unshift(@line,"$main::time<>$main::date<>$main::addr<>$main::agent<>$main::cnumber<>$main::pmfile<>\n");

# �t�@�C�����X�V
Mebius::Mkdir(undef,$directory);
Mebius::Fileout("","${main::int_dir}_backup/_redun/${file}_redun.log",@line);

# ���^�[��
return($block_flag);

}

1;
