# The main file for doom rogue blatant ripoff
#  - learning project
#
# Author: Barrels-o-fun
#

# GAME CONSTANTS
WIDTH = 640
HEIGHT = 480
# SPRITE_HEIGHT = 20
# SPRITE_WIDTH = 10
PLAYER_SPRITE= "marine_lolx2.png"

# Error tolerance, the larger the number, the larger the arrays for collision
# ... but, the world objects (buildings etc.) can be more varied in placement
# Increasing this, increases chance of sprite going over objects
ERR_TOLERANCE=2


# Check game characters height/width
@marine = Qt::Image.new PLAYER_SPRITE
SPRITE_HEIGHT = @marine.height
SPRITE_WIDTH = @marine.width
# Set how much player moves, higher numbers, smaller movements
PLAYER_MOVE_TOLERANCE=1
PLAYER_MOVE_X = SPRITE_WIDTH / PLAYER_MOVE_TOLERANCE
PLAYER_MOVE_Y = SPRITE_HEIGHT / PLAYER_MOVE_TOLERANCE / 2

# Debug
$debug=0

# Idea - Have multiple arrays (or hashes?) for different objects.
#
# Init global, tracks number of buildings - might not be needed!
$bldgs = []

# Init array for global occupied squares, array grows as more objects are on screen.
$static_x = []
$static_y = []

# $x and $y currently only track player, var may be renamed to increase readability.
$x = []
$y = []

# Init player initial position
$player_x=WIDTH-60
$player_y=HEIGHT-HEIGHT/ERR_TOLERANCE
# Check if player is on the SQUARE grid, else place at 0 for offending axis.
if $player_x%SPRITE_WIDTH != 0 
  $player_x=0 
end
if $player_y%SPRITE_HEIGHT != 0 
  $player_y=0 
end

