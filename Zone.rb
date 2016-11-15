# The main file for doom rogue blatant ripoff
#  - learning project
#
# Author: Barrels-o-fun
#
# Created: Nov 2016
#   
#  Key points
#
#  Player (and their shots) stored in player_x[] : player_y[]
#  Beasts stored in $beast_x[] : beast_y[]
#

require_relative 'build_things'

### Debug
$diagnostics=1
$diagnostics_shooting_timer=0
$diagnostics_shooting=0
$static_arrays_mon=false
$debug=0
$timer_inactive=0
$one_house=0
$beast_hidden=0
$beast_inactive=0
###

### GAME CONSTANTS
WIDTH = 640
HEIGHT = 480
# Error tolerance, the larger the number, the larger the arrays for collision
# ... but, the world objects (buildings etc.) can be more varied in placement
ERR_TOLERANCE=2
###

#
## Timer delay to change timing of different objects (currently the backdrop flashing)
$game_timer=10
$acid_level=16
$unsettling=12
$unsettling_offset=5
# Init variables, do not change these
$acid_timer=0
$unsettling_timer=0

# ***** Idea - Have multiple arrays (or hashes?) for different objects.
#
# Init global, stores Images and tracks number of buildings
$bldgs = []

# Init array for global occupied squares, array grows as more objects are on screen.
$static_x = []
$static_y = []

# $player_x and $player_y track player and player related, incl. bullets.
$player_x = []
$player_y = []

# Beast hash
$beasts=[]
$beast_life=[]
$beasts[0]=0
$beast_life[0]=5
$beasts[1]=1
$beast_life[1]=5

# $beast_x and $beast_y track the beasties.
$beast_x = []
$beast_y = []

# Init player initial position
$player_x_pos=WIDTH-60
$player_y_pos=HEIGHT-HEIGHT/ERR_TOLERANCE

# Init beasty initial position (mainly for testing)
$beast_x_pos=WIDTH-100
$beast_y_pos=HEIGHT-HEIGHT/ERR_TOLERANCE - 80



# Images used in game
$player_sprites={}
$player_sprites["left"] = Qt::Image.new "marine_lolx2_left.png"
$player_sprites["right"] = Qt::Image.new "marine_lolx2_right.png"
$player_sprites["up"] = Qt::Image.new "marine_lolx2_up.png"
$player_sprites["down"] = Qt::Image.new "marine_lolx2_down.png"

$pewpew_sprites={}
$pewpew_sprites["left"] = Qt::Image.new "pewpew_left.png"
$pewpew_sprites["right"] = Qt::Image.new "pewpew_right.png"
$pewpew_sprites["up"] = Qt::Image.new "pewpew_up.png"
$pewpew_sprites["down"] = Qt::Image.new "pewpew_down.png"

$back_drops={}
$back_drops["default"] = Qt::Image.new "bldg_80x40.png"
$back_drop_x=0
$back_drop_y=0

# Creates images from scratch
$shooty_sprites={}
shoot_directions=%w[left right up down]
shoot_directions.each { |i| 
  $shooty_sprites[i]=BuildThings.build_shooty(i)
  }
###
  

# Sounds (using aplay via fork atm
@pewpew_sound = Qt::Sound.new "pewpew.wav"

# Init shooting arrays and hashes
$shots_active=[]
$shots_direc={}
$shots_counter=0


# Check game characters height/width
@marine = $player_sprites["left"]
SPRITE_HEIGHT = @marine.height
SPRITE_WIDTH = @marine.width
# Set how much player moves, higher numbers, smaller movements
PLAYER_MOVE_TOLERANCE=1
PLAYER_MOVE_X = SPRITE_WIDTH / PLAYER_MOVE_TOLERANCE / 2

## Trying this out, keeps the Marine "on the spot" more but slow does vertical movements
# Not sure which I prefer...
PLAYER_MOVE_Y = SPRITE_HEIGHT / PLAYER_MOVE_TOLERANCE / 4
PERIMETER_RIGHT=WIDTH-SPRITE_WIDTH
PERIMETER_BOTTOM=HEIGHT-SPRITE_HEIGHT

