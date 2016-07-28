#!/usr/bin/env ruby

require 'fox16'
require 'fox16/keys'
require_relative 'littleanim'
include Fox

# Class that the moves.
class Mover < GameObject
  attr_accessor :x
  attr_accessor :y
  def initialize (game, group, x=0, y=0)
    super(game, group)
    @x = x
    @y = y
  end
  def move (args)
  end
end