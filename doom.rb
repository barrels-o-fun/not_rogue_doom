#!/usr/bin/ruby

# Blatant rip-off of rogue dooom
# - but it is just a learning project!
# Author: Barrels-o-fun
# v 0.1

require 'Qt'
require_relative 'Zone'

class QtApp < Qt::MainWindow
    
    def initialize
        super
        
        setWindowTitle "Totally not roguedoom!"
       
        setCentralWidget Board.new(self)
       
        resize 640, 480
        center

        show
    end

    def center
    qdw = Qt::DesktopWidget.new

    screenWidth = qdw.width
    screenHeight = qdw.height

    x = (screenWidth - WIDTH) / 2
    y = (screenHeight - HEIGHT) / 2

    move x+450, y+200
  end

end

app = Qt::Application.new ARGV
QtApp.new
app.exec
