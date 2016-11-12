# The main file for doom rogue blatant ripoff
#  - learning project
#
# Author: Barrels-o-fun

WIDTH = 640
HEIGHT = 480
SQUARE_HEIGHT = 20
SQUARE_WIDTH = 10
ALL_SQUARES = WIDTH * HEIGHT / (SQUARE_HEIGHT * SQUARE_WIDTH)

# Idea - Have multiple arrays (or hashes?) for different objects.
$bldgs = []

# global occupied squares will contain all possible squares
$taken_x = [0] * ALL_SQUARES
$taken_y = [0] * ALL_SQUARES

$x = []
$y = []
$player_x=WIDTH-50
$player_y=HEIGHT-HEIGHT/2
# Check if player is on the grid, else put it top of screen
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
         
        @left = false
        @right = false
        @up = false
        @down = false
        @inGame = true
        @dots = 0
      
        build_house( 2, 100, 200 )
        # This rescue doesn't seem to work - look into at some point? 
        begin
            @marine = Qt::Image.new "marine_lol.png"
            @bldg1 = Qt::Image.new "bldg_40x80.png"
        rescue
            puts "cannot load images"
        end

        # Place all objects in space
        $x[0]=$player_x
        $y[0]=$player_y
        $taken_x[0]=100
        $taken_y[0]=200
        setStyleSheet "QWidget { background-color: #000000 }"
       
   
    # Might be useful
    #    @timer = Qt::BasicTimer.new 
    #    @timer.start(500, self)
        
    end


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

    def drawObjects painter

                painter.drawImage $x[0], $y[0], @marine
                painter.drawImage $taken_x[0], $taken_y[0], @bldg1
    end

    # Keeping this for now
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


    def checkCollision
        hit=0
        hit_x=0
        hit_y=0
        $taken_x.each { |i| hit_x=1 if $x[0]==i }
        $taken_y.each { |i| hit_y=1 if $y[0]==i }
        if hit_x==1 && hit_y==1
          puts "hit!"
          hit=1
        end
       
         return hit
    end




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

    def build_house ( id, x, y, size="default" )
      # Check existing size of $bldgs array, to ensure we don't overwrite
      # This assumes ids are coming in sequentially, this is not forced at the moment, so really only good for testing at this point.
      if $bldgs.count >= id
        puts "bad choice"
      else 
     
      # Using @bldg2 for now, eventually, I want to dynamically create bldg vars, or have some way of iterating over all building objects for "painting" 
      @bldg2 = Qt::Image.new "bldg_40x80.png"
      $taken_x[id]=x
      $taken_y[id]=y
      end
    end

end
