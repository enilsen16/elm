import Text exposing (..)
import Color exposing (..)
import Graphics.Element exposing (..)
import Graphics.Collage exposing (..)

diamond color size =
  rotate (degrees 45) (filled color (square size))

main =
  collage 200 200 [ diamond red 100, diamond green 75 ]