class Board < Qt::Widget

  
    def initialize(parent)
      super(parent)
        
      setFocusPolicy Qt::StrongFocus
      
      initGame
    end


    def initGame
     
      # Set background colour 
      setStyleSheet "QWidget { background-color: #000000 }"

      # Initialize main game attributes    
      @left = false
      @right = false
      @up = false
      @down = false
      @inGame = true
     
      # Building my houses outside of begin/end loop (it was there from nibbles.. 
      @bldg1 = build_house( 120, 120 )
      @bldg2 = build_house( WIDTH-140, HEIGHT-120 )
      @bldg3 = build_house( 200, 280 )
      @bldg4 = build_house( 300, 248, 1 )
      @bldg5 = build_house( WIDTH-20, HEIGHT-100 )

      

      # This rescue doesn't seem to work - look into at some point? 
      begin
        @marine = Qt::Image.new PLAYER_SPRITE
      rescue
        puts "cannot load images"
      end

      # Place player in space
      $x[0]=$player_x
      $y[0]=$player_y
       
   
      # Might be useful if I want things moving even when player is not
      #    @timer = Qt::BasicTimer.new 
      #    @timer.start(500, self)
        
    end


    # Simply check if we are @ingame or not.
    def paintEvent event

        painter = Qt::Painter.new
        painter.begin self

        if @inGame
            drawObjects painter
        else 
            gameOver painter
        end

        painter.end
    end


    # Here we draw the objects, currently the arrays are manually set for
    # marine and two buildings.
    def drawObjects painter


        # Paint buildings
        p=0
        q=0
        while p < $bldgs.count
          painter.drawImage $static_x[q], $static_y[q], $bldgs[p] unless $bldgs[p]==nil
          # Due to the way we store collison data, this logic ensures each building
          # is placed in the right place
          q+=($bldgs[p].width/(SPRITE_WIDTH/ERR_TOLERANCE))*($bldgs[p].height/(SPRITE_HEIGHT/ERR_TOLERANCE))
          p+=1
        end  

                painter.drawImage $x[0], $y[0], @marine
                print "$static_x: ", $static_x.to_s, "\n" if $debug > 2
                print "$static_y: ", $static_y.to_s, "\n" if $debug > 2 
    end


    # Keeping this for now - game over screen
    def gameOver painter
        msg = "Game Over"
        small = Qt::Font.new "Helvetica", 12,
            Qt::Font::Bold.value
        
        metr = Qt::FontMetrics.new small
        
        textWidth = metr.width msg
        h = height
        w = width

        painter.setPen Qt::Color.new Qt::white
        painter.setFont small
        painter.translate Qt::Point.new w/ERR_TOLERANCE, h/2
        painter.drawText -textWidth/ERR_TOLERANCE, 0, msg
    end


    # Player moves, do they collide?
    def move
        if @left
            $x[0] -= PLAYER_MOVE_X  unless $x[0]==0
        end

        if @right 
            $x[0] += PLAYER_MOVE_X  unless $x[0]==WIDTH-SPRITE_WIDTH
        end

        if @up
            $y[0] -= PLAYER_MOVE_Y  unless $y[0]==0
        end

        if @down
            $y[0] += PLAYER_MOVE_Y  unless $y[0]==HEIGHT-SPRITE_HEIGHT
        end

        # collision check, currently against non-hurty static objects (buildings)
        if checkCollision==1
          if @left
              $x[0] += PLAYER_MOVE_X
          end

          if @right 
              $x[0] -= PLAYER_MOVE_X
          end

          if @up
              $y[0] += PLAYER_MOVE_Y
          end

          if @down
              $y[0] -= PLAYER_MOVE_Y 
          end
        end

        print "Marine-x: ", $x[0], " - Marine-y: ", $y[0], "\n"
    end


    # Checks if players x,y pos matches any other object.
    # We add (SPRITE_x / 2) to check the MIDDLE of the sprite
    def checkCollision
        hit=0
        p=0
        while p < $static_x.count
          if $static_x[p]==($x[0] +( SPRITE_WIDTH / 2 ) )
            print "HIT X! \n"  if $debug >1
            print "$static_y[", p,"] is ", $static_y[p], "\n" if $debug > 2
            hit=1 if $static_y[p]==$y[0]
          end
          p+=1
        end
           
        p=0
        while p < $static_y.count
          if $static_y[p]==($y[0] + (  SPRITE_HEIGHT / 2 ) )
            print "HIT Y! \n" if $debug >1
            print "$static_x[", p,"] is ", $static_x[p], "\n" if $debug > 2
            hit=1 if $static_x[p]==$x[0]
          end
          p+=1
        end
        if hit==1
          puts "hit!"
          hit=1
        end
       
         return hit
    end


    # Player has inputted someting, what was it?
    def keyPressEvent event
        
        key = event.key
        
        print "\n\n\n" if $debug > 0 
        if key == Qt::Key_Left.value
            @left = true
            @right = false
            @up = false
            @down = false
            move
        end
        
        if key == Qt::Key_Right.value
            @left = false
            @right = true
            @up = false
            @down = false
            move
        end
        
        if key == Qt::Key_Up.value
            @left = false
            @right = false
            @up = true
            @down = false
            move
        end
        
        if key == Qt::Key_Down.value
            @left = false
            @right = false
            @up = false
            @down = true
            move
        end
        repaint
    end


    # Function to place a building (one image only atm), and then populate the x/y arrays to ensure player stops!
    # I expect I will move this to another file at some point
    def build_house ( x, y, house=0 )
        $build_err_x=0
        $build_err_y=0
        if x % (SPRITE_WIDTH/ERR_TOLERANCE) != 0
          p=0
          while (x+p) % (SPRITE_WIDTH/ERR_TOLERANCE) != 0
            p+=1
          end
          print "Bad-X, increasing by ", p, "\n"
          $build_err_x=p
        elsif y % (SPRITE_HEIGHT/ERR_TOLERANCE) != 0
          p=0
          while (y+p) % (SPRITE_HEIGHT/ERR_TOLERANCE) != 0
            p+=1
          end
          print "Bad-Y, increasing by ", p, "\n"
          $build_err_y=p
        end
        # Set building sprite - this will eventually have more options!
        if house==1
          bldg_temp = Qt::Image.new "bldg_80x40.png"
        else
          bldg_temp = Qt::Image.new "bldg_40x80.png"
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
            $static_x.push x+$build_err_x+p
            print "$static_x: ", $static_x.to_s, "\n" if $debug >= 5
            $static_y.push y+$build_err_y+q
            print "$static_y: ", $static_y.to_s, "\n" if $debug >= 5
            q+=SPRITE_HEIGHT/ERR_TOLERANCE
          end
          p+=SPRITE_WIDTH/ERR_TOLERANCE
        end
      $bldgs.push bldg_temp
      return bldg_temp
    end

end
