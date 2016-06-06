require_relative 'littleengine'
require_relative 'v2/littlemenu'

      c = Component.new(:menu, nil, 20, 20, 100, 50)
      puts c
      c2 = Component.new(:menu, c, 0, 0, 35, 20)
      puts c.layout.canAdd?(c2)
      c.add(c2)
      c.show
      
      puts c
      puts c2
      
      c.update
      
