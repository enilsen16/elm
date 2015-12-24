import Text exposing (..)
import Color exposing (..)
import Graphics.Element exposing (..)
import Graphics.Collage exposing (..)

main =
  collage 200 200 [ rotate (degrees 45) (filled blue (square 100)) ]
