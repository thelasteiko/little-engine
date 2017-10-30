#!/usr/bin/env ruby

# Little is a small and unassuming game engine based on Gosu.
# All rights go to the Gosu people for the Gosu code.
#
# @author      Melinda Robertson
# @copyright   Copyright (c) 2017 Little, LLC
# @license     GNU

# We'll need SQLite
require 'sqlite3'

# And we need to expand on little game to load the db info
module Little
  class DataManager
    def initialize(dbname)
      @db = SQLite3::Database.new(dbname)
    end
    
    # Utility functions for
    # - retrieving data
    # - adding data
  
  end

end