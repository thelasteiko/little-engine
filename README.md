# little-engine

### The little game engine that could.

This is a basic game engine meant for experimentation and learning. It's overly commented without too many bells and whistles. It probably has some bad habits and is not the most efficient design.

If you want a serious game engine, this is not it. If you want a framework that's easy to play with then you're in the right place.

## Installation

In order to run littleengine you will need:

### Using Gosu

| Software		| Version	|
| -------------	| --------- |
| Ruby			| 2.3.1p112 |
| Gosu			| 0.12.1	|
| freeglut3		| 			|
| freeglut3-dev	|			|
| Texplay		| 0.4.4.pre |

#### Ubuntu
'''bash
sudo apt-get install ruby
sudp apt-get install freeglut3-dev
sudo gem install gosu
sudo gem install texplay -v 0.4.4.pre
'''

### Using fxruby
* Type these commands one at a time:
    gem install fxruby
    gem install opengl
    gem install glu


## Installing Ruby
Ruby versions after 1.9 have gem installed already. Please see the appropriate installation instructions for your system.

https://www.ruby-lang.org/en/downloads/

To put Ruby and Gem into your path variable:

### Windows users

* Start > Control Panel > System > Advanced System Settings > Advanced > Environment Variables
* Look for PATH
* Click on edit and paste the bin file location for your Ruby directory at the end of the value (usually something like "C:\Ruby22\bin").

### Linux

Ruby should be installed in a default bin directory, meaning you should not have to add it
in the PATH environment variable. But in case you have multiple ruby versions or
you want to make double sure....

* Open a terminal
* Go to your home directory if you aren't there already
'''bash
cd /home/USERNAME
'''
* Open a the .bashrc file in your favorite text editor (with super user privileges)
'''bash
sudo vi .bashrc
'''
* Whatever you commands you add to this file will be called when you open a terminal, so let's modify the PATH
'''bash
export PATH=$PATH:/path/to/ruby
'''
* Save the file and set the .bashrc file as the source
'''bash
source .bashrc
'''

## File Descriptions
* littleengine.rb is the fxruby version
* littlegame.rb is the Gosu version
* tester.rb demonstrates how the engine can be used as well as the debugger.
* test2.rb is a simpler test of only the framework without any extensions.
