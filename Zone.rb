# The main file for doom rogue blatant ripoff
#  - learning project
#
# Author: Barrels-o-fun
#

require_relative 'build_things'

# GAME CONSTANTS
WIDTH = 640
HEIGHT = 480
# SPRITE_HEIGHT = 20
# SPRITE_WIDTH = 10
$player_sprite_left= "marine_lolx2_left.png"
$player_sprite_right= "marine_lolx2_right.png"
$player_sprite_up= "marine_lolx2_up.png"
$player_sprite_down= "marine_lolx2_down.png"
$pewpew_sprite_left = "pewpew_left.png"
$pewpew_sprite_right = "pewpew_right.png"
$pewpew_sprite_up = "pewpew_up.png"
$pewpew_sprite_down = "pewpew_down.png"

# Error tolerance, the larger the number, the larger the arrays for collision
# ... but, the world objects (buildings etc.) can be more varied in placement
ERR_TOLERANCE=2


# Check game characters height/width
@marine = Qt::Image.new $player_sprite_left
SPRITE_HEIGHT = @marine.height
SPRITE_WIDTH = @marine.width
# Set how much player moves, higher numbers, smaller movements
PLAYER_MOVE_TOLERANCE=1
PLAYER_MOVE_X = SPRITE_WIDTH / PLAYER_MOVE_TOLERANCE / 2
PLAYER_MOVE_Y = SPRITE_HEIGHT / PLAYER_MOVE_TOLERANCE / 2

# Debug
$diagnostics=1
$debug=3

# Idea - Have multiple arrays (or hashes?) for different objects.
#
# Init global, stores Images and tracks number of buildings
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

# Init beasty initial position
$beasty_x=20
$beasty_y=40

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
      @shoot = false
      @shoot_dir = false
      @inGame = true
     
      # Building my houses outside of begin/end loop (it was there from nibbles.. 
      @bldg1 = BuildThings.build_house( 40, 40, 2, "green" )
      @bldg2 = BuildThings.build_house( WIDTH-140, HEIGHT-120, 2, "red")
      @bldg3 = BuildThings.build_house( 200, 280, 2)
      @bldg4 = BuildThings.build_house( 300, 248, 2, "blue" )
