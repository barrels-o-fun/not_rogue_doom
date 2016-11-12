WIDTH = 640
HEIGHT = 480
SQUARE_HEIGHT = 20
SQUARE_WIDTH = 10
ALL_SQUARES = WIDTH * HEIGHT / (SQUARE_HEIGHT * SQUARE_WIDTH)

$x = [0] * ALL_SQUARES
$y = [0] * ALL_SQUARES
$player_x=WIDTH-50
$player_y=HEIGHT-HEIGHT/2
if $player_y%SQUARE_HEIGHT != 0 
  $player_y=20 
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
       
        # This rescue doesn't seem to work - look into at some point? 
        begin
            @marine = Qt::Image.new "marine_lol.png"
            @bldg1 = Qt::Image.new "bldg_40x80.png"
            @bldg2 = Qt::Image.new "bldg_40x80.png"
        rescue
            puts "cannot load images"
        end

        # Place all objects in space
        $x[0]=$player_x
        $y[0]=$player_y
        $x[1]=140
        $y[1]=160
        $x[2]=WIDTH-100-@bldg2.width
        $y[2]=HEIGHT-20-@bldg2.height
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
                painter.drawImage $x[1], $y[1], @bldg1
                painter.drawImage $x[2], $y[2], @bldg2
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
        print "Marine-x: ", $x[0], " - Marine-y: ", $y[0], "\n"
    end


    def checkCollision


        if $y[0] > HEIGHT
            @inGame = false
        end
        
        if $y[0] < 0
            @inGame = false
        end
        
        if $x[0] > WIDTH
            @inGame = false
        end
        
        if $x[0] < 0
            @inGame = false
        end    
        
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
end
