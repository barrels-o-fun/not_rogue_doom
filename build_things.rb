#
# Beginnings of the module, one function so far
#
module BuildThings

    # Generates a building and populates static_ x/y arrays
    def BuildThings.build_house ( x, y, house=0, color="green" )
        # Check if x and y match up to grid
        build_err_x=0
        build_err_y=0
        if x % (SPRITE_WIDTH/ERR_TOLERANCE) != 0
          p=0
          while (x+p) % (SPRITE_WIDTH/ERR_TOLERANCE) != 0
            p+=1
          end
          print "Bad-X, increasing by ", p, "\n"
          build_err_x=p
        elsif y % (SPRITE_HEIGHT/ERR_TOLERANCE) != 0
          p=0
          while (y+p) % (SPRITE_HEIGHT/ERR_TOLERANCE) != 0
            p+=1
          end
          print "Bad-Y, increasing by ", p, "\n"
          build_err_y=p
        end
        # Set building sprites - this will eventually have more options!
        case
          when house==0
          bldg_temp = Qt::Image.new "bldg_40x80.png"
          when house==1
            bldg_temp = Qt::Image.new "bldg_80x40.png"
          when house==2
            bldg_temp = Qt::Image.new "bldg_80x160_green.png" if color=="green"
            bldg_temp = Qt::Image.new "bldg_80x160_blue.png" if color=="blue"
            bldg_temp = Qt::Image.new "bldg_80x160_red.png" if color=="red"
        end

        # Logic to populate taken arrays with whole building size
        # Array position X and Y MUST match up for collision code
        p=0
        q=0
        r=$static_x.count
        s=$static_y.count
        while p < bldg_temp.width
          q=0
          while q < bldg_temp.height
            $static_x.push x+build_err_x+p
            print "$static_x: ", $static_x.to_s, "\n" if $debug >= 5
            $static_y.push y+build_err_y+q
            print "$static_y: ", $static_y.to_s, "\n" if $debug >= 5
            q+=SPRITE_HEIGHT/ERR_TOLERANCE
          end
          p+=SPRITE_WIDTH/ERR_TOLERANCE
        end
      $bldgs.push bldg_temp
      return bldg_temp
    end
end
