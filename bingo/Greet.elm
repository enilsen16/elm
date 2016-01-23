module Greet where

import Html
import String

greet name color food animal =
  name ++ "'s favorites are: " ++ color ++ " " ++ food ++ " " ++ animal
    |> Html.text

main =
  greet "Erik" "Blue" "Pizza" "donkey"
