
use strict;
package Mebius::Adventure;

#-----------------------------------------------------------
# �A�C�e���V���b�v�y�[�W
#-----------------------------------------------------------
sub ViewItem{

# �錾
my($init) = &Init();
my($init_login) = init_login();
my($head_title,$flag,$item_list);
our($advmy);

# CSS��`
$main::css_text .= qq(
div.sort1{word-spacing:0.50em;}
);

# �A�C�e�����擾
($flag,$item_list) = &SelectItem("LIST Get-index","",$advmy);

# �q�ɂ̃A�C�e�����擾
my($itemstock_list) = &ItemStock("Get-index Allow-edit",undef,$advmy);
if($itemstock_list){ $itemstock_list = qq(<h2 id="STORAGE">�A�C�e���q��</h2>\n$itemstock_list); }

# �y�[�W�^�C�g��
$head_title = qq(�A�C�e���V���b�v);

# �A�C�e���̕��בւ������N
my($sort_link);
my @item_sort = ("=>����","gold=>���z�̒Ⴂ��","atack=>�З͂̍�����");

	# �W�J
	foreach(@item_sort){

		# ����
		my($value,$text) = split(/=>/,$_);
		my($sort_href);

			# �����N�̒��g
			if($value){
				$sort_href = qq(&amp;sort=$value);
			}

			# �I�𒆂̃y�[�W
			if($value eq $main::in{'sort'}){
					if($value){ $head_title .= qq( | $text | $init->{'title'}); }
					else{ $head_title .= qq( | $init->{'title'}); }
				$sort_link .= qq($text\n);
			}
			# ���̃y�[�W
			else{ $sort_link .= qq(<a href="$init->{'script'}?mode=item_shop$sort_href">$text</a>\n); }
	}


# HTML
my $print = qq(
<h1>�A�C�e���V���b�v</h1>
$init_login->{'link_line'}
<div class="sort1">���בւ��F
$sort_link
</div>
<h2>�w������</h2>
<div class="line_height">
���q�l�ցB�A�C�e���̂��l�i�A�i�����A�i���͎����ɂ���ĕϓ�����ꍇ���������܂��B<br>
</div>
$item_list
$itemstock_list

);

Mebius::Template::gzip_and_print_all({ Title => $head_title , BCL => ["�A�C�e��"] },$print);


exit;

}


