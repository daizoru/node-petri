My god installation of SimSparl on Mac OSX is just crazy..
it's a version hell (ruby, opengl, SDL, even Boost..)
actually I haven't managed to fully install it 

TODO write down a tutorial or something. here a lame compilation of instructions I found on the web:

    $ brew install devil
    $ brew install freetype
    $ brew install sdl
    $ brew install jpeg
    $ brew-install ode

    $ brew tap homebrew/versions
    $ brew install boost149


Then symlink 

    /usr/local/Cellar/boost149/1.49.0/include 

 to

    /usr/local/include/boost

then at compile it ask to export BOOST_FOOBAR (I don't remember the name), so just do it

Then do:

    svn co https://simspark.svn.sourceforge.net/svnroot/simspark simspark

Then (wtf) do:

Modify simspark/trunk/spark/lib/zeitgeist/scriptserver/scriptserver.cpp and 
replace the following line (should be 611 or so):

     pkgdatadir += "Contents/Resources/";

to

     pkgdatadir += "../share/simspark/";


Then at the project root: 

    mkdir build
    cd build
    cmake ..
    make
    make install

you should not need SUDO if you are using homebrew


then the imageperceptor will fail to compile. 

I'm still stuck here.... it is related to GL EXT or something?