#      @bldg5 = BuildThings.build_house( WIDTH-20, HEIGHT-100 )
      

      

      # This rescue doesn't seem to work - look into at some point? 
      # Paint images must be in initGame for game to function.
      begin
        @marine = Qt::Image.new $player_sprite_left
        @pewpew = Qt::Image.new $pewpew_sprite_left
      rescue
        puts "cannot load images"
      end

      # Place player in space
      $x[0]=$player_x
      $y[0]=$player_y

      # Place beasty in space
      $x[2]=$beasty_x
      $y[2]=$beasty_y
       
      # Adding beasty here for now
        @beasty = Qt::Image.new "beasty_lol.png"

      @timer = Qt::BasicTimer.new 
      @timer.start(30, self)
   
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

    # Keeps things moving even when player is not
    def timerEvent event

        if @shoot == true
           if checkCollision(1)==1
           @shoot = false
           end
        else 
            @timer.stop
        end
 
        repaint
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

            if @beasty != nil
                painter.drawImage $x[2], $y[2], @beasty
            end
                
            if @shoot==true
                puts "shooting"
                painter.drawImage $x[1], $y[1], @pewpew
            end
                print "$static_x: ", $static_x.to_s, "\n" if $debug > 2
                print "$static_y: ", $static_y.to_s, "\n" if $debug > 2 

        
      # Shooting logic, make sure the bullet goes the right way!
      if @shoot==true
        if @shoot_dir=="left"
          $x[1]-=SPRITE_WIDTH
        elsif @shoot_dir=="right"
          $x[1]+=SPRITE_WIDTH
        elsif @shoot_dir=="up"
          $y[1]-=( SPRITE_HEIGHT / 2 )
        elsif @shoot_dir=="down"
          $y[1]+=( SPRITE_HEIGHT / 2 )
        end
      end  
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
        # Player Moves
        if @left
            $x[0] -= PLAYER_MOVE_X  unless $x[0]==0
            @shoot_dir="left" unless @shoot==true
            @marine = Qt::Image.new $player_sprite_left
            
        end

        if @right 
            $x[0] += PLAYER_MOVE_X  unless $x[0]==WIDTH-SPRITE_WIDTH
            @shoot_dir="right" unless @shoot==true 
            @marine = Qt::Image.new $player_sprite_right
        end

        if @up
            $y[0] -= PLAYER_MOVE_Y  unless $y[0]==0
            @shoot_dir="up" unless @shoot==true
            @marine = Qt::Image.new $player_sprite_up
        end

        if @down
            $y[0] += PLAYER_MOVE_Y  unless $y[0]==HEIGHT-SPRITE_HEIGHT
            @shoot_dir="down" unless @shoot==true
            @marine = Qt::Image.new $player_sprite_down
        end

        # collision check, currently against non-hurty static objects (buildings)
        if checkCollision(0)==1
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

       # Move beasty (random direction)
         beast_move=rand(8)
          puts beast_move
          case beast_move
            when (1..2)
              $x[2] += PLAYER_MOVE_X unless $x[2] > ( WIDTH - ( SPRITE_WIDTH * 1.5 ) ) 
              $x[2] -= PLAYER_MOVE_X if checkCollision(2)==1
            when (3..4)
              $x[2] -= PLAYER_MOVE_X unless $x[2] < ( SPRITE_WIDTH / 1 )
              $x[2] += PLAYER_MOVE_X if checkCollision(2)==1
            when (5..6)
              $y[2] += PLAYER_MOVE_Y unless $y[2] > ( HEIGHT - ( SPRITE_HEIGHT * 1.5 ) )
              $x[2] -= PLAYER_MOVE_Y if checkCollision(2)==1
            when (7..8)
              $y[2] -= PLAYER_MOVE_Y unless $y[2] < ( SPRITE_HEIGHT / 2 )
              $x[2] += PLAYER_MOVE_Y if checkCollision(2)==1
          end
          
        
       # Diagnostics
      print "Marine-x: ", $x[0], " - Marine-y: ", $y[0], "\n" if $diagnostics==1
      print "Beasty-x: ", $x[2], " - Beasty-y: ", $y[2], "\n" if $diagnostics==1
    end


    # Checks if players x,y pos matches any other object.
    # We add (SPRITE_x / 2) to check the MIDDLE of the sprite
    def checkCollision(x=0)
        hit=0
        p=0
        while p < $static_x.count
          if $static_x[p]==($x[x] +( SPRITE_WIDTH / 2 ) )
            print "HIT X! \n"  if $debug >5
            print "$static_y[", p,"] is ", $static_y[p], "\n" if $debug > 5
            hit=1 if $static_y[p]==$y[x]
          end
          p+=1
        end
           
        p=0
        while p < $static_y.count
          if $static_y[p]==($y[x] + (  SPRITE_HEIGHT / 2 ) )
            print "HIT Y! \n" if $debug >5
            print "$static_x[", p,"] is ", $static_x[p], "\n" if $debug > 5
            hit=1 if $static_x[p]==$x[x]
          end
          p+=1
        end
        if hit==1
          puts "hit!"
          hit=1
        end
        
        # Extra check if bullet
        # - Will need code to figure out if bullet hit beasty
        
        # Extra check if not player, to check if OOB
        if x != 0
            if $x[x] < 0
              hit=1
            elsif $x[x] > WIDTH
              hit=1
            elsif $y[x] < 0
              hit=1
            elsif $y[x] > HEIGHT
              hit=1
            end
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

        if key == Qt::Key_Space.value
          if @shoot==false
            @shoot = true
            if @shoot_dir=="left"
              $x[1]=$x[0]-SPRITE_WIDTH
              $y[1]=$y[0]+( SPRITE_HEIGHT / 2 )
              @pewpew = Qt::Image.new $pewpew_sprite_left
            end
            if @shoot_dir=="right"
              $x[1]=$x[0]+SPRITE_WIDTH
              $y[1]=$y[0]+( SPRITE_HEIGHT / 2 )
              @pewpew = Qt::Image.new $pewpew_sprite_right
            end
            if @shoot_dir=="up"
              $x[1]=$x[0]+( SPRITE_WIDTH / 2 )
              $y[1]=$y[0]-( SPRITE_HEIGHT / 8 ) 
              @pewpew = Qt::Image.new $pewpew_sprite_up
            end
            if @shoot_dir=="down"
              $x[1]=$x[0]+( SPRITE_WIDTH / 2 )
              $y[1]=$y[0]+( SPRITE_HEIGHT  )
              @pewpew = Qt::Image.new $pewpew_sprite_down
            end
          end
        end
        repaint
    end

end
