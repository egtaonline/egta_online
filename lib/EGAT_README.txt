=====
A few things you need to know about running EGAT!
=====

EGAT requires lpsolve 5.5 (http://lpsolve.sourceforge.net/5.5/Java/README.html, google it for more information)
to be installed on the production server. Since lpsolve is a dynamic library written in c (with a java wrapper),
a LD_LIBRARY_PATH or DYLD_LIBRARY_PATH environment variable must be set to the location of the lpsolve dynamic libraries
inside of the egat bash script (bin/egat-0.9-SNAPSHOT/egat) 

Currently, EGTMAS seems to only support symmetric games and profiles, thus the algorithms in egat_interface.rb make the 
general assumption that all games are symmetric. New functions must be written for non-symmetric games, though they can
follow the same general template.  