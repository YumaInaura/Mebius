
use strict;
package Mebius::BBS;

#-----------------------------------------------------------
# �ߋ����O�\���y�[�W
#-----------------------------------------------------------
sub PastIndexView{

# �錾
my($type) = @_;
my($plustype_all,%recentry_index,%year_index,%all_index,$recentry_line);
my($allindex_line,$yearindex_line,$h1_text,$plustype_search,$pagelinks_line,$monthf,$yearf,$start_page,$search_keyword);
my($allbbs_index_line,$all_line,$search_form,$navigation_line);

# CSS��`
$main::css_text .= qq(
table.past_index{border-style:none;width:100%;}
form.pastindex_search{padding:0.5em;margin:1em 0em;background:#ddd;}
h1{font-size:160%;}
h2{font-size:120%;}
td.past,th.past{border-style:none;padding:0.5em 0.2em;}
div.pagelinks_pastindex{padding:0.3em 0.75em;border:1px solid #333;margin:1em 0em;}
div.past_menu{padding:0.5em 1em;background:#fee;}
);

	# �Ǘ����[�h��`
	if($type =~ /Admin-mode/){
		$plustype_all .= qq( Admin-mode);
	}

	# �y�[�W�w��G���[
	if($main::submode_num > 5){
		main::error("���̃��[�h�͑��݂��܂���B");
	}

	# ��{�^�C�g����`
	if($type =~ /Select-BBS-view/){
		$main::head_link3 = qq(&gt; <a href="past.html">�ߋ����O</a>);
	}

	# �����^�C�v���`

	# �S�f���̑僁�j���[
	if($type =~ /All-BBS-view/){
		$main::sub_title = qq(�ߋ����O | ���r�E�X�����O - $main::server_domain );
		$main::head_link4 = qq(&gt; �ߋ����O);
		$h1_text = qq(�ߋ����O - $main::server_domain );
	}

	# �f�����Ƃ̃��j��
	elsif($type =~ /Select-BBS-view/){

			# �ߋ����O����
			if($main::ch{'word'}){
				$type .= qq( Search-view);
				$plustype_all .= qq( Search-index);
				$main::head_link4 = qq(&gt; �h$main::in{'word'}�h�̌�������);
				$main::sub_title = qq(�h$main::in{'word'}�h�̌������� | �ߋ����O | $main::head_title);
				$h1_text = qq(�ߋ����O);
					if($main::in{'handle'}){ $plustype_search .= qq( Handle-search); }
					if($main::in{'subject'}){ $plustype_search .= qq( Subject-search); }
					if($main::in{'strict'}){ $plustype_search .= qq( Strict-search); }
					$yearf = $main::in{'target'};
					$monthf = $main::in{'month'};
					$start_page = $main::in{'page'};
					$search_keyword = $main::in{'word'};
					if($yearf && !$monthf || $yearf eq "all"){ $type .= qq( Year-view); }
					elsif($yearf && $monthf){ $type .= qq( Month-view); }
					elsif($yearf eq "recentry"){ $type .= qq( Recentry-view); }
					else{ main::error("�����^�C�v���w�肵�Ă��������B"); }
			}
			# ��{���j���[
			elsif($main::submode2 eq ""){
				$type .= qq( All-view Toppage-view);
				$plustype_all .= qq( Normal-view);
				$main::sub_title = qq(�ߋ����O | $main::head_title);
				$main::head_link3 = qq(&gt; �ߋ����O);
				$h1_text = qq($main::title - �ߋ����O);
			}
			# �N�ʂɕ\��
			elsif($main::submode2 eq "year" && $main::submode3 =~ /^(\d+)$/ && $main::submode4 =~ /^(all)$/ && $main::submode5 =~ /^(|\d+)$/){
				$type .= qq( Year-view);
				$plustype_all .= qq( Normal-view);
				$yearf = $main::submode3;
				$monthf = $main::submode4;
				$start_page = $main::submode5;
				$main::sub_title = qq($yearf�N �ߋ����O | $main::head_title);
				$main::head_link4 = qq(&gt; $yearf�N);
				$h1_text = qq($main::title - $yearf�N�̉ߋ����O);
			}
			# ���ʂɕ\��
			elsif($main::submode2 eq "year" && $main::submode3 =~ /^(\d+)$/ && $main::submode4 =~ /^(\d{2})$/ && $main::submode5 =~ /^(|\d+)$/){
				$type .= qq( Month-view);
				$plustype_all .= qq( Normal-view);
				$yearf = $main::submode3;
				$monthf = $main::submode4;
				$start_page = $main::submode5;
				$main::sub_title = qq($yearf�N$monthf�� �ߋ����O | $main::head_title);
				$main::head_link4 = qq(&gt; <a href="past-year-$yearf-all.html">$yearf�N</a>);
				$main::head_link5 = qq(&gt; $monthf��);
				$h1_text = qq($main::title - $yearf�N$monthf���̉ߋ����O);

			}

			else{
				main::error("�\\�����[�h���w�肵�Ă��������B");
			}

	}


	# �^�C�g������
	if($start_page){
		$main::sub_title = qq($main::sub_title | $start_page );
	}

	# ���o�C���^�A�N�Z�X�̏ꍇ
	if($main::device_type eq "mobile"){
		main::kget_items();
		$plustype_all .= qq( Mobile-view);
	}
	# �f�X�N�g�b�v�^�A�N�Z�X�̏ꍇ
	else{
		$plustype_all .= qq( Desktop-view);
	}


	# �S�f���̃��X�g���擾����
	if($type =~ /All-BBS-view/){
		my(%all_bbs_index) = Mebius::BBS::PastIndexAllBBS("Get-index Addtion-Hx");
		$allbbs_index_line = $all_bbs_index{'index_line'};
	}

	# �S�ߋ����O�̃��j���[���擾����
	(%all_index) = Mebius::BBS::PastIndexAll("Get-index Months-link $plustype_all",$main::realmoto,$yearf,$monthf);

		# �����X�V
		# 2012/2/23 (��)
		if($all_index{'please_fix_renew_flag'}){
			Mebius::BBS::PastIndexAll("Renew",$main::realmoto,$yearf,$monthf);
		}

		if($type =~ /All-view|Year-view|Month-view/ && $all_index{'index_line'}){
			$allindex_line .= qq(<div class="past_menu">);
				#if($type =~ /Toppage-view/){ $allindex_line .= qq(<h2$main::kstyle_h2>�ߋ����O�ꗗ</h2>\n); }
				#else{ $allindex_line .= qq(<h2$main::kstyle_h2><a href="past.html">�ߋ����O�ꗗ</a></h2>\n); }
			$allindex_line .= qq(<div class="line-height">$all_index{'index_line'}</div>\n);
			$allindex_line .= qq(</div>);
		}


	# �N�ʂ̃��j���[���擾����
	if($type =~ /Year-view/){

		# �J���t�@�C���̍Ē�`
		my($yearf_select);
			if($yearf eq "all"){ $yearf_select = $all_index{'all_years'}; }
			else{ $yearf_select = $yearf; }

		(%year_index) = Mebius::BBS::PastIndex("Year-file Get-index Addtion-Hx $plustype_all",$main::realmoto,$yearf_select,$monthf,undef,$start_page,$search_keyword);
			if($year_index{'index_line'}){
				#$yearindex_line .= qq(<h2$main::kstyle_h2>$yearf�N�̉ߋ����O ( $year_index{'thread_num'}�L�� )</h2>\n);
				$yearindex_line .= qq($year_index{'index_line'});
				$pagelinks_line = qq($year_index{'pagelinks_line'});
			}
	}

	# �����ʂ̃��j���[���擾����
	if($type =~ /Month-view/){
		(%year_index) = Mebius::BBS::PastIndex("Year-file Get-index Month-view Addtion-Hx $plustype_all",$main::realmoto,$yearf,$monthf,undef,$start_page,$search_keyword);
			if($year_index{'index_line'}){
				#$yearindex_line .= qq(<h2$main::kstyle_h2>$yearf�N$monthf���̉ߋ����O ( $year_index{"thread_num_month$monthf"}�L�� )</h2>\n);
				$yearindex_line .= qq($year_index{'index_line'});
				$pagelinks_line = qq($year_index{'pagelinks_line'});
			}
	}

	# �ŋ߂̉ߋ����O���擾���擾����
	#if($type =~ /All-view/){
	#	(%recentry_index) = Mebius::BBS::PastIndex("Recentry-file Get-index Addtion-Hx $plustype_all",$main::realmoto,undef,undef,undef,undef,$search_keyword);
	#		if($recentry_index{'index_line'}){
	#			#$recentry_line .= qq(<h2$main::kstyle_h2>�ŋ߂̉ߋ����O</h2>\n);
	#			$recentry_line .= qq($recentry_index{'index_line'});
	#		}
	#}

	# �������t�H�[�����擾
	if($type =~ /Select-BBS-view/){
		($search_form) = Mebius::BBS::PastIndexSearchForm("$plustype_all",%all_index);
	}

# �w�b�_
main::header("Body-print");

	# �i�r�Q�[�V���������N���`
	if(!$main::kflag){
		$navigation_line .= qq(<div class="word-spacing">);
		$navigation_line .= qq(<a href="$main::home">�s�n�o�y�[�W</a>\n);

			if($type =~ /All-BBS-view/){ $navigation_line .= qq(�S�f���̉ߋ����O\n); }
			else{ $navigation_line .= qq(<a href="${main::main_url}past.html">�S�f���̉ߋ����O</a>\n);  }

			if($type !~ /All-BBS-view/){
					if($type =~ /All-view/){ $navigation_line .= qq($main::title�̉ߋ����O\n); }
					else{ $navigation_line .= qq(<a href="./past.html">$main::title�̉ߋ����O</a>\n); }
			}

		$navigation_line .= qq(<a href="./">$main::title</a>\n);
		$navigation_line .= qq(</div>);
	}

# ���o���\��
$all_line .= qq(<h1$main::kstyle_h1>$h1_text</h1>\n);
$all_line .= qq(
$navigation_line
$search_form
);

	# ���ׂẴ��C�����`
	if($type !~ /Search-view/){
		$all_line .= qq($allindex_line);
	}

$all_line .= qq(
<div id="LIST">
$yearindex_line
$recentry_line
$pagelinks_line
$allbbs_index_line
</div>
);

	# ���ׂẴ��C�����`
	if($type =~ /Search-view/){
		$all_line .= qq($allindex_line);
	}

# �Ǘ��p��URL�ϊ�
if($type =~ /Admin-mode/){ ($all_line) = Mebius::Fixurl("Normal-to-admin Multi-fix",$all_line); }

# HTML��\��
print qq($all_line);

# �t�b�^
main::footer("Body-print");

exit;

}

#-----------------------------------------------------------
# �����{�b�N�X
#-----------------------------------------------------------
sub PastIndexSearchForm{

# �錾
my($type,%all_index) = @_;
my($form,$checked_subject,$checked_handle,$checked_strict);
my($checked_target_recentry,$checked_target_all);

	# �I�[�g�t�H�[�J�X�𓖂Ă�
	if(!exists $main::in{'word'}){
		$main::body_javascript = qq( onload="document.pastindex_search.word.focus()");
	}

	# �`�F�b�N
	if($main::in{'subject'}){ $checked_subject = $main::parts{'checked'}; }
	if($main::in{'handle'}){ $checked_handle = $main::parts{'checked'}; }
	if($main::in{'strict'}){ $checked_strict = $main::parts{'checked'}; }
	if($main::in{'target'} eq "all"){ $checked_target_all = $main::parts{'checked'}; }
	elsif($main::in{'target'} eq "recentry" || $main::in{'target'} eq ""){ $checked_target_recentry = $main::parts{'checked'}; }

	# ��؂��
	if($type =~ /Mobile-view/){
		$form .= qq(<hr>\n);
	}

# �t�H�[����`
$form .= qq(<form method="get" action="./$main::script" name="pastindex_search" class="pastindex_search">\n);
$form .= qq(<div class="size90">\n);
$form .= qq(<input type="hidden" name="mode" value="past"$main::xclose>\n);
$form .= qq(<input type="text" name="word" value="$main::in{'word'}" size="13" class="normal"$main::xclose>\n);


	# ���M�{�^��
	if($type =~ /Desktop-view/){
		$form .= qq(<input type="submit" value="�ߋ����O���猟������" class="isubmit"$main::xclose>\n);
	}
	elsif($type =~ /Mobile-view/){
		$form .= qq(<input type="submit" value="����"$main::xclose>\n);
	}


# �i�荞��
	if($type =~ /Desktop-view/){ $form .= qq(�@�i�荞�݁F ); }
	elsif($type =~ /Mobile-view/){ $form .= qq(\n<br$main::xclose>); }

$form .= qq(<input type="checkbox" name="subject" value="1" id="past_search_subject"$checked_subject$main::xclose>);
$form .= qq(<label for="past_search_subject">�薼</label>\n);
$form .= qq(<input type="checkbox" name="handle" value="1" id="past_search_handle"$checked_handle$main::xclose>);
$form .= qq(<label for="past_search_handle">�쐬��</label>\n);
$form .= qq(<input type="checkbox" name="strict" value="1" id="past_search_strict"$checked_strict$main::xclose>);
$form .= qq(<label for="past_search_strict">�B�������I�t</label>\n);

# �����ΏۂƂȂ�t�@�C��
	if($type =~ /Desktop-view/){ $form .= qq(\n�@|�@�����ΏہF); }
	elsif($type =~ /Mobile-view/){ $form .= qq(\n<br$main::xclose>); }

	$form .= qq(<input type="radio" name="target" value="recentry" id="past_target_recentry"$checked_target_recentry$main::xclose>);
$form .= qq(<label for="past_target_recentry">�ŋ�</label>\n);
$form .= qq($all_index{'input_radio'}\n);
$form .= qq(<input type="radio" name="target" value="all" id="past_target_all"$checked_target_all$main::xclose>);
$form .= qq(<label for="past_target_all">�S��</label>\n);

$form .= qq(</div>\n);
$form .= qq(</form>\n);

	# ��؂��
	if($type =~ /Mobile-view/){
		$form .= qq(<hr>\n);
	}

return($form);

}

#-----------------------------------------------------------
# ��ꂽ�e�L�����ߋ����O��
#-----------------------------------------------------------
sub BePastThread{

# �Ǐ���
my($type,$realmoto,$thread_number) = @_;
my(%renew,$yearf,$monthf,$plustype_bepast_multi);

# �����`�F�b�N
if($realmoto =~ /\W/){ return(); }
if($thread_number =~ /\D/){ return(); }

# �L�[��ݒ�
$renew{'key'} = 3;
$renew{'Concept_plus'} = " Be-pasted";

# �L�����m�F
my($thread) = Mebius::BBS::thread({ TypeGetHashDetail => 1 , ReturnReference => 1 },$realmoto,$thread_number);

	# �L�������݂��Ȃ��ꍇ�̓��^�[��
	if(!$thread->{'f'}){ return(); }

	# �폜���ꂽ�L���͉ߋ����O�����Ȃ�
	if($thread->{'deleted_flag'}){ return(); }

	# ���ߋ����O�L�����A�V�ߋ����O�ɕϊ�����ꍇ
	if($type =~ /Old-thread/){

			# ���ɂ����ǉߋ����O�����Ă���ꍇ
			if($thread->{'bepast_time'} =~ /^(\d{9,})$/){ $renew{'bepast_time'} = $thread->{'bepast_time'}; }

			# �ߋ����O�����t���Ȃ��ꍇ�́A�t�@�C���̍ŏI�X�V�����g��
			else{ $renew{'bepast_time'} = $thread->{'stat_last_modified'}; }

			#if($main::alocal_mode){ $renew{'bepast_time'} = $main::time - 3*365*24*60*60 }
		$plustype_bepast_multi .= qq( Old-thread);
	}
	# ���ʂɐV�K���e����ߋ����O������ꍇ
	else{
		$renew{'bepast_time'} = time;
	}

	# �ߋ����O���̓��t���w��ł��Ȃ������ꍇ�A���^�[��
	if(!$renew{'bepast_time'}){ return(); }

	# �ߋ����O�����t����N�����擾
	my(%bepast_time) = Mebius::Getdate("Get-hash",$renew{'bepast_time'});

# �L�����X�V
my($renewed_thread) = Mebius::BBS::thread({ TypeRenew => 1 , ReturnReference => 1 , SelectRenew => \%renew },$realmoto,$thread_number);

# �ߋ����O�t�@�C���R��ނ��X�V
Mebius::BBS::PastIndexMulti("Renew New-line $plustype_bepast_multi",$realmoto,$bepast_time{'yearf'},$bepast_time{'monthf'},$renewed_thread);

}

#-----------------------------------------------------------
# �ߋ����O�C���f�b�N�X�𑀍� ( �S�� )
#-----------------------------------------------------------
sub PastIndexMulti{

# �錾
my($type,$realmoto,$yearf,$monthf,$thread) = @_;
my($plustype);

# �����n�������^�C�v���`
if($type =~ /Renew/){ $plustype .= qq( Renew); }
if($type =~ /New-line/){ $plustype .= qq( New-line); }
if($type =~ /Delete-thread/){ $plustype .= qq( Delete-thread); }
if($type =~ /Repair-thread/){ $plustype .= qq( Repair-thread); }
if($type =~ /Admin-mode/){ $plustype .= qq( Admin-mode); }
if($type =~ /Old-thread/){ $plustype .= qq( Old-thread); }

# �V�ߋ����O�̃C���f�b�N�X���X�V ( �ŋ߂̃��O )
Mebius::BBS::PastIndex("Recentry-file $plustype",$realmoto,undef,undef,$thread);

# �V�ߋ����O�̃C���f�b�N�X���X�V ( �N�ʂ̃��O )
Mebius::BBS::PastIndex("Year-file $plustype",$realmoto,$yearf,$monthf,$thread);

}

use Mebius::PostData;

#-----------------------------------------------------------
# �ŋ� / �N�ʂ̉ߋ����O
#-----------------------------------------------------------
sub PastIndex{

# �錾
my($type,$realmoto,$yearf,$monthf) = @_;
my(undef,undef,undef,undef,$maxview_index,$start_page,$search_keyword) = @_ if($type =~ /Get-index/);
my(undef,undef,undef,undef,$thread) = @_ if($type =~ /(New-line|Delete-thread|Repair-thread)/);
my($i,$file,$maxline_index,%data,$maxview_index_strong);
my($index_line,@index_line,$pagelinks_line,$max_pagelinks,$i_reverse,@files,$file_split);
my($line_num_all,$pagelinks_number,$search_keyword_encoded,%postbuf,%data);

	# �����`�F�b�N�P
	if($realmoto =~ /^$|\W/){ return(); }

	# �����`�F�b�N�Q
	if($type =~ /Renew/){
			if($thread->{'number'} =~ /^$|\D/){ return(); }
	}

	# �V�K�o�^���̃`�F�b�N
	if($type =~ /New-line/){
			if(!$thread){ return(); }
			if(!$thread->{'bepast_time'}){ return(); }
	}

	# �N�ʃt�@�C���񒲐�
	if($type =~ /Year-file/){
			if($yearf =~ /^$|[^\w,]/){ return(); }
			if($type =~ /New-line/ && $monthf =~ /^$|\D/){ return(); }

	}

	# �ŋ߂̃t�@�C������
	if($type =~ /Recentry-file/){
			if($type =~ /Get-index/ && !$maxview_index){
					if($type =~ /Desktop-view/){ $maxview_index = 10; }
					elsif($type =~ /Mobile-view/){ $maxview_index = 5; }
			}
	}


	# �����ݒ�
	if($type =~ /Search-index/){

		# �L�[���[�h���G���R�[�h
		($search_keyword_encoded) = Mebius::Encode(undef,$search_keyword);

		# �|�X�g�o�b�t�@���폜���Ē�`
		(%postbuf) = Mebius::PostBuf("Delete-key",$main::postbuf,"page","moto");

			# �����I�v�V�������w�肳��Ă��Ȃ��ꍇ�A��{�l��ݒ�
			if($type !~ /(Subject-search|Handle-search)/){
				$type .= qq( Subject-search); 
				$type .= qq( Handle-search); 
			}
	}

	# �\���ő吔 / �y�[�W�߂���P�ʂ��`
	if($type =~ /Get-index/ && !$maxview_index){
			if($type =~ /Desktop-view/){ $maxview_index = 100; }
			elsif($type =~ /Mobile-view/){ $maxview_index = 20; }
	}


	# �y�[�W�����N���A���ꂼ�ꍶ�E�ɉ��܂ŕ\�����邩
	if($type =~ /Desktop-view/){ $max_pagelinks = 9; }
	elsif($type =~ /Mobile-view/){ $max_pagelinks = 9; }


# �f�B���N�g����`
my $directory1 = "${main::int_dir}_bbs_index/";
my $directory2 = "${directory1}_${realmoto}_index/";

	# �t�@�C����`
	if($type =~ /Year-file/){
		@files = split(/,/,$yearf);
		#if($main::alocal_mode){ @files = ("2010","2011","2012"); }
	}
	elsif($type =~ /Recentry-file/){
		$maxline_index = 5000;
		$maxview_index_strong = 50;
		@files = ("recentry");
	}

	# �����ő吔
	if(!$maxview_index_strong){ $maxview_index_strong = 30000; }
	if(!$maxline_index){ $maxline_index = 30000; }

	# ���S�t�@�C����W�J
	foreach $file_split (@files){

		# �Ǐ���
		my($file,@renew_index,$past_index_handler,%months,$thread_num);

		# �t�@�C����`
		if($file_split =~ /^(\w+)$/){ $file = "${directory2}${realmoto}_${file_split}_past.log"; } else { next; }

		# �t�@�C�����J��
		open($past_index_handler,"<",$file);

			# �t�@�C�����b�N
			if($type =~ /Renew/){ flock($past_index_handler,1); }

		# �g�b�v�f�[�^�𕪉�
		chomp(my $top1 = <$past_index_handler>);
		($data{'key'},$data{'thread_num'},$data{'line_num'},$data{'months'}) = split(/<>/,$top1);

		# �����W�J�p�̒�������
		$line_num_all += $data{'line_num'};

			# �n�b�V�������Ԃ��ꍇ
			if($type =~ /Get-hash-only/){
				close($past_index_handler);
				return(%data);
			}


		# ���E���h�J�E���^��������`
		my $i_reverse1 = $data{'line_num'} + 1;

				# �t�@�C����W�J����
				while(<$past_index_handler>){

					# �Ǐ���
					my($hit,$i_search,$keyword_split,$hit_point2);

					# �s�𕪉�
					chomp;
					my($key2,$monthf2,$subject2,$posthandle2,$resnum2,$thread_number2,$bepasttime2,$posttime2) = split(/<>/);

						# ���ʕ\���̏ꍇ ( �C���f�b�N�X�擾 )
						if($type =~ /Get-index/){
								if($type =~ /Month-view/ && $monthf2 ne $monthf){ next; }
						}

					# ���E���h�J�E���^
					$i++;
					$i_reverse1--;

						# �����ő�s���ɒB�����ꍇ�A�����I�� ( �����ׂ�h���\������ )
						if($i > $maxline_index && $maxline_index){ last; }

						# �\���ő�s�� ( ���� ) �ɒB�����ꍇ�A�����I�� ( �����ׂ�h���\������ )
						if($i > $maxview_index_strong && $maxview_index_strong){ last; }

						# ���폜�p
						if($type =~ /Delete-thread/){
								if($thread_number2 eq $thread->{'number'} && $key2 !~ /Deleted/){
									$key2 .= qq( Deleted);
								}
						}

						# �������p
						elsif($type =~ /Repair-thread/){
								if($thread_number2 eq $thread->{'number'} && $key2 =~ /Deleted/){
									$key2 =~ s/(\s?)Deleted//g;
								}
						}

						# ���̃t�@�C���̋L���� ( �폜���ꂽ�L���͂̂��� )
						if($key2 !~ /Deleted/){
							# �S�L����
							$thread_num++;
							# ���ʋL����
							$months{"$monthf2"}++;
						}

						# ���C���f�b�N�X�擾�p
						if($type =~ /Get-index/){

								# ���L�[���[�h��������ꍇ
								if($type =~ /Search-index/){

										# �L�[���[�h���X�y�[�X��؂�œW�J
										foreach $keyword_split (split(/ |�@/,$search_keyword)){

											# �Ǐ���
											my($plustype_similar);

											# ���E���h�J�E���^
											$i_search++;

												# �薼������
												if($type =~ /Subject-search/){
														if($type =~ /Strict-search/){ $plustype_similar .= qq( Strict-search); }
													my($hit_buffer) = Mebius::Text::SimilarJudge("Cut-keyword $plustype_similar",$subject2,$keyword_split);
														if($hit_buffer){ $hit++; }
													$hit_point2 += $hit_buffer;
												}

												# �쐬�҂̕M��������
												if($type =~ /Handle-search/){
													my($hit_buffer) = Mebius::Text::SimilarJudge("Strict-search",$posthandle2,$keyword_split);
														if($hit_buffer){ $hit++; }
													$hit_point2 += $hit_buffer;
												}
										}

										# �q�b�g���Ȃ���Ύ��񏈗��� ( AND���� )
										if($hit < $i_search){ next; }

								}
							
								# �C���f�b�N�X�z���ǉ�
					push(@index_line,"$hit_point2<>$i_reverse1<>$key2<>$monthf2<>$subject2<>$posthandle2<>$resnum2<>$thread_number2<>$bepasttime2<>$posttime2<>\n");

						}

						# ���t�@�C���X�V�p
						if($type =~ /Renew/){

								# �����L���͏d�����Ēǉ����Ȃ�
								if($type =~ /New-line/){
										if($thread->{'number'} eq $thread_number2){ next; }
								}
								
							# �s��ǉ�
							push(@renew_index,"$key2<>$monthf2<>$subject2<>$posthandle2<>$resnum2<>$thread_number2<>$bepasttime2<>$posttime2<>\n");

						}

				}

		# �t�@�C�������
		close($past_index_handler);

			# ���t�@�C�����X�V����
			if($type =~ /Renew/){

					# �Ǐ���
					my(@months,$newkey);

					# ���V�����s��ǉ�����ꍇ
					if($type =~ /New-line/){

						# �L�����J�E���^�𑝂₷
						$thread_num++;
						$months{$monthf}++;

						# ���E���h�J�E���^�𑝂₷
						$i++;

						# �L�[�w��
						if($type =~ /Old-thread/){
							$newkey .= qq( Old-thread);
						}

					# �V�����ǉ�����s
					unshift(@renew_index,"$newkey<>$monthf<>$thread->{'subject'}<>$thread->{'posthandle'}<>$thread->{'res'}<>$thread->{'number'}<>$thread->{'bepast_time'}<>$thread->{'posttime'}<>\n");

						# �ߋ����O���������t�Ń\�[�g
						@renew_index = sort { (split(/<>/,$b))[6] <=> (split(/<>/,$a))[6] } @renew_index;

							# �S�ߋ����O�t�@�C�����X�V
							if($type =~ /Year-file/){
								Mebius::BBS::PastIndexAll("Renew New-line",$realmoto,$yearf,undef,$thread_num);
							}

					}

					# ���s���폜 / ���������ꍇ
					if($type =~ /(Delete-thread|Repair-thread)/){
							Mebius::BBS::PastIndexAll("Renew",$realmoto,$yearf,undef,$thread_num);
					}

				# �f�B���N�g���쐬
				Mebius::Mkdir(undef,$directory1);
				Mebius::Mkdir(undef,$directory2);

					# ���J�E���g��W�J����
					if(%months){
							foreach(keys %months){
								push(@months,"$_=$months{$_}");
							}
						@months = sort { (split(/=/,$b))[0] <=> (split(/=/,$a))[0] } @months;
						$data{'months'} = "@months";
					}

				# �g�b�v�f�[�^��ǉ�
				unshift(@renew_index,"$data{'key'}<>$thread_num<>$i<>$data{'months'}<>\n");

				# �t�@�C���X�V
				Mebius::Fileout(undef,$file,@renew_index);

			}

	}

	# ���C���f�b�N�X�̍ēW�J
	if($type =~ /Get-index/){

		# �Ǐ���
		my($first_page_number,$lastroupe_monthf);
		my $i_reverse_foreach = $i + 1;

		# �y�[�W�߂��萔�̎w�肪�Ȃ��ꍇ�͑��
		if(!$start_page){
			$type .= qq( First-page);
				if($type =~ /Normal-view/){
					$start_page = $i;
				}
				if($type =~ /Search-index/){
					$start_page = 1;
				}
		}

			# �z����\�[�g����ꍇ
			if($type =~ /Search-index/){
				@index_line = sort { (split(/<>/,$b))[0] <=> (split(/<>/,$a))[0] } @index_line;
			}

			# �z���W�J
			foreach(@index_line){

				# �Ǐ���
				my($mark2);

					# ���E���h�J�E���^
					$data{'i'}++;
					$i_reverse_foreach--;

					# �s�𕪉�
					chomp;
					my($hit_point2,$i2,$key2,$monthf2,$subject2,$posthandle2,$resnum2,$thread_number2,$bepasttime2,$posttime2) = split(/<>/);

						# ���y�[�W�߂���p�̃����N���` ( ��� )
						if($type =~ /Normal-view/){

								# �������P - ��؂�̗ǂ�������
								if($i_reverse_foreach % $maxview_index == 0 
								# �������Q - �܂��\������s���c���Ă���
								&& $i_reverse_foreach >= 1){
									my($page) = int($i_reverse_foreach / $maxview_index); 
										# �����y�[�W�̏ꍇ
										if($i_reverse_foreach == $start_page){
											$pagelinks_line .= qq(<span style="color:#f00;">$page</span>\n);
										}
										# �����y�[�W�ł͂Ȃ����A�����y�[�W���ӂ̃����N�̏ꍇ
										elsif($type =~ /Desktop-view/
										|| 	($i_reverse_foreach <= $start_page + ($maxview_index*$max_pagelinks)
										&& $i_reverse_foreach >= $start_page - ($maxview_index*$max_pagelinks))){
											$pagelinks_line .= qq(<a href="past-year-$yearf-$monthf-$i_reverse_foreach.html#LIST">$page</a>\n);
										}
										# �ŏ��̃y�[�W�͕K���\������
										elsif($i_reverse_foreach == $maxview_index){
											$pagelinks_line .= qq( .. <a href="past-year-$yearf-$monthf-$i_reverse_foreach.html#LIST">$page</a>\n);
										}
								}
						}

						# ���y�[�W�߂���p�̃����N���` ( ���� )
						if($type =~ /Search-index/){

								# �������P - ��؂�̗ǂ�������
								if(($data{'i'} - 1) % $maxview_index == 0){

									# �y�[�W���̕\�������[�v���Ƃɑ��₷
									$pagelinks_number++;

										# �����y�[�W�̏ꍇ
										if($data{'i'} == $start_page){
											$pagelinks_line .= qq(<span style="color:#f00;">$pagelinks_number</span>\n);
										}
										# �����y�[�W�ł͂Ȃ����A�����y�[�W���ӂ̃����N�̏ꍇ�A�������͍ŏ��̃y�[�W�̏ꍇ
										elsif($data{'i'} == 1
										|| ($data{'i'} <= $start_page + ($maxview_index*$max_pagelinks)
										&& $data{'i'} >= $start_page - ($maxview_index*$max_pagelinks))){
											$pagelinks_line .= qq(<a href="./?mode=pastindex&amp;$postbuf{'body'}&amp;page=$data{'i'}#LIST">$pagelinks_number</a>\n);
										}

								}

						}


						# �s���폜�ς݂̏ꍇ
						if($key2 =~ /Deleted/){
								if($type !~ /Admin-mode/){ next; }
							$mark2 .= qq( <span style="color:#f00;">[ �폜�ς� ]</span>);
						}

						# ���`���̉ߋ����O����L�^�����ꍇ
						if($key2 =~ /Old-thread/ && $type =~ /Admin-mode/){
							$mark2 .= qq( <span style="color:#f00">[ ���`������L�^ ]</span>);
						}

					# �q�b�g�J�E���^
					$data{'hit'}++;

					# ���ʃq�b�g�J�E���^
					$data{"thread_num_month$monthf2"}++;

						# ���y�[�W�߂��菈�� ( ���� )
						if($start_page && $type =~ /Normal-view/){
								# �O�߂���
								if($i_reverse_foreach > $start_page){ next; }
								# ��߂���
								if($i_reverse_foreach <= $start_page - $maxview_index){
									$data{'flow_index'}++;
									next; 
								}
								# �Q�y�[�W�ڂŁA�����y�[�W�Əd������L���͕\�����Ȃ�
								if($type !~ /First-page/ && $i_reverse_foreach > $line_num_all - $maxview_index){
									next;
								}
						}

						# ���y�[�W�߂��菈�� ( ���� )
						if($start_page && $type =~ /Search-index/){
								# �O�߂���
								if($data{'i'} < $start_page){ next; }
								# ��߂���
								if($data{'i'} >= $start_page + $maxview_index){
									$data{'flow_index'}++;
									next; 
								}
						}


					# �O���j�b�W����������t�����Z
					my(%time_bepast) = Mebius::Getdate("Get-hash-detail",$bepasttime2);
					my(%time_postthread) = Mebius::Getdate("Get-hash-detail",$posttime2);
					my($gyap_time2) = Mebius::SplitTime("Get-top-unit",$bepasttime2 - $posttime2);

						# �f�X�N�g�b�v�ł̕\��
						if($type =~ /Desktop-view/){

								# ���ʂ̌��o���\��
								if($monthf2 ne $lastroupe_monthf && $type !~ /(Search-index|Month-view)/){
									$index_line .= qq(<tr>);
									$index_line .= qq(<td class="past">);
									$index_line .= qq(<a href="past-year-$yearf-$monthf2.html"><strong class="month">$yearf�N$monthf2��</strong></a>);
									$index_line .= qq(</td>);
									$index_line .= qq(</tr>\n);
								}

							# �L����\��
							$index_line .= qq(<tr>);
							#$index_line .= qq(<td class="past">);
							#$index_line .= qq($i2);
							#$index_line .= qq(</td>);
							$index_line .= qq(<td class="past">);
							$index_line .= qq(<a href="$thread_number2.html">$subject2</a>$mark2);
							$index_line .= qq(</td>);
							$index_line .= qq(<td class="past">);
							$index_line .= qq($posthandle2);
							$index_line .= qq(</td>);
							$index_line .= qq(<td class="past">);
							$index_line .= qq($resnum2��);
							$index_line .= qq(</td>);
							$index_line .= qq(<td class="past">);
							$index_line .= qq($time_bepast{'date_forward_day'});
							$index_line .= qq(</td>);
							$index_line .= qq(<td class="past">);
							$index_line .= qq($time_postthread{'date_forward_day'});
							$index_line .= qq(</td>);
							$index_line .= qq(<td class="past">);
							$index_line .= qq($gyap_time2);
							$index_line .= qq(</td>);
							$index_line .= qq(</tr>\n);
						}

						# �g�єł̕\��
						elsif($type =~ /Mobile-view/){

							# �w�i�F
							my $background_style_in = qq(background:#eee;) if($data{'hit'} % 2 == 1);

							# �\�����e
							$index_line .= qq(<div style="$background_style_in$main::ktextalign_center_in">);
							$index_line .= qq(<a href="$thread_number2.html">$subject2</a> $mark2);
							$index_line .= qq(<br$main::xclose>$resnum2���X $posthandle2);
							$index_line .= qq(</div>\n);
						}

				# �O���[�v�́h���h���o���Ă���
				$lastroupe_monthf = $monthf2;

			}

	}
	
	# ���y�[�W�߂���p�����N�̐��`
	if($type =~ /Get-index/ && $pagelinks_line && $data{'line_num'} > $maxview_index){
		$data{'pagelinks_line'} .= qq(<div class="pagelinks_pastindex line-height">\n);
		$data{'pagelinks_line'} .= qq(�y�[�W�F \n);
			if($type =~ /Normal-view/){
					if($type =~ /First-page/){ $data{'pagelinks_line'} .= qq(<span style="color:#f00;">�V</span>\n); }
					else{ $data{'pagelinks_line'} .= qq(<a href="past-year-$yearf-all.html">�V</a>\n); }
			}
		$data{'pagelinks_line'} .= qq($pagelinks_line\n);
		$data{'pagelinks_line'} .= qq(</div>\n);
	}

	# �������Ńq�b�g���Ȃ������ꍇ
	if($type =~ /Search-index/ && (!$index_line || $search_keyword eq "")) {
		$data{'index_line'} = qq(<h2$main::kstyle_h2>�h$main::in{'word'}�h�̌������� (0��)</h2>\n�q�b�g���܂���ł����B�L�[���[�h��ς��Č������Ă��������B\n);
	}

	# ���C���f�b�N�X�̐��`
	elsif($type =~ /Get-index/){

			# �\���s������ꍇ�͐��`
			if($index_line){

					# ���o����t����ꍇ
					if($type =~ /Addtion-Hx/){
							if($type =~ /Search-index/){
								$data{'index_line'} .= qq(<h2$main::kstyle_h2>�h$main::in{'word'}�h�̌������� ($data{'hit'}��)</h2>\n);
							}
							elsif($type =~ /Month-view/){
								$data{'index_line'} .= qq(<h2$main::kstyle_h2>$yearf�N$monthf�� ( $data{'i'}�L�� )</h2>\n);
							}
							elsif($type =~ /Year-file/){
								$data{'index_line'} .= qq(<h2$main::kstyle_h2>$yearf�N ( $data{'i'}�L�� )</h2>\n);
							}
							elsif($type =~ /Recentry/){
								$data{'index_line'} .= qq(<h2$main::kstyle_h2>�ŋ߂̉ߋ����O</h2>\n);
							}
					}

				# �f�[�^����
				if($type =~ /Desktop-view/){
					$data{'index_line'} .= qq(<table summary="�ߋ����O�ꗗ" class="past_index">\n);
					#$data{'index_line'} .= qq(<th>�A��</th>);
					$data{'index_line'} .= qq(<tr>);
					$data{'index_line'} .= qq(<th>�薼</th><th>�쐬��</th><th>���X</th><th>�ߋ����O��</th><th>�쐬��</th><th>����</th>\n);
					$data{'index_line'} .= qq(</tr>);
					$data{'index_line'} .= qq($index_line);
					$data{'index_line'} .= qq(</table>\n);
				}

				# �f�[�^����
				elsif($type =~ /Mobile-view/){
					$data{'index_line'} .= qq(<div>\n);
					$data{'index_line'} .= qq($index_line);
					$data{'index_line'} .= qq(</div>\n);
				}

			}
	}



return(%data);

}


#-----------------------------------------------------------
# �P�f��������̑S�N���j���[
#-----------------------------------------------------------
sub PastIndexAll{

# �錾
my($type,$realmoto,$yearf,$monthf) = @_;
my(undef,undef,undef,undef,$new_thread_num) = @_ if($type =~ /New-line|Year-delete/);
my($i,@renew_index,$index_line,$thread_num_all,%years,%self,$last_roupe_yearf);

	# �����`�F�b�N
	if($realmoto =~ /^$|\W/){ return(); }
	if($type =~ /Renew/ && $yearf =~ /\D/){ return(); }

# �t�@�C����`
my $directory1 = "${main::int_dir}_bbs_index/";
my $directory2 = "${directory1}_${realmoto}_index/";
my $file = "${directory2}${realmoto}_allindex.log";

	# �t�@�C�����J��
	my($past_allindex_handler,$read_write) = Mebius::File::read_write($type,$file,$directory1,$directory2);
		if($read_write->{'f'}){ %self = (%self,%$read_write); } else{ return(%self); }

# �g�b�v�f�[�^�𕪉�
chomp(my $top1 = <$past_allindex_handler>);
($self{'key'},$self{'yearfile_num'},$self{'thread_num'},$self{'years'}) = split(/<>/,$top1);

	# �n�b�V�������Ԃ��ꍇ
	if($type =~ /Get-hash-only/){
		close($past_allindex_handler);
		return(%self);
	}

	# �t�@�C����W�J����
	while(<$past_allindex_handler>){

		# ���E���h�J�E���^
		$i++;

		# �s�𕪉�
		chomp;
		my($key2,$yearf2,$thread_num2,$months2) = split(/<>/);

		# �N�ʋL����
		$years{"$yearf2"} = $thread_num2;

		# �S�L�����𐔂���
		$thread_num_all += $thread_num2;

			# ���C���f�b�N�X�擾�p
			if($type =~ /Get-index/){

				if($months2 eq ""){ $self{'please_fix_renew_flag'} = 1; }

				# �N�ʃt�@�C���̃g�b�v�f�[�^���擾
				#my(%year_index) = Mebius::BBS::PastIndex("Get-hash-only Year-file",$realmoto,$yearf2);

					# �N�ʃt�@�C���ɋL�������Ȃ��ꍇ�́A�G�X�P�[�v
					#if($year_index{'thread_num'} <= 0){ next; }

					# �ړ������N��`
					if(!$yearf || $yearf eq $yearf2){

							# �N�y�[�W�ւ̃����N���`
							if($yearf2 eq $yearf && $monthf eq "all"){
								$index_line .= qq(<h2 style="color:#f00;">$yearf2�N ( $thread_num2�L�� )</h2>);
							}
							else{
								$index_line .= qq(<h2><a href="past-year-$yearf2-all.html">$yearf2�N ( $thread_num2�L�� )</a></h2>);
							}


							# ���y�[�W�ւ̃����N���`
							if($type =~ /Months-link/){
									# ���f�[�^��W�J
									foreach(split(/\s/,$months2)){
										my($monthf3,$thread_num3) = split(/=/);
											if($monthf3 eq $monthf && $yearf2 eq $yearf){
												$index_line .= qq( <span style="color:#f00;">$monthf3��</span>\n);
												#( $thread_num3�L�� )
											}
											else{
												$index_line .=  qq( <a href="past-year-$yearf2-$monthf3.html">$monthf3��</a>\n);
												# ( $thread_num3�L�� )
											}
									}
							}
	
						$index_line .= qq(<br$main::xclose>\n);

					}

					# �S�Ă̔N���L��
					if($self{'all_years'}){ $self{'all_years'} .= qq(,$yearf2); }
					else{ $self{'all_years'} = qq($yearf2); }

					# �T�[�`�{�b�N�X�̃��W�I�{�^����s��`
					my($checked_yearf) = $main::parts{'checked'} if($yearf eq $yearf2);
					$self{'input_radio'} .= qq(<input type="radio" name="target" value="$yearf2" id="past_search_year_$yearf2"$checked_yearf$main::xclose>\n);
					$self{'input_radio'} .= qq(<label for="past_search_year_$yearf2">$yearf2�N</label>\n);

			}

			# ���t�@�C���X�V�p
			if($type =~ /Renew/){

				# �N�ʃt�@�C���̃g�b�v�f�[�^���擾
				my(%year_index) = Mebius::BBS::PastIndex("Get-hash-only Year-file",$realmoto,$yearf2);

					# �s���L�^
					if($year_index{'months'}){ $months2 = $year_index{'months'}; }
					if($year_index{'thread_num'} ne ""){ $thread_num2 = $year_index{'thread_num'}; }

					# ���O�s�������Ă���ꍇ
					if($last_roupe_yearf && $last_roupe_yearf - 1 > $yearf2){
						my $push_year = $last_roupe_yearf - 1;
						push(@renew_index,"<>$push_year<><>\n");
					}

				# ���O���A�̂��߂ɁA�s�̔N�x���o���Ă���
				$last_roupe_yearf = $yearf2;

					# ���ɓ��N�̓o�^������ꍇ
					if($type =~ /New-line/ && $yearf2 eq $yearf){ next; }

				# �X�V�s��ǉ�
				push(@renew_index,"$key2<>$yearf2<>$thread_num2<>$months2<>\n");

			}

	}

	# ���C���f�b�N�X�𐮌`
	if($type =~ /Get-index/ && $index_line){
		$self{'index_line'} .= qq();
		$self{'index_line'} .= qq($index_line);
		$self{'index_line'} .= qq();
	}

	# ���t�@�C�����X�V����
	if($type =~ /Renew/){

		# �錾
		my(@years);

			# ���V�����s��ǉ�����ꍇ
			if($type =~ /New-line/){

				# �N�ʃt�@�C���̃g�b�v�f�[�^���擾
				my(%year_index) = Mebius::BBS::PastIndex("Get-hash-only Year-file",$realmoto,$yearf);

				# �V�����s��ǉ�����
				unshift(@renew_index,"<>$yearf<>$new_thread_num<>$year_index{'months'}<>\n");

				# ���E���h�J�E���^ / �S�L�����Ȃǂ𑝂₷
				$i++;
				$thread_num_all += 1;
				$years{"$yearf"} += 1;

			}

		# �N�ʂɃ\�[�g
		@renew_index = sort { (split(/<>/,$b))[1] <=> (split(/<>/,$a))[1] } @renew_index;

			# �g�b�v�f�[�^����
			if($thread_num_all){ $self{'thread_num'} = $thread_num_all; }

			# �N�J�E���g��W�J����
			if(%years){
					foreach(keys %years){
						push(@years,"$_=$years{$_}");
					}
				@years = sort { (split(/=/,$b))[0] <=> (split(/=/,$a))[0] } @years;
				$self{'years'} = "@years";
			}

		# �g�b�v�f�[�^��ǉ�
		unshift(@renew_index,"$self{'key'}<>$i<>$self{'thread_num'}<>$self{'years'}<>\n");

		# �t�@�C���X�V
		Mebius::File::truncate_print($past_allindex_handler,@renew_index);

	}

close($past_allindex_handler);

	# �p�[�~�b�V�����ύX
	if($type =~ /Renew/){	Mebius::Chmod(undef,$file); }

	# �S�f���̈ꗗ���X�V
	if($type =~ /Renew/){
		Mebius::BBS::PastIndexAllBBS("Renew New-line",$realmoto,$main::title,$self{'thread_num'},$self{'years'});
	}


# ���^�[��
return(%self);

}

#-----------------------------------------------------------
# �S�f���̃��X�g
#-----------------------------------------------------------
sub PastIndexAllBBS{

# �錾
my($type,$realmoto) = @_;
my(undef,undef,$title,$thread_num) = @_ if($type =~ /New-line/);
my($allbbs_index_handler,%data,@renew_index,$thread_num_all,$index_line);

	# �����`�F�b�N
	if($type =~ /Renew/ && $realmoto =~ /^$|\W/){ return(); }
	
	# �e�탊�^�[��
	if($realmoto =~ /^(sc|sub)/){ return(); }

# �t�@�C����`
my $directory1 = "${main::int_dir}_bbs_index/";
my $file = "${directory1}allbbs_index.log";

# �t�@�C�����J��
open($allbbs_index_handler,"<$file");

	# �t�@�C�����b�N
	if($type =~ /Renew/){ flock($allbbs_index_handler,1); }

#�g�b�v�f�[�^�𕪉�
chomp(my $top1 = <$allbbs_index_handler>);
($data{'key'},$data{'lasttime'},$data{'thread_num'}) = split(/<>/,$top1);

	# �t�@�C����W�J
	while(<$allbbs_index_handler>){

		# �Ǐ���
		my($all_split);

		# �s�𕪉�
		chomp;
		my($key2,$realmoto2,$title2,$thread_num2,$lasttime2) = split(/<>/);

			# �L�����J�E���^
			$thread_num_all += $thread_num2;

			# �C���f�b�N�X�擾�p
			if($type =~ /Get-index/){

				# �N�ʃt�@�C���̃n�b�V�����擾
				my(%all_index) = Mebius::BBS::PastIndexAll("Get-hash-only",$realmoto2);

				# ��{�����N
				$index_line .= qq(<a href="/_$realmoto2/past.html">$title2</a> ( $thread_num2 )\n);
				$index_line .= qq( - );

					# �N�ʃ����N
					foreach $all_split (split(/\s/,$all_index{'years'})){
						my($yearf3,$thread_num3) = split(/=/,$all_split);
						$index_line .= qq(<a href="/_$realmoto2/past-year-$yearf3-all.html">$yearf3�N</a> ( $thread_num3 )\n);
					}

				$index_line .= qq(<br$main::xclose>\n);

			}

			# ���t�@�C���X�V�p
			if($type =~ /Renew/){

					# �d�������f���̏ꍇ
					if($realmoto2 eq $realmoto){
						next;
					}

				# �X�V�s��ǉ�
				push(@renew_index,"$key2<>$realmoto2<>$title2<>$thread_num2<>$lasttime2<>\n");

			}

	}

close($allbbs_index_handler);

	# ���t�@�C���X�V�p
	if($type =~ /Renew/){

		# �f�B���N�g�����쐬
		Mebius::Mkdir(undef,$directory1);

			# �V�����s��ǉ�
			if($type =~ /New-line/){
				unshift(@renew_index,"<>$realmoto<>$title<>$thread_num<>$main::time<>\n");
				$thread_num_all++;
			}

		# �X�V�s���\�[�g
		@renew_index = sort { (split(/<>/,$b))[3] <=> (split(/<>/,$a))[3] } @renew_index;

		# �g�b�v�f�[�^��ǉ�
		unshift(@renew_index,"$data{'key'}<>$main::time<>$thread_num_all<>\n");

		# �t�@�C�����X�V
		Mebius::Fileout(undef,$file,@renew_index);

	}

	# ���C���f�b�N�X�擾�p
	if($type =~ /Get-index/){

			# �C���f�b�N�X�𐮌`
			if($index_line){

					if($type =~ /Addtion-Hx/){
						$data{'index_line'} .= qq(<h2$main::kstyle_h2>���j���[ ( �S $data{'thread_num'}�L�� )</h2>\n);
					}

				$data{'index_line'} .= qq(<div class="line-height">\n);
				$data{'index_line'} .= qq($index_line\n);
				$data{'index_line'} .= qq(</div>\n);
				$data{'index_line'} .= qq(\n);
			}

	}


return(%data);

}



1;
