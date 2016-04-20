module Main (..) where

import Color exposing (..)
import Graphics.Collage exposing (..)
import Graphics.Element exposing (..)
import Mouse


main : Signal Element
main =
  Signal.map squares Mouse.position


squares : ( Int, Int ) -> Element
squares ( x, y ) =
  let
    theGroup =
      group
        [ move ( 0, -55 ) blueSquare
        , move ( 0, 55 ) redSquare
        ]

    originGroup =
      move ( -400, 400 ) theGroup

    movedGroup =
      move ( toFloat (x), toFloat (-1 * y) ) originGroup
  in
    collage 800 800 [ movedGroup ]


blueSquare : Form
blueSquare =
  traced (dashed blue) square


redSquare : Form
redSquare =
  traced (solid red) square


square : Path
square =
  path [ ( 50, 50 ), ( 50, -50 ), ( -50, -50 ), ( -50, 50 ), ( 50, 50 ) ]
