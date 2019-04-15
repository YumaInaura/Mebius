
package Mebius::Adventure;
use strict;

#-----------------------------------------------------------
# �����L���O�y�[�W��\��
#-----------------------------------------------------------
sub ViewRanking{

# �錾
my($init) = &Init();
my($init_login) = init_login();
my($maxview,$print);
our($advmy);

	# �\����
	if($main::in{'viewall'}){ $maxview = 1000; }
	else{ $maxview = 100; }

# �����L���O�擾
my($menber_list);
my($line,undef,$flow_flag) = &RankingFile({ TypeGetIndex => 1 , MaxViewIndex => $maxview , SelectJobName => $main::in{'jobname'} , Sort => $main::in{'sort'} },{},$advmy);

# CSS��`
$main::css_text .= qq(
div.sort{margin:1em 0em;word-spacing:0.5em;background:#ddf;padding:0.5em 1em;}
div.jobname_sort{margin:1em 0em;word-spacing:0.5em;background:#ff9;padding:0.5em 1em;}
);

# ���ёւ��̎��
my @sort_mode = (
"=>���x����������",
"level_low=>���x�����Ⴂ��",
"maxhp=>�ő�HP��",
"gold=>��������",
"login=>���O�C�����ԏ�",
"name=>���O��"
);

$print .= <<"EOM";
<h1>�����o�[���X�g</h1>
$init_login->{'link_line'}
$init->{'ads1_formated'}
EOM

$print .= qq(
<h2>�ꗗ</h2>
$init->{'reset_limit'} ���ȏ�s�����Ă��Ȃ��L�����N�^�͔�\\���ɂȂ�܂��B�i�L�����f�[�^�͎c��̂ŁA���̌�����O�C���͉\\�ł��j�B<br>
$init->{'charaon_day'} ���ȏ�s�����Ă��Ȃ��L�����N�^�[�̓O���[�ŕ\\������܂��B);

# �e����בւ������N
$print .= qq(<div class="sort">���בւ��F\n);
	foreach(@sort_mode){
		my($sort_type,$sort_title) = split(/=>/,$_);
			if($main::in{'sort'} eq $sort_type){ $print .= qq($sort_title); }
			elsif($sort_type eq ""){ $print .= qq(<a href="$init->{'script'}?mode=ranking">$sort_title</a>); }
			else{ $print .= qq(<a href="$init->{'script'}?mode=ranking&amp;sort=$sort_type">$sort_title</a>); }
		$print .= qq(\n);
	}
$print .= qq(</div>);

	# �E�Ƃł̕��ёւ������N
$print .= qq(<div class="jobname_sort">�E�ƁF\n);
	require Mebius::Adventure::Job;
	my(@jobnames) = &SelectJob("Get-jobname");
	if($main::in{'jobname'} eq ""){ $print .= qq(�S�E��\n); }
	else{ $print .= qq(<a href="$init->{'script'}?mode=ranking">�S�E��</a>\n); }
	foreach(@jobnames){
		my($jobname_encoded) = Mebius::Encode(undef,$_);
		if($main::in{'jobname'} eq $_){ $print .= qq($_\n); }
		else{ $print .= qq(<a href="$init->{'script'}?mode=ranking&amp;jobname=$jobname_encoded">$_</a>\n); }
	}
$print .= qq(</div>);

# �����L���O�{�̕���
$print .= qq($line);

	# ���Ă���ꍇ
	if($flow_flag || Mebius::alocal_judge()){
		$print .= qq(<br><a href="$init->{'script'}?$main::postbuf&amp;viewall=1">�������L���O�̑�����\\��</a><br><br>);
	}


$print .= "$init->{'ads1_formated'}\n";

$print .= qq(</div>);

Mebius::Template::gzip_and_print_all({ BodyPrint => 1 , BCL => ["�����L���O"] },$print);

exit;

}





#-----------------------------------------------------------
# �����L���O�������擾
#-----------------------------------------------------------
sub RankingFile{

# �錾
my($use,$select_renew,$adv) = @_;
my($init) = &Init();
my($line,$i,@RANKING,$flow_flag,$file_handle1,$max_view,%data,@renew_line);

# CSS��`
$main::css_text .= qq(
div.comment{width:20em;word-break:break-all;}
);

	# �����^�C�v���`
	if($use->{'TypeGetIndex'}){
			if($use->{'MaxViewIndex'}){ $max_view = $use->{'MaxViewIndex'}; }
			else{ $max_view = 100; }
	}
	elsif($use->{'TypeRenew'}){
	}
	elsif($use->{'TypeGetSelectOption'}){
	}
	# �����^�C�v���w�肳��Ă��Ȃ��ꍇ
	else{ die('Type is not decided'); }

	# �t�@�C����` (���[�J��)
	if(Mebius::alocal_judge()){
			if($use->{'FileType'} eq "Old"){
				$data{'file'} = "$init->{'adv_dir'}_log_adv/chara_alocal.log";
			}
			else{
				$data{'file'} = "$init->{'adv_dir'}_log_adv/character_alocal.log";
			}
	}
	# �t�@�C����` (�T�[�o�[)
	else{
			if($use->{'FileType'} eq "Old"){
				$data{'file'} = "$init->{'adv_dir'}_log_adv/chara.log";
			}
			else{
				$data{'file'} = "$init->{'adv_dir'}_log_adv/character.log";
			}
	}

	# �t�@�C�����J��
	if($use->{'FileCheckError'}){
		$data{'f'} = open($file_handle1,"+<$data{'file'}") || main::error("�t�@�C�������݂��܂���B");
	}
	else{
		$data{'f'} = open($file_handle1,"+<$data{'file'}");

			# �t�@�C�������݂��Ȃ��ꍇ�͐V�K�쐬
			if(!$data{'f'}){
					if($use->{'TypeRenew'}){
						Mebius::Fileout("Allow-empty",$data{'file'});
						$data{'f'} = open($file_handle1,"+<$data{'file'}");
					}
					else{
						return(%data);
					}
			}

	}

	# �t�@�C�����b�N
	if($use->{'TypeRenew'} || $use->{'TypeRenew'}){ flock($file_handle1,2); }

# �g�b�v�f�[�^�𕪉�
chomp($data{'top1'} = <$file_handle1>);
($data{'key'}) = split(/<>/,$data{'top1'});

	# �t�@�C����W�J
	while(<$file_handle1>){

			# ���̍s�𕪉�
			chomp;
			my($key,$id2,$name,$level,$jobname,$hp,$maxhp,$gold,$comment,$lasttime,$host2,$number,$account,$itemname) = split(/<>/);

				# �z��ɒǉ�
				if($use->{'TypeGetIndex'}){ push(@RANKING,$_); }

				# �Z���N�g���擾
				if($use->{'TypeGetSelectOption'}){
					my($selected2,$class1,$viewhp,$viewgold);
						if($use->{'TargetJobName'}){
								if(index($use->{'TargetJobName'},$jobname) < 0){ next; }
						}
						if($use->{'TypeViewHP'}){
							my($hp_comma,$maxhp_comma) = Mebius::MultiComma({ Language => $init->{'comma_language'} } , [$hp,$maxhp]);
							$viewhp = qq( HP $hp_comma / $maxhp_comma );
						}
						if($use->{'TypeViewGold'}){
							my($gold_comma) = Mebius::MultiComma({ Language => $init->{'comma_language'} } , [$gold]);
							$viewgold = qq( ������ $gold_comma\G );
						}
						if($lasttime+$init->{'charaon_day'}*24*60*60 < time){ next; }
						if($use->{'TypeJudgeLevel'} && $adv->{'maxhp'} > $maxhp*$init->{'special_battle_gyap'}){
							$class1 = qq( class="disable");
							next;
						}
						if($id2 eq $adv->{'last_select_special_id'}){ $selected2 = $main::selected; }
					$data{'select_option_line'} .= qq(<option value="$id2"$class1$selected2>$name ( Lv.$level $jobname )$viewhp$viewgold</option>\n);
				}

				# �X�V�p
				if($use->{'TypeRenew'}){

						# ��莞�Ԉȏネ�O�C�����Ă��Ȃ��L�����s�͍폜
						if($lasttime && time > $lasttime + $init->{'reset_limit'}*24*60*60){ next; }
						
						# �����̏ꍇ
						if($id2 eq $adv->{'id'}){ next; }

					# �s��ǉ�
					push(@renew_line,"$key<>$id2<>$name<>$level<>$jobname<>$hp<>$maxhp<>$gold<>$comment<>$lasttime<>$host2<>$number<>$account<>$itemname<>\n");

				}
	}


	# �V�����s
	if($use->{'TypeNewStatus'}){
	unshift(@renew_line,"1<>$adv->{'id'}<>$adv->{'name'}<>$adv->{'level'}<>$adv->{'jobname'}<>$adv->{'hp'}<>$adv->{'maxhp'}<>$adv->{'gold'}<>$adv->{'comment'}<>$adv->{'lasttime'}<><>$adv->{'number'}<>$adv->{'id'}<>$adv->{'item_name'}<>\n");
	}

	# �t�@�C���X�V
	if($use->{'TypeRenew'}){

		# �g�b�v�f�[�^��ǉ�
		unshift(@renew_line,"$data{'key'}<>\n");

		# �t�@�C���X�V
		seek($file_handle1,0,0);
		truncate($file_handle1,tell($file_handle1));
		print $file_handle1 @renew_line;
	}

# �t�@�C�������
close($file_handle1);

	# �p�[�~�b�V�����ύX
	if($use->{'TypeRenew'}){ Mebius::Chmod(undef,$data{'file'}); }

	# �C���f�b�N�X�̕��ёւ�
	if($use->{'TypeGetIndex'}){
			if($use->{'Sort'} eq "login"){ @RANKING = sort { (split(/<>/,$b))[9] <=> (split(/<>/,$a))[9] } @RANKING; }
			elsif($use->{'Sort'} eq "name"){ @RANKING = sort { (split(/<>/,$a))[2] cmp (split(/<>/,$b))[2] } @RANKING; }
			elsif($use->{'Sort'} eq "gold"){ @RANKING = sort { (split(/<>/,$b))[7] <=> (split(/<>/,$a))[7] } @RANKING; }
			elsif($use->{'Sort'} eq "maxhp"){ @RANKING = sort { (split(/<>/,$b))[6] <=> (split(/<>/,$a))[6] } @RANKING; }
			elsif($use->{'Sort'} eq "level_low"){ @RANKING = sort { (split(/<>/,$a))[3] <=> (split(/<>/,$b))[3] } @RANKING; }
			else{ @RANKING = sort { (split(/<>/,$b))[3] <=> (split(/<>/,$a))[3] } @RANKING; }

		# ���`
		$line .= qq(<table class="adventure"><tr><th>����</th><th>���x��</th><th>���O</th><th>�E��</th><th>HP</th>);
			if($use->{'Sort'} eq "gold"){ $line .= qq(<th>�S�[���h</th>); }
		$line .= qq(<th>�R�����g</th><th>SNS</th></tr>);

	}

	# �t�@�C�����e���ēW�J
	if($use->{'TypeGetIndex'}){

		# �Ǐ���
		my($i,$hit);

			# �z���W�J
			foreach(@RANKING){

				# �J�E���^
				$i++;
	
				# ���̍s��W�J
				chomp;
				my($key,$id2,$name,$level,$jobname,$hp,$maxhp,$gold,$comment,$lasttime,$host2,$number,$account,$itemname) = split(/<>/);
				my($view_itemname,$class1,$mark1);

					# �G�X�P�[�v����
					if($id2 eq ""){ next; }

					# �E�Ƃōi�荞��
					if($use->{'SelectJobName'}){
						if($use->{'SelectJobName'} ne $jobname){ next; }
					}

				# �J���}��t����
				my($hp_comma,$maxhp_comma,$gold_comma) = Mebius::MultiComma({ Language => $init->{'comma_language'} },[$hp,$maxhp,$gold]);

					#if($lasttime+$init->{'charaon_day'}*24*60*60 < $main::time){ $class1 = qq( class="disable"); }
					#elsif($adv->{'login_flag'} && $adv->{'maxhp'} < $maxhp*$init->{'select_battle_gyap'}){ $mark1 = qq( <span class="alert">( �� )</span> ); }
					#if($main::myadmin_flag >= 5){ $view_itemname = qq(<br>����F $itemname); }

					# �ő�\���s���ɒB�����ꍇ
					if($hit > $max_view) { $flow_flag = 1; last; }

				$hit++;
				#$rdate = $lasttime + (60*60*24*$init->{'reset_limit'});

				$line .= qq(<tr$class1>\n);
				$line .= qq(<td>$i</td>\n);
				$line .= qq(<td>$level</td>\n);

					# �X�e�[�^�X�ւ̃����N
					# ���f�[�^
					if($use->{'TypeOldFile'}){
						$line .= qq(<td><a href="$init->{'script'}?mode=chara&amp;chara_id=$id2">$name</a> );
					}
					# �V�f�[�^
					else{
						$line .= qq(<td><a href="$init->{'script'}?mode=status&amp;id=$id2">$name</a> );
					}

					if($main::myaccount{'admin'}){ $line .= qq( - $id2); }
				$line .= qq($mark1</td>\n);

				$line .= qq(<td>$jobname</td><td class="hpcolor">$hp_comma / $maxhp_comma</td>\n);
						if($use->{'Sort'} eq "gold"){ $line .= qq(<td class="goldcolor">$gold_comma G</td>); }
				$line .= qq(<td><div class="comment">$comment$view_itemname</div></td>\n);
					if($account){ $account = qq(<a href="${main::auth_url}$account/">$account</a>); }
				$line .= qq(<td>$account</td>);
				$line .= qq(</tr>\n);

			}

		# ���`
		$line .= qq(</table>);

	}

return($line,$data{'select_option_line'},$flow_flag);

}



1;
