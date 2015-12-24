import Text exposing (..)
import Color exposing (..)
import Graphics.Element exposing (..)
import Graphics.Collage exposing (..)

diamond: Color -> Float -> Form
diamond color size =
  square size |> filled color |> rotate (degrees 45)

main =
  collage 200 200 [ diamond red 100, diamond green 75 ]


-- Type Annotations
-- add: Int -> Int -> Int
-- add x y = x + y

-- ---- elm repl 0.16.0 -----------------------------------------------------------
--  :help for help, :exit to exit, more at <https://github.com/elm-lang/elm-repl>
-- --------------------------------------------------------------------------------
-- > import String
-- > import List
-- > name = "Mike"
-- "Mike" : String
-- > "Howdy, " ++ name ++ "!"
-- "Howdy, Mike!" : String
-- > names = ["larry", "moe", "curly"]
-- ["larry","moe","curly"] : List String
-- > List.map String.toUpper names
-- ["LARRY","MOE","CURLY"] : List String
-- > List.filter (\n -> n < 0) [-2..3]
-- [-2,-1] : List number
-- > List.foldl (\n sum -> sum + n) 0 [1..6]
-- 21 : number
-- > List.foldl (+) 0 [1..6]
-- 21 : number
