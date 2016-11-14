#
# Beginnings of the module, one function so far
#
module BuildThings

    # Generates a building and populates static_ x/y arrays
    def BuildThings.build_house ( pos_x, pos_y, color="green", house="default", width=80, height=160 )
        # Check if x and y match up to grid
        build_err_x=0
        build_err_y=0
        if pos_x % (SPRITE_WIDTH/ERR_TOLERANCE) != 0
          p=0
          while (pos_x+p) % (SPRITE_WIDTH/ERR_TOLERANCE) != 0
            p+=1
          end
          print "Bad-X, increasing by ", p, "\n"
          build_err_x=p
        elsif pos_y % (SPRITE_HEIGHT/ERR_TOLERANCE) != 0
          p=0
          while (pos_y+p) % (SPRITE_HEIGHT/ERR_TOLERANCE) != 0
            p+=1
          end
          print "Bad-Y, increasing by ", p, "\n"
          build_err_y=p
        end
        # Set building sprites - this will eventually have more options!
        #
        orientation="verti"
        orientation="horiz" if height > width

        case color
          when "blue"
            pre_bldg_temp = Qt::Image.new "bldg_80x160_blue.png"  if orientation=="verti"
            pre_bldg_temp = Qt::Image.new "bldg_160x80_blue.png" if orientation=="horiz"
          when "red"
            pre_bldg_temp = Qt::Image.new "bldg_80x160_red.png" if orientation=="verti"
            pre_bldg_temp = Qt::Image.new "bldg_160x80_red.png" if orientation=="horiz"
          else
            pre_bldg_temp = Qt::Image.new "bldg_80x160_green.png" if orientation=="verti"
            pre_bldg_temp = Qt::Image.new "bldg_160x80_green.png" if orientation=="horiz"
        end

        case house
          when "default"
            bldg_temp = pre_bldg_temp
          when "custom"
            bldg_temp = pre_bldg_temp.scaled(height, width)
          else
            puts "Bad entry, house fail"
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
            $static_x.push pos_x+build_err_x+p
            print "$static_x: ", $static_x.to_s, "\n" if $debug >= 5
            $static_y.push pos_y+build_err_y+q
            print "$static_y: ", $static_y.to_s, "\n" if $debug >= 5
            q+=SPRITE_HEIGHT/ERR_TOLERANCE
          end
          p+=SPRITE_WIDTH/ERR_TOLERANCE
        end
      $bldgs.push bldg_temp
      return bldg_temp
    end
end
