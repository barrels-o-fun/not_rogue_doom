# The main file for doom rogue blatant ripoff
#  - learning project
#
# Author: Barrels-o-fun
#

require_relative 'build_things'

# Debug
$diagnostics=1
$debug=0
$timer_inactive=0
$one_house=0
$beasty_hidden=0
$beasty_inactive=0


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

$pewpew_sprites={}
$pewpew_sprites["left"]= Qt::Image.new $pewpew_sprite_left
$pewpew_sprites["right"]= Qt::Image.new $pewpew_sprite_right
$pewpew_sprites["up"]= Qt::Image.new $pewpew_sprite_up
$pewpew_sprites["down"]= Qt::Image.new $pewpew_sprite_down

# Shooting arrays and hashes
$shots_active=[]
$shots_direc={}
$shots_counter=0


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


# Idea - Have multiple arrays (or hashes?) for different objects.
#
# Init global, stores Images and tracks number of buildings
$bldgs = []

# Init array for global occupied squares, array grows as more objects are on screen.
$static_x = []
$static_y = []

# $player_x and $player_y track player and player related 
# e.g. bullets.
$player_x = []
$player_y = []

# $beast_x and $beast_y track the beasties
$beasty_x = []
$beasty_y = []

# Init player initial position
$player_x_pos=WIDTH-60
$player_y_pos=HEIGHT-HEIGHT/ERR_TOLERANCE

# Init beasty initial position
$beasty_x_pos=20
$beasty_y_pos=40

# Check if player is on the SQUARE grid, else place at 0 for offending axis.
if $player_x_pos%SPRITE_WIDTH != 0 
  $player_x_pos=0 
