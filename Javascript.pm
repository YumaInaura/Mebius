
use strict;
package Mebius::Javascript;
use Mebius::Export;

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
sub onload{

my $self = shift;
my $url = shift || return;
my $id_for_click = shift;
my $id_for_view = shift;

$id_for_click = e($id_for_click);
$id_for_view = e($id_for_view);
$url = e($url);

my $javascript = <<"EOM";
<script>
\$(document).ready(function(){
	\$("#$id_for_click").click(function () { 
			\$("#$id_for_view").load("$url");
	});

});
</script>
EOM

$javascript;

}


#-----------------------------------------------------------
# 投稿フォームに入力があったまま移動しようとすると、ダイアログを表示する
#-----------------------------------------------------------
sub before_unload_use_form{

#			return '投稿が完了していません。このまま移動しますか？';


my $return = q(
<script>
$(function(){

	$("form textarea").change(function() {
		$(window).on('beforeunload', function() {
			return '送信が済んでいません。';
		});
	});

	$("input[type=submit]").click(function() {
		$(window).off('beforeunload');
	});
});
</script>
);

$return;

}

#-----------------------------------------------------------
# 投稿フォームの文字数カウントのための
#-----------------------------------------------------------
sub count_character_num{

my $self = shift;

my $javascript = qq(
<script>
<!--
	function count_character_num( str , max_length , counter_id , submit_button_id ) {

var COUNTER = document.getElementById(counter_id);
var SUBMIT = document.getElementById(submit_button_id);
COUNTER.innerHTML = max_length - str.length;

			if(str.length > max_length){
				COUNTER.style.color = "red";
				SUBMIT.disabled = true;
			} else {
				COUNTER.style.color = "black";
				SUBMIT.disabled = false;
			}

	}
// --></script>
);

$javascript;

}

#-----------------------------------------------------------
# いいね のための javascript
#-----------------------------------------------------------
sub push_good{

my $self = shift;
my $form_id = shift;
my($my_account) = Mebius::my_account();

$form_id = e($form_id);

	if(!$my_account->{'login_flag'}){
	#	return();
	}

my $script = qq(
<script>
<!--

var forms = document.getElementById("$form_id");
var action_url = forms.action;
var array = [];
	for (var i = 0; i < forms.length; i++) {
		var elem = forms.elements[i];
			if(forms.elements[i].type == 'hidden'){
				array.push(elem.name + '=' + elem.value);
			}
	}

var form_params = array.join('&');

var good_num = {};
var my_push_count = {};
var done = {};

function push_good(data,target,default_good_num,max_push_count,type) {

var id = target.id;
target.disabled = true;
target.className = 'good_sending';
var target_name = target.name;

	if(max_push_count === 'null'){
		max_push_count = 1;
	}

	if(done[id]){
			if(my_push_count[id] >= 1){
				type = 'cancel';
				target_name = target_name.replace(/_push_/, '_cancel_');
			} else {
				type = 'push';
				target_name = target_name.replace(/_cancel_/, '_push_');
			}
	}

	if(good_num[id] == undefined){
		good_num[id] = default_good_num || 0;
	}

	if(!my_push_count[id]){
		my_push_count[id] = 0;
	}

var send_data_successed = function(event) {

	if(type === 'cancel'){
		good_num[id]--;
		my_push_count[id]--;
	} else {
		good_num[id]++;
		my_push_count[id]++;
	}

target.value = target.value.replace(/([0-9]+)/g, good_num[id]);

		if(type === 'cancel'){
			target.className = 'good';
		} else if(target.value.match(/いいね/)) {
			target.className = 'good_disabled';
		} else {
			target.className = 'bad_disabled';
		}

		if(done[id]){
			done[id] = 0;
		} else {
			done[id] = 1;
		}

		target.disabled = false;

};

	var urlEncodedData = "";

	urlEncodedData += form_params + '&';
	urlEncodedData += target_name + '=1' + '&';
	urlEncodedData += 'escape_error=1' + '&';

	for(name in data) {
		var name = encodeURIComponent(name);
		var value = encodeURIComponent(data[name]);
		urlEncodedData += name + "=" + value + "&";
	}

send_data(action_url,urlEncodedData,send_data_successed);

}
// -->
</script>

);

$script;


}


1;
