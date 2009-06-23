#!/usr/bin/perl -w
# Time-stamp: <2005/02/18, 10:02:06 (EST), maverick, build.pl>

use strict;

my $e = $ARGV[0] or die "Specify example input file";
my $ee = $e;
$ee =~ s/\\/\\\//g;
print "Using $e as sample input\n";

my $lang = $ARGV[1] or die "Specify a language";
my $suffix = $ARGV[2] or die "Specify a suffix";
my $numleft = $ARGV[3] || -1;
print "Processing $numleft themes\n" if($numleft > 0);

my $date = localtime;
my $htmldir = '../html/';

open IDX, '>' . $htmldir . "index-$suffix.html" 
  or die "Cannot open index-$suffix.html";

# html header
my $title = 'GNU Emacs Color Theme Test';
print IDX <<HEADER
<html>
  <head>
    <title>$title - $lang - $date</title>
    <style>
      body { background: White; }
      a {
        border-top: thin none;
        border-left: thin none;
        border-bottom: thin dotted #FF9900;
        border-right: thin none;
        color: Black;
        text-decoration: none;
      }
      a:hover { color: White; background: #FF9900; }
      a.frames { border: thin dotted #FF9900; }
      a.frames:hover { color: White; background: #FF9900; }
      td { padding-top: 5px; }
    </style>
  </head>
  <body>
    <h1><a href="./index.html">$title</a> - $lang</h1>
    <script language="javascript">
      function changeHeight(h) {
        var tds = document.getElementsByTagName("td");
        for(var i = 0; i < tds.length; i++) { tds[i].setAttribute("height", h + "px"); }
      }
    </script>
    <ul>
    <li>This page really requires a modern web browser. Click <a
      href="./index.html">here</a> for more information.</li>
    <li>Do your friends a favor. Link to the <a href="./index.html">parent page</a>
      instead. Thanks!</li>
    <li>Useful tip: decrease the text size to see more in each <tt>iframe</tt>.
      (For example, in Firefox press ctrl-minus and you will see.)</li>
    <li>Select <tt>iframe</tt> height (in pixels):
    <input type="radio" name="height" value="100" onclick="changeHeight(100);">100</input>
    <input type="radio" name="height" value="200" onclick="changeHeight(200);">200</input>
    <input type="radio" name="height" value="300" onclick="changeHeight(300);" checked>300</input>
    <input type="radio" name="height" value="400" onclick="changeHeight(400);">400</input>
    <input type="radio" name="height" value="500" onclick="changeHeight(500);">500</input>
    <input type="radio" name="height" value="600" onclick="changeHeight(600);">600</input>
    </li>
    </ul>
    <hr>
    <table width="100%" valign="top" cellpadding="0px" cellspacing="1px">
HEADER
;

# emacs specific
print "Generating color theme list...";
system('emacs', '--eval',
       '"(progn (make-color-theme-list) (kill-emacs))"');
print "\n";

# setup column state machine
my $colmax = 3;
my $colstate = 0;
my $colwidth = int(100 / $colmax);

# enumerate colors
my $counter = 0;
my $emacscolorsdir = 'C:/Bin/Emacs/site-lisp';
open D, "color-theme-list.txt"
  or die "Cannot open color-theme-list.txt";
while(my $line = <D>) {

  # extract name
  chomp $line;
  my ($cname, $cfunc) = split(':', $line);

  # skip color themes that I don't want to show
  next if $cname eq 'Maverick\'s Cool Color';

  print $cname;
  my ($cfuncshort) = $cfunc =~ /^color-theme-(.*)$/;
  my $hname = "$cfuncshort-$suffix.html";

  # compute the timestamps
  my $colortime = (stat($emacscolorsdir . '/' . 'color-theme.el'))[9] || 0;
  my $htmltime = (stat($htmldir . $hname))[9] || 0;

  # generate iframe source
  unless ($colortime < $htmltime) { # skip if colorscheme is older than the html
    system('emacs', '--eval',
      '"(progn (' . $cfunc . ') (funcall \'htmlize-file \"' . $e . '\")'
           . ' (kill-emacs))"');
    system('mv', $e . '.html', $htmldir . $hname);
    #system('sed', '-i', 's/>' . $ee . '.html' . '</>' . $cname . '</i', $hname);
  } else {
    print ' [skipped]';
  }

  print "\n";

  # is this the beginning of a row?
  if($colstate == 0) {
    print IDX <<ROW1
      <tr valign="top">
ROW1
;
  }

  # actual html to include iframe
  print IDX <<COL
        <td width="$colwidth%" height="300px">
          $cname<br>
          <iframe src="$hname" frameborder="0" width="100%" height="100%" scrolling="no"></iframe>
        </td>
COL
;
  $counter++;

  # is this the end of a row?
  if($colstate + 1 == $colmax) {
    print IDX <<ROW2
      </tr>
ROW2
;
  }

  # update state machine
  $colstate = ($colstate + 1) % $colmax;

  # quit if we have tested enough colors
  $numleft--;
  last unless $numleft;

}
close D;

# is the last row orphaned?
if($colstate != 0) {
  print IDX <<ROW3
      </tr>
ROW3
;
}

# html footer
print IDX <<FOOTER
    </table>
    <hr>
    <p>Total: $counter themes
    <p>Generated on $date by Maverick Woo</p>
  </body>
</html>
FOOTER
;

close IDX;

# emacs specific
unlink "semantic.cache";
unlink "color-theme-list.txt";