# Check if player is on the SQUARE grid, else place at 0 for offending axis.
# - For testing
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
      @just_shot = false
      @shoot_dir = "left"
      @prev_shoot_dir = "left"
      @inGame = true
     
      # Building my houses outside of begin/end loop (it was there from nibbles.. 
      # BuildThings.build_house ( pos_x, pos_y, color="green", house="default", width=80, height=160 )
      #
      # I did not expect this to work, thought I would need @bldgx per building.
      # ...but multiple images exist in this one attribute.
      # I guess it is because they are built in order when initGame runs?
      #  Nope!!! It's because you store the buildings in an array!
      #
      # This does make it easier to dynamically create buildings!
      @bldg = BuildThings.build_house( 90, 40, "red", "custom", 200, 120 )
      if $one_house==0
        @bldg = BuildThings.build_house( WIDTH-200, HEIGHT-120, "red" )
        @bldg = BuildThings.build_house( 200, 280, "green", "custom", 160, 80 )
        @bldg = BuildThings.build_house( 300, 248, "blue", "custom", 80, 160  )
        @bldg = BuildThings.build_house( WIDTH-20, HEIGHT-180, "green", "custom", 160, 80 )
      end
      
      print "$static_x: ", $static_x.to_s, "\n" if $static_arrays_mon==true
      print "$static_y: ", $static_y.to_s, "\n" if $static_arrays_mon==true

      # Paint images must be in initGame for game to function.
      begin
        @back_drop_pre_scale = $back_drops["default"]
        @back_drop=@back_drop_pre_scale.scaled(WIDTH, HEIGHT)
        @marine = $player_sprites["left"]
        @shooty_sprite = $shooty_sprites["left"]

=begin
        puts "HERE"
        puts @marine.height
        puts "Before colorTable"
        puts @marine.colorTable
        puts "Before pixel"
        puts @marine.pixel
        puts "Before pixelIndex"
        puts @marine.pixelIndex
        puts "HERE_2"
