module RandomGifPair (..) where

import RandomGif
import Effects exposing (Effects)
import Html exposing (..)
import Html.Attributes exposing (..)


type alias Model =
  { left : RandomGif.Model
  , right : RandomGif.Model
  }


type Action
  = Left RandomGif.Action
  | Right RandomGif.Action


init : String -> String -> ( Model, Effects Action )
init leftTopic rightTopic =
  let
    ( left, leftFx ) =
      RandomGif.init leftTopic

    ( right, rightFx ) =
      RandomGif.init rightTopic
  in
    ( { left = left
      , right = right
      }
    , Effects.batch
        [ Effects.map Left leftFx
        , Effects.map Right rightFx
        ]
    )


update : Action -> Model -> ( Model, Effects Action )
update action model =
  case action of
    Left act ->
      let
        ( left, fx ) =
          RandomGif.update act model.left
      in
        ( { model | left = left }
        , Effects.map Left fx
        )

    Right act ->
      let
        ( right, fx ) =
          RandomGif.update act model.right
      in
        ( { model | right = right }
        , Effects.map Right fx
        )


view : Signal.Address Action -> Model -> Html
view address model =
  div
    [ style [ ( "display", "flex" ) ] ]
    [ RandomGif.view (Signal.forwardTo address Left) model.left
    , RandomGif.view (Signal.forwardTo address Right) model.right
    ]