#-----------------------------------------------------------
# ����𔃂� / ��������
#-----------------------------------------------------------
sub BuyWepon{

# �Ǐ���
my($type) = @_;
my($init) = &Init();
my($init_login) = init_login();
my($hit,$item_id,$item_pass,$message1,$message2);
my($select_item,$item_damage);
my($flag,$list,%renew,$item,$stock,$new_item);
our($advmy);

	# �����^�C�v���`
	if($main::in{'type'} eq "change_item"){ $type .= qq( Change-item); }
	else{ $type .= qq( Buy-item); }

	# �e��G���[
	if($type =~ /Buy-item/ && $main::in{'select_item'} eq ""){ main::error("�A�C�e����I��ł��������B"); }
	if($type =~ /Change-item/ && $main::in{'item_session'} eq ""){ main::error("�A�C�e����I��ł��������B"); }

# �L�����t�@�C�����J��
my($adv) = &File("Password-check",{ InputFileType => $main::in{'file_type'} , id => $main::in{'id'} , my_id => $advmy->{'id'} });

	# ���V�����A�C�e�����w������ꍇ
	if($type =~ /Buy-item/){

		# �A�C�e�����擾
		($flag,$list,$new_item) = &SelectItem("BUY_ACTION",$main::in{'select_item'},$adv);

		# �e��G���[
		if(!$flag) { main::error("���݂��Ȃ��A�C�e���ł��B"); }
		if($new_item->{'item_price'} >= 1 && $adv->{'gold'} < $new_item->{'item_price'}) {
			main::error("����������܂��� $new_item->{'item_price'} G / $adv->{'gold'} G");
		}

		# �E�Ɛ�啐��̃��x������
		my $need_level = int($new_item->{'item_damage'} / 1);
			if($new_item->{'item_job'} && $new_item->{'item_damage'} >= 100 && $need_level > $adv->{'level'} && !$main::alocal_mode){
				main::error("$need_level�܂Ń��x�����グ�Ȃ��Ƃ��̕���͔����܂���B");
			}

			# �������Ă��镐�킪����ꍇ�A�ȑO�̕����q�ɂ�
			if($adv->{'item_name'}){ ItemStock("Renew Add-stock Buy-item",undef,$adv); }

		# �e�풲��
		$renew{'-'}{'gold'} = $new_item->{'item_price'};
		$new_item->{'item_damage_plus'} = "";		# �V�i�Ȃ̂ŋ����l�̓[����

		# ���b�Z�[�W
		if($new_item->{'item_number'} eq "0000"){
			$message1 = qq(������O���܂����B);
				if($adv->{'item_name'}){ $message2 = qq(�u$adv->{'item_name'}�v�͑q�ɂɕۊǂ��܂����B); }
			$new_item->{'item_number'} = $new_item->{'item_name'} = $new_item->{'item_damage'} = $new_item->{'item_concept'} = "";
		}
		else{
			$message1 = qq(�h$new_item->{'item_name'}�h��$new_item->{'item_price'}\G �ōw�����܂����I);
				if($adv->{'item_name'}){ $message2 = qq(�u$adv->{'item_name'}�v�͑q�ɂɕۊǂ��܂����B); }
		}


	}

	# ���A�C�e������������/����ꍇ
	elsif($type =~ /Change-item/){

			# ���A�C�e���𔄂�ꍇ
			if($main::in{'drop_stock'}){

				# �`�F�b�N���J���̏ꍇ
				if(!$main::in{'sell_item_check'}){
					main::error("�����肢��������̂ł��傤���H");
				}

				# �q�ɂ̃A�C�e��ID���Q�b�g�A���̂܂܊Y���A�C�e�����̂Ă�
				($stock) = &ItemStock("Drop-stock Renew Get-hash",$main::in{'item_session'},$adv);

				# �A�C�e�����擾
				($item) = &SelectItem("Get-hash",$stock->{'item_number'});

				# ���p����
				my $sell_price = ($item->{'item_price'}/3);
					# ���틭���l�ɂ���Ĕ��p�l���グ��
					if($stock->{'item_damage_plus'} >= 1 && $item->{'item_damage'} >= 1){
						$sell_price += int($sell_price * (($stock->{'item_damage'}+($stock->{'item_damage_plus'}*3*1.7)) / $item->{'item_damage'}));
					}
				$sell_price = int $sell_price;
				my($sell_price_comma) = Mebius::MultiComma({ Language => $init->{'comma_language'} },[$sell_price]);
				$renew{'+'}{'gold'} = $sell_price;
				$message1 = qq(�q�ɂ́h$stock->{'item_name'}�h�� ${sell_price_comma}G�� ���p���܂����B);

			}

			# ���A�C�e������������ꍇ
			else{

				# �q�ɂ���A�V�����������镐���ID���擾����
				($stock) = &ItemStock("ItemStock Get-hash",$main::in{'item_session'},$adv);
					if($stock->{'item_number'} eq ""){ main::error("���̃A�C�e�� �͑q�ɂɑ��݂��܂���B"); }

				# �q�ɂ���o�����A�C�e���̍ŐV�f�[�^���擾�A���f������ ( item_damage_plus �ȊO )
				($new_item) = &SelectItem("Get-hash",$stock->{'item_number'});
				$new_item->{'item_damage_plus'} = $stock->{'item_damage_plus'};

				# ���̕����q�ɂ� / ���o���������q�ɂ������
				&ItemStock("Renew Add-stock",$main::in{'item_session'},$adv);

				# ���b�Z�[�W��`
				$message1 = qq(�h$new_item->{'item_name'}�h�𑕔����܂����B);
				if($adv->{'item_name'}){ $message2 = qq(�u$adv->{'item_name'}�v�͑q�ɂɕۊǂ��܂����B); }

			}

	}

# �V��������𑕔����� (�L�����f�[�^�ւ̔��f)
$renew{'item_number'} = $new_item->{'item_number'};
$renew{'item_name'} = $new_item->{'item_name'};
$renew{'item_damage'} = $new_item->{'item_damage'};
$renew{'item_job'} = $new_item->{'item_job'};
$renew{'item_damage_plus'} = $new_item->{'item_damage_plus'};
$renew{'item_concept'} = $new_item->{'item_concept'};

# �L�����t�@�C�����X�V
&File("Renew Password-check",{ InputFileType => $main::in{'file_type'} , id => $main::in{'id'} , my_id => $advmy->{'id'} },\%renew);

	# �W�����v
	if(Mebius::alocal_judge()){
		#Mebius::Redirect(undef,"$init->{'script'}?mode=item_shop");
	}


# HTML
my $print = qq(
<h1>$message1</h1>
$init_login->{'link_line'}
<div class="adv_message">
$message2
<div>
<a href="$init->{'script'}?mode=item_shop">���A�C�e���V���b�v�֖߂�</a>
</div>
</div>
$init->{'continue_button'}
</div>
);

# �t�b�^
Mebius::Template::gzip_and_print_all({ RefreshURL => "$init->{'script'}?mode=item_shop" , RefreshSecond => 2 },$print);

exit;

}


