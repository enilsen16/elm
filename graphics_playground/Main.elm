module Main (..) where

import Color exposing (..)
import Graphics.Collage exposing (..)
import Graphics.Element exposing (..)
import Mouse


main : Signal Element
main =
  Signal.map shapes Mouse.position


shapes : ( Int, Int ) -> Element
shapes ( x, y ) =
  let
    theGroup =
      group
        [ move ( 0, -55 ) blueSquare
        , move ( 0, 55 ) redSquare
        , move ( -110, -55 ) blueCircle
        , move ( -110, 55 ) redCircle
        , move ( 110, -55 ) blueHexagon
        , move ( 110, 55 ) redPentagon
        ]

    originGroup =
      move ( -400, 400 ) theGroup

    movedGroup =
      move ( toFloat (x), toFloat (-1 * y) ) originGroup
  in
    collage 800 800 [ movedGroup ]


blueCircle : Form
blueCircle =
  filled blue circle


redCircle : Form
redCircle =
  filled red circle

blueHexagon : Form
blueHexagon =
  filled blue (ngon 6 50)

redPentagon : Form
redPentagon =
  filled red (ngon 5 50)

blueSquare : Form
blueSquare =
  outlined (dashed blue) square


redSquare : Form
redSquare =
  outlined (solid red) square


square : Shape
square =
  Graphics.Collage.square 100


circle : Shape
circle =
  Graphics.Collage.circle 50