end
if $player_y_pos%SPRITE_HEIGHT != 0 
  $player_y_pos=0 
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
      @shoot_dir = "left"
      @inGame = true
     
      # Building my houses outside of begin/end loop (it was there from nibbles.. 
      @bldg1 = BuildThings.build_house( 40, 40, 2, "green" )
      if $one_house==0
        @bldg2 = BuildThings.build_house( WIDTH-140, HEIGHT-120, 2, "red")
        @bldg3 = BuildThings.build_house( 200, 280, 2)
        @bldg4 = BuildThings.build_house( 300, 248, 2, "blue" )
      #  @bldg5 = BuildThings.build_house( WIDTH-20, HEIGHT-100 )
      end
      
                print "$shots_counter: ", $shots_counter.to_s, "\n"
                print "$player_x.to_s: ", $player_x.to_s, "\n"
                print "$player_y.to_s: ", $player_y.to_s, "\n"
                print "$shots_direc_keys: ", $shots_direc.keys, "\n"
                print "$shots_direc_values: ", $shots_direc.values, "\n"
      

      # This rescue doesn't seem to work - look into at some point? 
      # Paint images must be in initGame for game to function.
      begin
        @marine = Qt::Image.new $player_sprite_left
        @pewpew = Qt::Image.new $pewpew_sprite_left
      rescue
        puts "cannot load images"
      end

      # Place player in space
      $player_x[0]=$player_x_pos
      $player_y[0]=$player_y_pos

      # Place beasty in space
      $beasty_x[0]=$beasty_x_pos
      $beasty_y[0]=$beasty_y_pos
       
      # Adding beasty here for now
      @beasty = Qt::Image.new "beasty_lol.png"

      if $timer_inactive==0
        @timer = Qt::BasicTimer.new 
        @timer.start(80, self)
      end
   
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

        if $shots_active != 0
        
        # Figure out shots and place them
        p=1
        # Using p-1 here as hash stores from 1, array from 0
        while $shots_direc.keys.count > p-1
          direction=$shots_direc[p]
          case direction
            when "left"
              $player_x[p]-=SPRITE_WIDTH
            when "right"
              $player_x[p]+=SPRITE_WIDTH
            when "up"
              $player_y[p]-=( SPRITE_HEIGHT / 2 )
            when "down"
              $player_y[p]+=( SPRITE_HEIGHT / 2 )
            end
              p+=1
        end
        print "$shots_direc.keys: ", $shots_direc.keys.to_s, "\n"
        $shots_direc.keys.each { |i|
          if checkCollision("player", i)==1 
            $player_x[i]=0
            $player_y[i]=0
            $shots_direc[i]=nil
            $shots_counter-=1
          end
        }
      #          @shoot = false
      #  Keeping here as a note if needing to stop timer
      #      @timer.stop
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
 

        # Paint player
        painter.drawImage $player_x[0], $player_y[0], @marine

        
        # Paint beasty
        if @beasty != nil
          if $beasty_hidden==0
            painter.drawImage $beasty_x[0], $beasty_y[0], @beasty
          end
        end
       
        

          print "$shots_counter: ", $shots_counter.to_s, "\n"
          print "$player_x.to_s: ", $player_x.to_s, "\n"
          print "$player_y.to_s: ", $player_y.to_s, "\n"
          print "$shots_direc_keys: ", $shots_direc.keys, "\n"
          print "$shots_direc_values: ", $shots_direc.values, "\n\n\n"
        if @shoot==true
          if $shots_direc.count != 0
             $shots_direc.keys.each {
                |i| painter.drawImage $player_x[i], $player_y[i], $pewpew_sprites[$shots_direc[i]]  unless $shots_direc[i]==nil
                 }
          end
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
        @shoot_dir="left" if @shoot_dir == nil 
        # Player Moves
        if @left
            $player_x[0] -= PLAYER_MOVE_X  unless $player_x[0]==0
            @marine = Qt::Image.new $player_sprite_left
            
        end

        if @right 
            $player_x[0] += PLAYER_MOVE_X  unless $player_x[0]==WIDTH-SPRITE_WIDTH
            @shoot_dir="right" unless @shoot==true 
            @marine = Qt::Image.new $player_sprite_right
        end

        if @up
            $player_y[0] -= PLAYER_MOVE_Y  unless $player_y[0]==0
            @shoot_dir="up" unless @shoot==true
            @marine = Qt::Image.new $player_sprite_up
        end

        if @down
            $player_y[0] += PLAYER_MOVE_Y  unless $player_y[0]==HEIGHT-SPRITE_HEIGHT
            @shoot_dir="down" unless @shoot==true
            @marine = Qt::Image.new $player_sprite_down
        end

        # collision check, currently against non-hurty static objects (buildings)
        if checkCollision("player", 0)==1
          if @left
              $player_x[0] += PLAYER_MOVE_X
          end

          if @right 
              $player_x[0] -= PLAYER_MOVE_X
          end

          if @up
              $player_y[0] += PLAYER_MOVE_Y
          end

          if @down
              $player_y[0] -= PLAYER_MOVE_Y 
          end
        end

        # Move beasty (random direction)
        beast_move=rand(8)
          if $beasty_inactive==0
            case beast_move 
              when (0..2)
                $beasty_x[0] += PLAYER_MOVE_X unless $beasty_x[0] > ( WIDTH - ( SPRITE_WIDTH * 1.5 ) ) 
                $beasty_x[0] -= PLAYER_MOVE_X if checkCollision( "beast", 0 )==1
              when (3..4)
                $beasty_x[0] -= PLAYER_MOVE_X unless $beasty_x[0] < ( SPRITE_WIDTH / 1 )
                $beasty_x[0] += PLAYER_MOVE_X if checkCollision( "beast", 0 )==1
              when (5..6)
                $beasty_y[0] += PLAYER_MOVE_Y unless $beasty_y[0] > ( HEIGHT - ( SPRITE_HEIGHT * 1.5 ) )
                $beasty_y[0] -= PLAYER_MOVE_Y if checkCollision( "beast", 0 )==1
              when (7..8)
                $beasty_y[0] -= PLAYER_MOVE_Y unless $beasty_y[0] < ( SPRITE_HEIGHT / 2 )
                $beasty_y[0] += PLAYER_MOVE_Y if checkCollision( "beast", 0 )==1
            end
          end
          
        
       # Diagnostics
      print "Marine-x: ", $player_x[0], " - Marine-y: ", $player_y[0], "\n" if $diagnostics==1
      $shots_direc.keys.each { |i| print "$shots_direc [", i, "]: ", $shots_direc[i], "\n" }
        if $beasty_hidden==0
          print "Beasty-x: ", $beasty_x[0], " - Beasty-y: ", $beasty_y[0], "\n" if $diagnostics==1
        end
    end


    # Checks if players x,y pos matches any other object.
    # We add (SPRITE_x / 2) to check the MIDDLE of the sprite
    def checkCollision( sprite="player", sprite_num = 0)
        case sprite
          when "player"
            check_x=$player_x
            check_y=$player_y
          when "beast"
            check_x=$beasty_x
            check_y=$beasty_y
        end
        hit=0
        p=0
        while p < $static_x.count
          if $static_x[p]==(check_x[sprite_num] +( SPRITE_WIDTH / 2 ) )
            print "HIT X! \n"  if $debug >5
            print "$static_y[", p,"] is ", $static_y[p], "\n" if $debug > 5
            hit=1 if $static_y[p]==check_y[x]
          end
          p+=1
        end
           
        p=0
        while p < $static_y.count
          if $static_y[p]==(check_y[sprite_num] + (  SPRITE_HEIGHT / 2 ) )
            print "HIT Y! \n" if $debug >5
            print "$static_x[", p,"] is ", $static_x[p], "\n" if $debug > 5
            hit=1 if $static_x[p]==check_x[x]
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
        if sprite_num != 0 || sprite != "player"
            puts "HERE"
            if check_x[sprite_num] < 0
              hit=1
            elsif check_x[sprite_num] > WIDTH
              hit=1
            elsif check_y[sprite_num] < 0
              hit=1
            elsif check_y[sprite_num] > HEIGHT
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
            @shoot_dir = "left"
            move
        end
        
        if key == Qt::Key_Right.value
            @left = false
            @right = true
            @up = false
            @down = false
            @shoot_dir = "right"
            move
        end
        
        if key == Qt::Key_Up.value
            @left = false
            @right = false
            @up = true
            @down = false
            @shoot_dir = "up"
            move
        end
        
        if key == Qt::Key_Down.value
            @left = false
            @right = false
            @up = false
            @down = true
            @shoot_dir = "down"
            move
        end

        if key == Qt::Key_Space.value
            @shoot = true
            @left = false
            @right = false
            @up = false
            @down = false
            $shots_counter+=1
            $shots_active.push 1
            case @shoot_dir
              when "left"
                $player_x[$shots_counter]=$player_x[0]-SPRITE_WIDTH
                $player_y[$shots_counter]=$player_y[0]+( SPRITE_HEIGHT / 2 )
                @pewpew = Qt::Image.new $pewpew_sprite_left
                $shots_direc[$shots_counter]="left"
              when "right"
                $player_x[$shots_counter]=$player_x[0]+SPRITE_WIDTH
                $player_y[$shots_counter]=$player_y[0]+( SPRITE_HEIGHT / 2 )
                @pewpew = Qt::Image.new $pewpew_sprite_right
                $shots_direc[$shots_counter]="right"
              when "up"
                $player_x[$shots_counter]=$player_x[0]+( SPRITE_WIDTH / 2 )
                $player_y[$shots_counter]=$player_y[0]-( SPRITE_HEIGHT / 8 ) 
                @pewpew = Qt::Image.new $pewpew_sprite_up
                $shots_direc[$shots_counter]="up"
              when "down"
                $player_x[$shots_counter]=$player_x[0]+( SPRITE_WIDTH / 2 )
                $player_y[$shots_counter]=$player_y[0]+( SPRITE_HEIGHT  )
                @pewpew = Qt::Image.new $pewpew_sprite_down
                $shots_direc[$shots_counter]="down"
            end
            puts $shots_direc[$shots_counter]
            print "Just shot: \n"
                print "@shoot_dir: ", @shoot_dir, "\n"
                print "$shots_counter: ", $shots_counter.to_s, "\n"
                print "$player_x.to_s: ", $player_x.to_s, "\n"
                print "$player_y.to_s: ", $player_y.to_s, "\n"
                print "$shots_active: ", $shots_active.to_s, "\n"
                print "$shots_direc_keys: ", $shots_direc.keys, "\n"
                print "$shots_direc_values: ", $shots_direc.values, "\n"
            print "\n\n"
            move
        end

        repaint
    end
end
end
