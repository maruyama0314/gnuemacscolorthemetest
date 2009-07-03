perl build.pl samples/sms.c "C" "c"
perl build.pl samples/hl-line.el "Emacs Lisp" "el"
perl build.pl samples/GetEnv.java "Java" "java"
perl build.pl samples/test.tex "LaTeX" "tex"
perl build.pl samples/csvformat.pl "Perl" "pl"

svn add --force ..\html
svn ps svn:mime-type text/html ..\html\*.html

dir ..\html\*-c.html | tail -n 3
dir ..\html\*-el.html | tail -n 3
dir ..\html\*-java.html | tail -n 3
dir ..\html\*-tex.html | tail -n 3
dir ..\html\*-pl.html | tail -n 3
