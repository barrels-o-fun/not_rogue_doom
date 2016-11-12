# The main file for doom rogue blatant ripoff
#  - learning project
#
# Author: Barrels-o-fun
#

# GAME CONSTANTS
WIDTH = 640
HEIGHT = 480
SQUARE_HEIGHT = 20
SQUARE_WIDTH = 10

# Idea - Have multiple arrays (or hashes?) for different objects.
#
# Init global, tracks number of buildings - might not be needed!
$num_bldgs = 0

# Init array for global occupied squares, array grows as more objects are on screen.
$static_x = []
$static_y = []

# $x and $y currently only track player, var may be renamed to increase readability.
$x = []
$y = []

# Init player initial position
$player_x=WIDTH-50
$player_y=HEIGHT-HEIGHT/2
# Check if player is on the SQUARE grid, else place at 0 for offending axis.
if $player_x%SQUARE_WIDTH != 0 
  $player_x=0 
end
if $player_y%SQUARE_HEIGHT != 0 
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
      @bldg1 = build_house( 200, 100 )
      @bldg2 = build_house( WIDTH-140, HEIGHT-120 )

      # This rescue doesn't seem to work - look into at some point? 
      begin
        @marine = Qt::Image.new "marine_lol.png"
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

                painter.drawImage $x[0], $y[0], @marine
                painter.drawImage $static_x[0], $static_y[0], @bldg1
                print "$static_x: ", $static_x.to_s, "\n"
                print "$static_y: ", $static_y.to_s, "\n"
                painter.drawImage $static_x[16], $static_y[16], @bldg2
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
        painter.translate Qt::Point.new w/2, h/2
        painter.drawText -textWidth/2, 0, msg
    end


    # Player moves, do they collide?
    def move
        if @left
            $x[0] -= SQUARE_WIDTH unless $x[0]==0
        end

        if @right 
            $x[0] += SQUARE_WIDTH unless $x[0]==WIDTH-SQUARE_WIDTH
        end

        if @up
            $y[0] -= SQUARE_HEIGHT unless $y[0]==0
        end

        if @down
            $y[0] += SQUARE_HEIGHT unless $y[0]==HEIGHT-SQUARE_HEIGHT
        end

        # collision check, currently against non-hurty static objects (buildings)
        if checkCollision==1
          if @left
              $x[0] += SQUARE_WIDTH
          end

          if @right 
              $x[0] -= SQUARE_WIDTH
          end

          if @up
              $y[0] += SQUARE_HEIGHT
          end

          if @down
              $y[0] -= SQUARE_HEIGHT
          end
        end

        print "Marine-x: ", $x[0], " - Marine-y: ", $y[0], "\n"
    end


    # Checks if players x,y pos matches any other object.
    def checkCollision
        hit=0
        p=0
        while p < $static_x.count
          if $static_x[p]==$x[0]
            puts "HIT X!!!!"
            print "$static_y[", p,"] is", $static_y[p]
            hit=1 if $static_y[p]==$y[0]
          end
          p+=1
        end
           
        p=0
        while p < $static_y.count
          if $static_y[p]==$y[0]
            puts "HIT Y!!!!"
            print "$static_x[", p,"] is", $static_x[p]
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
    def build_house ( x, y, size="default" )
        # Increase size of $bldgs array
        $num_bldgs=+1
        # Count size of bldgs and set id for new building
        bldg_temp = Qt::Image.new "bldg_40x80.png"
        # Logic to populate taken arrays with whole building size
        # Array position X and Y MUST match up for collision code
        p=0
        q=0
        r=$static_x.count
        s=$static_y.count
        while p < bldg_temp.width
          q=0
          while q < bldg_temp.height
            $static_x.push x+p
            print "$static_x: ", $static_x.to_s, "\n"
            $static_y.push y+q
            print "$static_y: ", $static_y.to_s, "\n"
            q+=SQUARE_HEIGHT
          end
          p+=SQUARE_WIDTH 
        end
      return bldg_temp
    end

end