=end

      @pewpew = Qt::Image.new $pewpew_sprite_left
        
      rescue
        puts "cannot load images"
      end

      # Place player in space
      $player_x[0]=$player_x_pos
      $player_y[0]=$player_y_pos

      # Place beasty in space
      $beast_x[0]=$beast_x_pos
      $beast_y[0]=$beast_y_pos
      $beast_x[1]=40
      $beast_y[1]=40
      
      # Diagnostics
      if $diagnostics > 1
          print "=== GAME_START ===\n"
          print "Marine-x: ", $player_x[0], " - Marine-y: ", $player_y[0], "\n" 
          if $beast_hidden!=1
            $beasts.each {|i| print "Beast-x[", i, "]: ", $beast_x[i], " - Beast-y[", i, "]: ", $beast_y[i], "\n" }
          end
        print "---------------- \n"
        end
       
      # Adding beasty here for now
      @beasty = Qt::Image.new "beasty_lol.png"

      if $timer_inactive==0
        @timer = Qt::BasicTimer.new 
        @timer.start($game_timer, self)
      end


   
    end


    # Simply check if we are @ingame or not.
    def paintEvent event

        painter = Qt::Painter.new
        painter.begin self

        if @inGame
            drawObjects painter
        if $diagnostics_shooting_timer==1
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
        end

        # check if any shots in play, or clear arrays/hashes/counters 
        if $shots_direc.value?("left")==true
        else          
          if $shots_direc.value?("right")==true
          else
            if $shots_direc.value?("up")==true
            else
              if $shots_direc.value?("down")==true
             else
                $shots_direc={}
                $shots_counter=0
                $shots_active=[]
                # Required as we track shots and player positions in one array
                player_at_x=$player_x[0]
                player_at_y=$player_y[0]
                $player_x=[]
                $player_y=[]
                $player_x[0]=player_at_x
                $player_y[0]=player_at_y
             end
           end
         end
       end

    
        else 
            gameOver painter
        end

        painter.end
    end

    # Keeps things moving even when player is not
    def timerEvent event

	@just_shot=false    
        # Check if shot sprites are on screen
        # figure out shots and place them
        if $shots_active != 0
          p=1
          # Using p-1 here as hash stores from 1, array from 0
          while $shots_direc.keys.count > p-1
            direction=$shots_direc[p]
              case direction
                when "left"
                  $player_x[p]-=( SPRITE_WIDTH / 4 )
                when "right"
                  $player_x[p]+=( SPRITE_WIDTH / 4 )
                when "up"
                  $player_y[p]-=( ( SPRITE_HEIGHT / 4 ) / 2 )
                when "down"
                  $player_y[p]+=( ( SPRITE_HEIGHT / 4 ) / 2 )
              end
              p+=1
          end
          # Check if bullets have collided (currently only works on static images)
          $shots_direc.keys.each { |i|
            if checkCollision("player", i)==1 
              $player_x[i]=0
              $player_y[i]=0
              $shots_direc[i]=nil
            end
          }
      

        end

      # Acid Level
      $acid_timer+=1
      @back_drop.invertPixels if $acid_timer==$acid_level
      $acid_timer=0 unless $acid_timer < $acid_level
 
      # Unsettling backdrop
      $unsettling_timer+=1
      if $unsettling_timer==$unsettling
        if $back_drop_x < 0
          $back_drop_x+=$unsettling_offset
          $back_drop_y+=$unsettling_offset
        elsif
          $back_drop_x-=$unsettling_offset
          $back_drop_y-=$unsettling_offset
        end
        $unsettling_timer=0 unless $unsettling_timer < $unsettling
      end
         repaint

      #  Keeping here as a note if needing to stop timer
      #      @timer.stop
    end



    # Here we draw the objects, 
    def drawObjects painter

      # Paint backdrop 
      painter.drawImage $back_drop_x, $back_drop_y, @back_drop
        
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
      painter.drawImage $player_x[0], $player_y[0], @marine unless @just_shot==true && @shoot_dir=="up"
      
      # Paint beasty
      if $beast_hidden != 1
        $beasts.each { |active_beast|
          if $beast_life[active_beast] > 0
            painter.drawImage $beast_x[active_beast], $beast_y[active_beast], @beasty
          end
        }
      end
     
      # Paint bullets
      # (We don't currently set @shoot to false, only to true after first hit)
      if @shoot==true
        if $shots_direc.count != 0
          $shots_direc.keys.each {
            |i| painter.drawImage $player_x[i], $player_y[i], $pewpew_sprites[$shots_direc[i]]  unless $shots_direc[i]==nil
            }
        end
      
    
      # Paint shoting animation (if just_shot), has to be after bullet painting to prevent overlay
      if @just_shot==true
        case @shoot_dir
          when "left"
        print "@shooty_sprite_left.height: ", $shooty_sprites["left"].height, "\n"
	    display_x = 0 - $shooty_sprites["left"].width
	    display_y = ( SPRITE_HEIGHT / 2 - ( $shooty_sprites["left"].height ) )
            @shooty_sprite=$shooty_sprites["left"]
          when "right"
	    display_x = SPRITE_WIDTH
	    display_y = ( SPRITE_HEIGHT / 2 - ( $shooty_sprites["right"].height ) ) 
            @shooty_sprite=$shooty_sprites["right"]
          when "up"
	    display_x = ( SPRITE_WIDTH / 2 )
	    display_y = 0 - $shooty_sprites["up"].height + 12
            @shooty_sprite=$shooty_sprites["up"]
          when "down"
	    display_x= ( SPRITE_WIDTH  / 2 )
	    display_y= ( SPRITE_HEIGHT / 2 )   
            @shooty_sprite=$shooty_sprites["down"]

        end
      painter.drawImage $player_x[0] + display_x, $player_y[0] + display_y, @shooty_sprite
      painter.drawImage $player_x[0], $player_y[0], @marine if @shoot_dir=="up"
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

        # Diagnostics
        if $diagnostics > 1
          print "=== NEW TURN ===\n"
          print "Marine-x: ", $player_x[0], " - Marine-y: ", $player_y[0], "\n" 
          if $beast_hidden!=1
            $beasts.each {|i| print "Beast-x[", i, "]: ", $beast_x[i], " - Beast-y[", i, "]: ", $beast_y[i], "\n" }
          end
        print "---------------- \n"
        end

        @shoot_dir="left" if @shoot_dir == nil 
        # Player Moves
        if @left
            $player_x[0] -= PLAYER_MOVE_X  unless $player_x[0] == 0 #  || @prev_shoot_dir != "left"
            @shoot_dir="right" unless @shoot==true 
            @prev_shoot_dir="left"
            @marine = $player_sprites["left"]
            
        end

        if @right 
            $player_x[0] += PLAYER_MOVE_X  unless $player_x[0] == PERIMETER_RIGHT #  || @prev_shoot_dir != "right"
            @shoot_dir="right" unless @shoot==true 
            @prev_shoot_dir="right"
            @marine = $player_sprites["right"]
        end

        if @up
            puts @prev_shoot_dir
            $player_y[0] -= PLAYER_MOVE_Y  unless $player_y[0] == 0 #  || @prev_shoot_dir != "up"
            @shoot_dir="up" unless @shoot==true
            @prev_shoot_dir="up"
            @marine = $player_sprites["up"]
        end

        if @down
            $player_y[0] += PLAYER_MOVE_Y  unless $player_y[0] == PERIMETER_BOTTOM #  || @prev_shoot_dir != "down"
            @shoot_dir="down" unless @shoot==true
            @prev_shoot_dir="down"
            @marine = $player_sprites["down"]
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
        # Needs more logic, beasts get stuck, also don't react to player... yet ; )
        puts $beasts.to_s
        $beasts.each { |i|
          if $beast_life[i] > 0
            beast_move=rand(7)
            print "Beast", i, "rand: ", beast_move, "\n"
            if $beast_inactive==0
              case beast_move 
                when (0..1)  # left
                  $beast_x[i] -= PLAYER_MOVE_X unless $beast_x[i] == 0
                  if checkCollision( "beast", i ) ==1 
                     print "Beast Collided when going left \n"
                     $beast_x[i] += PLAYER_MOVE_X
                  end
               when (2..3)  # right
                 $beast_x[i] += PLAYER_MOVE_X unless $beast_x[i] == PERIMETER_RIGHT
                   if checkCollision( "beast", i ) ==1 
                     print "Beast Collided when going right \n"
                     $beast_x[i] -= PLAYER_MOVE_X
                   end
               when (4..5) # up
                 $beast_y[i] -= PLAYER_MOVE_Y unless $beast_y[i] == 0
                 if checkCollision( "beast", i ) ==1 
                   print "Beast Collided when going up \n"
                   $beast_y[i] += PLAYER_MOVE_Y
                 end
               when (6..7) # down
                 $beast_y[i] += PLAYER_MOVE_Y unless $beast_y[i] == PERIMETER_BOTTOM
                 if checkCollision( "beast", i ) ==1 
                   $beast_y[i] -= PLAYER_MOVE_Y 
                   print "Beast Collided when going down \n"
                 end
              end
            end
          end
        }
        
        # Diagnostics
        if $diagnostics > 1
          print "Marine-x: ", $player_x[0], " - Marine-y: ", $player_y[0], "\n" 
          if $beast_hidden!=1
            $beasts.each {|i| print "Beast-x[", i, "]: ", $beast_x[i], " - Beast-y[", i, "]: ", $beast_y[i], "\n" }
          end
        print "---------------- \n"
        end
    end


    # Checks if players x,y pos matches any other solid object.
    # We add (SPRITE_x / 2) to check the MIDDLE of the sprite
    def checkCollision( sprite="player", sprite_num = 0)
        
        case sprite
          when "player"
            check_x=$player_x
            check_y=$player_y
          when "beast"
            check_x=$beast_x
            check_y=$beast_y
        end
    #      print sprite, sprite_num, " is ", check_y[sprite_num]  ,"\n"
        bullet_modifier_y=0
        hit=0
        p=0
        #Check if sprite has hit static object, check X and corresponding Y
        while p < $static_x.count
          if $static_x[p]==(check_x[sprite_num] +( SPRITE_WIDTH / 2 )  )
            print sprite, sprite_num, "HIT Solid X, $static_y[", p,"] is ", $static_y[p], "\n" if $debug > 6
            hit=1 if $static_y[p]==check_y[sprite_num]
            if hit==1
              print "I'm HERERERERERE"
            end
          end
          p+=1
        end

        # We also check Y and corresponding X, this is required.
        # Hopefully one day we can do this better :-)
        q=0
        bullet_modifier_y=15 if sprite=="player" && sprite_num <= 0
        while q < $static_y.count
          if $static_y[q]==(check_y[sprite_num] + ( SPRITE_HEIGHT / 2 ) + bullet_modifier_y )
            print sprite, sprite_num, "HIT Solid Y, $static_x[", q,"] is ", $static_x[q], "\n" if $debug > 6
            hit=1 if $static_x[q]==check_x[sprite_num]
          end
          q+=1
        end

        if hit==1
          print "************", sprite, sprite_num, " hit solid object! ******* \n\n\n\n\n" if $diagnostics>=1
          hit=1
          return hit
        end
       
        #### Bullet Check ####
        # Records beast hits, and reduces beast life
        if sprite=="player" && sprite_num != 0 
          p=0
          while p < $beasts.count
            if $beast_x[p]==(check_x[sprite_num] - ( SPRITE_WIDTH / 2 ) )
              print "HIT Beast X! \n"  if $debug >4
              print "$beast_y[", p, "] is ", $beast_y[p], "\n" if $debug > 5
              if $beast_y[p]==check_y[sprite_num]+5
                hit=1
                beast_hit=$beasts[p]
                $beast_life[p]-=1
                if $beast_life[p]<=0
                  $beast_x[p]=-100
                  $beast_y[p]=-100
                end
                print "**** BEAST HIT - $beast_life[", beast_hit, "]: ", $beast_life[beast_hit], "\n" if $diagnostics>=1
              end
            end
            p+=1
            return hit if hit == 1
          end
          
          # As before we check X then Y above, and follow it with Y and X 
          q=0
          while q < $beast_y.count
            if $beast_y[q]==(check_y[sprite_num] - ( SPRITE_HEIGHT / 2 ) +5 )
              print "HIT Beast Y! \n" if $debug >4
              print "$beast_x[", q, "] is ", $beast_x[q], "\n" if $debug > 5
              if $beast_x[q]==check_x[sprite_num]+5
                hit=1
                beast_hit=$beasts[q]
                $beast_life[q]-=1
                if $beast_life[q]<=0
                  $beast_x[q]=-100
                  $beast_y[q]=-100
                end
                print "**** BEAST HIT - $beast_life[", beast_hit, "]: ", $beast_life[beast_hit], "\n" if $diagnostics>=1
              end
            end
            q+=1
            print "Player [", sprite_num, "] hit beasty[", p, "]\n\n" if hit==1 && $diagnostics==1
            return hit if hit == 1
          end
        end  
        
        # Extra check if not player, to check if OOB
        if sprite_num != 0 || sprite != "player"
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
       
	@just_shot = false 
        key = event.key
      
        # Will work properly at some point, right now crashes out
        # Quicker than Alt-F4 or moving mouse ; )
        if key == Qt::Key_Q.value
          puts "Q pressed"
          connect quit, ('clicked()'), $qApp, SLOT('quit()')
        end
 
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
            
            # Is there a way to get Qt to play sounds, I suspect so...
            # I'm not sure if the sound if being sent or not
            # I have found it requires /dev/dsp on linux
            # ... which meant installing/loading alsa-oss libraries
            #
            # @pewpew_sound = Qt::Sound.new "pewpew.wav"
            # @pewpew_sound.play
            # This shows the sound is loaded
            # - puts @pewpew_sound.to_s
            #
            # For now I will use this suggestion, good enough to get the feel!
            pid = fork{ exec 'aplay', 'pewpew.wav' }
            
            @shoot = true
            @left = false
            @right = false
            @up = false
            @down = false
	    @just_shot = true
            $shots_counter+=1
            $shots_active.push 1
            case @shoot_dir
              when "left"
                $player_x[$shots_counter]=$player_x[0]-SPRITE_WIDTH
                $player_y[$shots_counter]=$player_y[0]+( ( SPRITE_HEIGHT / 2 ) - 5 )
                @pewpew = Qt::Image.new $pewpew_sprite_left
                $shots_direc[$shots_counter]="left"
              when "right"
                $player_x[$shots_counter]=$player_x[0]+SPRITE_WIDTH
                $player_y[$shots_counter]=$player_y[0]+( ( SPRITE_HEIGHT / 2 ) - 5 )
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
            move
        end

        if $diagnostics_shooting==1
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
        end

        repaint
    end
end
end
