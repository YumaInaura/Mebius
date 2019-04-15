
package Mebius::Tag;
use strict;

#-----------------------------------------------------------
# ƒ^ƒO‚Ì®Œ`
#-----------------------------------------------------------
sub FixTag{

# éŒ¾
my($type,$tag) = @_;

$tag =~ s/&#39;/f/g;

$tag =~ s/@/ /g;
$tag =~ s/([ ]+)/ /g;
$tag =~ s/^\ //g;
$tag =~ s/\ $//g;
$tag =~ s/\-/]/g;
$tag =~ s/\//^/g;
$tag =~ s/\+/{/g;
$tag =~ s/\#/”/g;
$tag =~ s/\!/I/g;
$tag =~ s/\?/H/g;
$tag =~ s/\(/i/g;
$tag =~ s/\)/j/g;

$tag =~ s/&amp;/•/g;
$tag =~ s/&quot;/h/g;
$tag =~ s/&apos;/f/g;
$tag =~ s/&lt;/ƒ/g;
$tag =~ s/&gt;/„/g;

$tag =~ s/<br>//g;

$tag =~ s/‚P/1/g;
$tag =~ s/‚Q/2/g;
$tag =~ s/‚R/3/g;
$tag =~ s/‚S/4/g;
$tag =~ s/‚T/5/g;
$tag =~ s/‚U/6/g;
$tag =~ s/‚V/7/g;
$tag =~ s/‚W/8/g;
$tag =~ s/‚X/9/g;
$tag =~ s/‚O/0/g;

return($tag);

}

1;
