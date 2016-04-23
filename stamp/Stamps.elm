module Stamps (..) where

import Color exposing (..)
import Graphics.Collage exposing (..)
import Graphics.Element exposing (..)
import Mouse
import Keyboard


type Shape
  = Pentagon
  | Circle


type alias Stamp =
  { location : ( Int, Int )
  , shape : Shape
  }


type alias Model =
  { shift : Bool
  , stamps : List Stamp
  }


type Action
  = Click ( Int, Int )
  | Shift Bool


initialModel : Model
initialModel =
  { shift = False
  , stamps = []
  }


update : Action -> Model -> Model
update action model =
  case action of
    Shift bool ->
      { model | shift = bool }

    Click ( x, y ) ->
      let
        stamp =
          case model.shift of
            True ->
              Stamp ( x, y ) Circle

            False ->
              Stamp ( x, y ) Pentagon
      in
        { model | stamps = stamp :: model.stamps }


events : Signal Action
events =
  Signal.mergeMany
    [ clicks
    , shifts
    ]


clicks : Signal Action
clicks =
  Signal.map
    Click
    (Signal.sampleOn Mouse.clicks Mouse.position)


shifts : Signal Action
shifts =
  Signal.map Shift Keyboard.shift

view : Model -> Element
view model =
  let
    theGroup =
      group (List.map drawStamp model.stamps)

    originGroup =
      move ( -400, 400 ) theGroup
  in
    collage
      800
      800
      [ originGroup ]


drawStamp : Stamp -> Form
drawStamp stamp =
  let
    ( x, y ) =
      stamp.location

    shape =
      case stamp.shape of
        Pentagon ->
          ngon 5 50

        Circle ->
          circle 50
  in
    shape
      |> filled red
      |> move ( toFloat (x), toFloat (-1 * y) )


model : Signal Model
model =
  Signal.foldp update initialModel events


main : Signal Element
main =
  Signal.map view model