#-----------------------------------------------------------
# �A�C�e�����X�g���擾
#-----------------------------------------------------------
sub SelectItem{

# �Ǐ���
my($myaccount) = Mebius::my_account();
my($type,$select_item,$adv) = @_;
my($init) = &Init();
my($flag,$list,@item_list,%return,%item_kind,$FILE1);

# CSS��`
$main::css_text .= qq(
td.gold{text-align:right;}
td.damage{text-align:right;}
td.item_guide{padding-left:0.5em;}
table.itemlist{margin:1em 0em;}
);


# �t�@�C����`
my $file  = "$init->{'adv_dir'}_item_data_adventure/item1.dat";

# �A�C�e���t�@�C�����J��
open($FILE1,"<",$file) || die("Perl Die! Can't open item list file");
	while(<$FILE1>){
		chomp $_;
		my($item_number2,$item_name,$item_damage,$item_price,$item_guide,$item_job,$item_concept2,$salled_num2) = split(/<>/,$_);

			# �A�C�e���̓�d�o�^��h��
			if($item_kind{$item_number2}++){
				close($FILE1);
				main::error("�A�C�e������d�ݒ肳��Ă��܂��B");
			}

		( my $item_price_escape_comma = $item_price) =~ s/,//g;
		push(@item_list,"$item_number2<>$item_name<>$item_damage<>$item_price<>$item_guide<>$item_job<>$item_concept2<>$item_price_escape_comma<>$salled_num2<>\n");

	}
close($FILE1);

	# �A�C�e���̕��ёւ�
	if($type =~ /LIST/){
			if($main::in{'sort'} eq "gold"){ @item_list = sort { (split(/<>/,$a))[7] <=> (split(/<>/,$b))[7] } @item_list; }
			if($main::in{'sort'} eq "atack"){ @item_list = sort { (split(/<>/,$b))[2] <=> (split(/<>/,$a))[2] } @item_list; }
	}

	# �A�C�e���t�@�C�����J��
	foreach(@item_list){

		# �Ǐ���
		chomp;
		my($item_number2,$item_name,$item_damage,$item_price,$item_guide,$item_job,$item_concept2,$item_price_escape_comma2) = split(/<>/);
		my($disabled1,$class1,$myitem_mark);


		# �l�i�̐��` ( �J���}�������Ă���ꍇ���� )
		$item_price =~ s/\D//g;

			# �E�Ƃɂ���Ă͒l�i������
			if($adv->{'jobname'} eq '���\�͎�' && $adv->{'level'} >= 500){ $item_price = int $item_price * 0.85; }
			if($adv->{'jobname'} eq '�����W���[' && $adv->{'level'} >= 1000){ $item_price = int $item_price * 0.75; }

			# ����̃A�C�e��
			if($item_number2 eq $select_item){
				$return{'item_number'} = $item_number2;
				$return{'item_name'} = $item_name;
				$return{'item_damage'} = $item_damage;
				$return{'item_price'} = $item_price;
				$return{'item_guide'} = $item_guide;
				$return{'item_job'} = $item_job;


				$return{'item_concept'} = $item_concept2;

				$flag = 1;
			}

			# ���z�`�F�b�N
			if($item_price >= 1 && $item_price > $adv->{'gold'}){ $class1 = qq( class="disable"); $disabled1 = $main::disabled; }

			# �E�ƌ���A�C�e��
			if($item_job ne ""){
				my($hit);
				foreach(split(/,/,$item_job)){
					if($_ eq $adv->{'jobname'}){ $hit = 1; }
				}
				if(!$hit && $type =~/BUY_ACTION/ && $item_number2 eq $select_item){ main::error("�u$item_name�v�𔃂���̂� $item_job �����ł��B"); }
				if($hit){ $class1 = qq( class="fit"); }
				else{ $class1 = qq( class="def"); $disabled1 = $main::disabled; }
			}

			# ���݁A���̕���𑕔����Ă���ꍇ
			if($item_number2 eq $adv->{'item_number'}){
				$class1 = qq( class="self");
				$disabled1 = $main::disabled;
					# ���̏コ��ɁA��������𔃂����Ƃ����ꍇ
					if($type =~/BUY_ACTION/ && $adv->{'item_number'} eq $select_item){ main::error("���̃A�C�e�� ( $item_name ) �͊��Ɏ����Ă��܂��B"); }
			}

		# �����̏����A�C�e��
		#if($item_number2 eq $advitem){
			#if($type =~/BUY_ACTION/ && $item_number2 eq $select_item){ main::error("���̃A�C�e���͊��Ɏ����Ă��܂��B"); }
			#$class1 = qq( class="self"); $disabled1 = $disabled;
		#}

			# ���C���f�b�N�X���擾
			if($type =~ /Get-index/){

				# �l�i�ɃJ���}��t����
				my($item_price_comma) = Mebius::MultiComma({ Language => $init->{'comma_language'} },[$item_price]);

					# �A�C�e���R���Z�v�g�����ɁA�������̒ǉ�
					if($item_concept2 =~ /Getgold-boost-([0-9\.]+)/){ $item_guide .= qq(�퓬���̊l���S�[���h��$1�{�ɂȂ�܂��B); }
					if($item_concept2 =~ /Getexp-boost-([0-9\.]+)/){ $item_guide .= qq(�퓬���̊l���o���l��$1�{�ɂȂ�܂��B); }
					if($item_concept2 =~ /Anti-assassin/){ $item_guide .= qq(�G�̈ÎE��h���܂��B); }

				$list .= qq(<tr$class1><td><label for="item_$item_number2">);
					if($adv->{'f'}){
						$list .= qq(<input type="radio" name="select_item" value="$item_number2" id="item_$item_number2"$disabled1> );
					}
					if($main::in{'check'}){
						$list .= qq($item_concept2);
					}
				$list .= qq($item_name$myitem_mark</label></td><td class="gold"> $item_price_comma G</td><td class="damage">$item_damage</td><td>$item_job</td><td class="item_guide">$item_guide</td></tr>\n);
			}

	}


# �A�C�e�����X�g
$list = qq(
<table class="itemlist adventure" summary="�A�C�e���ꗗ" class="adventure">
<tr><th>���O</th><th>���i</th><th>�З�</th><th>�E�ƌ���</th><th>����</th></tr>
$list
</table>
);

	# ���O�C�����̏ꍇ�A�w���{�^����\��
	if($adv->{'f'}){

			# �������\��
			my($adv_gold_comma) = Mebius::MultiComma({ Language => $init->{'comma_language'} } , [$adv->{'gold'}]);

			# �A�C�e���_���[�W�\��
			my($item_damage_all);
			if(!$adv->{'item_number'}){}
			elsif($adv->{'item_damage_plus'}){ $item_damage_all = qq($adv->{'item_damage'} + $adv->{'item_damage_plus'}); }
			else{ $item_damage_all = qq($adv->{'item_damage'}); }

		$list = qq(
		<form action="$init->{'script'}" method="post" class="buy_item"$main::sikibetu>
		<div>
		���w���̍ۂ́A�����߂̃A�C�e���Ƀ`�F�b�N������ <input type="submit" value="���̃A�C�e���𔃂�"> �������Ă��������B
		<br$main::xclose>
		<br$main::xclose>

		<span class="goldcolor"> ���Ȃ��̏������F $adv_gold_comma G</span> / ���Ȃ��̕���F $adv->{'item_name'} ($item_damage_all)
		$list
		<input type="hidden" name="id" value="$adv->{'id'}">
		<input type="hidden" name="file_type" value="$adv->{'input_file_type'}">
		<input type="hidden" name="char" value="$adv->{'char'}">
		<input type="hidden" name="mode" value="item_buy">
		<input type="submit" value="���̃A�C�e���𔃂�" class="isubmit">
		</div>
		</form>
		);
	}

	# �n�b�V���݂̂�Ԃ��ꍇ
	if($type =~ /Get-hash/){
		return(\%return);
	}

	# ���^�[��
	else{
		return($flag,$list,\%return);
	}

}

#-----------------------------------------------------------
# �A�C�e���q��
#-----------------------------------------------------------
sub ItemStock{

# �錾
my($type,$item_session,$adv) = @_;
my(%type); foreach(split(/\s/,$type)){ $type{$_} = 1; } # �����^�C�v��W�J
my($init) = &Init();
my($stock_handler,@renewline,$index_line,$i,$directory,%data);
our($advmy);

	# �A�J�E���g������
	if(Mebius::Auth::AccountName(undef,$adv->{'id'})){ return(); }

	# �t�@�C�����J�� (�V)
	if($type{'Old-file'}){
		$data{'file'} = "$init->{'adv_dir'}_charadata_itemstock/$adv->{'id'}_itemstock.log";
	}
	# �t�@�C�����J�� (��)
	else{
		$data{'file'} = "$adv->{'directory'}$adv->{'id'}_itemstock.log";
	}

	# �t�@�C�����J��
	if($type{'File-check-error'}){
		$data{'f'} = open($stock_handler,"+<$data{'file'}") || main::error("�t�@�C�������݂��܂���B");
	}
	else{
		$data{'f'} = open($stock_handler,"+<$data{'file'}");

			# �t�@�C�������݂��Ȃ��ꍇ�͐V�K�쐬
			if(!$data{'f'} && $type{'Renew'}){
				Mebius::Fileout("Allow-empty",$data{'file'});
				$data{'f'} = open($stock_handler,"+<$data{'file'}");
			}

	}

	# �t�@�C�����b�N
	if($type =~ /Renew/){ flock($stock_handler,2); }

	# �g�b�v�f�[�^�𕪉�
	chomp(my $top1 = <$stock_handler>);
	my($tkey) = split(/<>/,$top1);

	# �t�@�C����W�J
	while(<$stock_handler>){

		# ���E���h�J�E���^
		$i++;

		# ���̍s�𕪉�
		chomp;
		my($item_session2,$item_number2,$item_name2,$item_damage2,$item_job2,$item_damage_plus2,$item_concept2) = split(/<>/);

			# �q�ɂ������ς��̏ꍇ
			if($type =~ /Buy-item/ && $i >= 200){
				close($stock_handler);
				main::error("�q�ɂ������ς��ł������₹�܂���B�ǂꂩ���̂ĂĂ��������B");
			}

			# �����t���ւ���ꍇ
			if($type =~ /Get-hash/){
					if($item_session eq $item_session2){
						$data{'item_number'} = $item_number2;
						$data{'item_name'} = $item_name2;
						$data{'item_damage'} = $item_damage2;
						$data{'item_job'} = $item_job2;
						$data{'item_damage_plus'} = $item_damage_plus2;
						$data{'item_concept'} = $item_concept2;
					}
			}

			# �A�C�e������������ꍇ
			if($type =~ /Add-stock/){
					if($item_session eq $item_session2){ next; }
					#if("$adv->{'item_number'}>$adv->{'item_name'}>$adv->{'item_damage'}" eq "$item_number2>$item_name2>$item_damage2"){ next; }	# ��������͑��₳�Ȃ�
			}

			# �A�C�e���𔄂�ꍇ
			if($type =~ /Drop-stock/ && $item_session2 eq $item_session){
				next;
			}

			# �X�V�s��ǉ�
			if($type =~ /Renew/){
				push(@renewline,"$item_session2<>$item_number2<>$item_name2<>$item_damage2<>$item_job2<>$item_damage_plus2<>$item_concept2<>\n");
			}

			# �C���f�b�N�X�\�����擾
			if($type =~ /Get-index/){

				my($edit_input) = qq(<input type="radio" name="item_session" value="$item_session2" id="stock_$item_session2">) if($type =~ /Allow-edit/);
				$index_line .= qq(<tr><td>$edit_input);
				$index_line .= qq(<label for="stock_$item_session2"> $i�D$item_name2);
				$index_line .= qq(</label></td>);
				$index_line .= qq(<td>�З� $item_damage2);
					if($item_damage_plus2){ $index_line .= qq( + $item_damage_plus2); }
				$index_line .= qq(</td></tr>\n);
			}

	}

		# ���t�@�C���X�V
		if($type =~ /Renew/){

				# �A�C�e����q�ɂɒǉ�����ꍇ
				if($type =~ /Add-stock/ && $adv->{'item_name'}){

					my($item_session) = Mebius::Crypt::char(undef,30);

					# �V�����ǉ�����s
	unshift(@renewline,"$item_session<>$adv->{'item_number'}<>$adv->{'item_name'}<>$adv->{'item_damage'}<>$adv->{'item_job'}<>$adv->{'item_damage_plus'}<>$adv->{'item_concept'}<>\n");
				}

				# �g�b�v�f�[�^��ǉ�
				if($tkey eq ""){ $tkey = 1; }
			unshift(@renewline,"$tkey<>\n");

			# �X�V
			seek($stock_handler,0,0);
			truncate($stock_handler,tell($stock_handler));
			print $stock_handler @renewline;

		}

# �t�@�C�������
close($stock_handler);

	# �p�[�~�b�V�����ύX
	if($type{'Renew'}){
		Mebius::Chmod(undef,$data{'file'});
	}


	# �C���f�b�N�X��Ԃ�
	if($type =~ /Get-index/){

		if($index_line){ $index_line = qq(<table summary="�q�ɂ̃A�C�e��" class="adventure">$index_line</table>); }
	
		if($index_line && $type =~ /Allow-edit/){
			$index_line = qq(
				<form action="$init->{'script'}" method="post"$main::sikibetu>
				<div>
				<input type="hidden" name="mode" value="item_buy"$main::xclose>
				<input type="hidden" name="type" value="change_item"$main::xclose>
				<input type="hidden" name="id" value="$advmy->{'id'}"$main::xclose>
				<input type="hidden" name="file_type" value="$advmy->{'input_file_type'}">
				<input type="hidden" name="char" value="$advmy->{'char'}">
				$index_line
				<input type="submit" value="�A�C�e������������" class="isubmit"$main::xclose>
				�@
				<input type="submit" name="drop_stock" value="�A�C�e���𔄂�" class="isubmit"$main::xclose>
				<label>
				<input type="checkbox" name="sell_item_check" value="1"$main::xclose>
				���́A���p���i���ɂ͈�؂ً̈c�������Ȃ����Ƃɓ��ӂ��A�M�X�ɖ{�A�C�e���𔄋p�������܂��B
			</label>
				</div>
				</form>
				);
		}

		return($index_line);
	}


	# �n�b�V����Ԃ�
	if($type =~ /Get-hash/){
		return(\%data);
	}

}

1;
