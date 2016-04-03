module Main (..) where

import Html exposing (..)
import String exposing (..)
import Signal exposing (Address)
import Json.Encode
import Html.Attributes exposing (class, target, href, property)
import Html.Events exposing (..)
import StartApp.Simple as StartApp


type alias Model =
  { count : Int
  , int : Int
  }


main =
  StartApp.start
    { view = view
    , update = update
    , model = initialModel
    }


initialModel : Model
initialModel =
  { count = 0
  , int = 1
  }


view : Address Action -> Model -> Html
view address model =
  div
    []
    [ button [ onClick address Decrement ] [ text "-" ]
    , div [] [ text (toString model.count) ]
    , button [ onClick address Increment ] [ text "+" ]
    , Html.br [] []
    , input [ onInput address SetIncrement, defaultValue model.int ] []
    ]


type Action
  = Increment
  | Decrement
  | SetIncrement String


update : Action -> Model -> Model
update action model =
  case action of
    Increment ->
      { model | count = (+) model.count model.int }

    Decrement ->
      { model | count = (-) model.count model.int }

    SetIncrement value ->
      { model | int = (toInt value |> Result.toMaybe |> Maybe.withDefault 0) }


onInput : Address Action -> (String -> Action) -> Attribute
onInput address wrap =
  on "input" targetValue (\val -> Signal.message address (wrap val))


defaultValue : Int -> Attribute
defaultValue int =
  property "defaultValue" (Json.Encode.int int)
