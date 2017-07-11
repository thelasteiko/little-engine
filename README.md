# little-engine
### The little game engine that could.

This is a basic game engine meant for experimentation and learning. It's overly commented without too many bells and whistles. It probably has some bad habits and is not the most efficient design.

If you want a serious game engine, this is not it. If you want a framework that's easy to play with then you're in the right place.

As a note, this is made specifically for Windows users. The reason for this is because I've found plenty of resources for Linux and iOS but almost nothing for working with Ruby on Windows. Deal with it.

## Installation

In order to run littleengine you will need:

* The latest Ruby for your system. This framework was designed using Ruby 2.2.4.23 on Windows 7.
* Setup Ruby so that gem is installed and Ruby and gem are in your path variable. (see below if you don't know how)
* Open the command line. (cmd.exe)
* Type these commands one at a time:
    gem install fxruby
    gem install opengl
    gem install glu
* Test it out.

## Installing Ruby
Ruby versions after 1.9 have gem installed already. Please see the appropriate installation instructions for your system.

https://www.ruby-lang.org/en/downloads/

To put Ruby and Gem into your path variable (Windows users) go to:

* Start > Control Panel > System > Advanced System Settings > Advanced > Environment Variables
* Under user variables you may see Path. If it's not there add it.
* Click on edit and paste the bin file location for your Ruby directory at the end of the value (usually something like "C:\Ruby22\bin").

## File Descriptions
* littleengine.rb is the game engine framework itself.
* tester.rb demonstrates how the engine can be used as well as the debugger.
* test2.rb is a simpler test of only the framework without any extensions.
