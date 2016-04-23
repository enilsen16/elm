module Main (..) where

import Color exposing (..)
import Graphics.Collage exposing (..)
import Graphics.Element exposing (..)
import Graphics.Input exposing (..)
import Keyboard
import Time exposing (Time)
import Animation exposing (..)
import Debug


type alias Point =
  ( Int, Int )


type alias Model =
  { points : List Point
  , x : Int
  , y : Int
  , color : Color
  , arrows : { x : Int, y : Int }
  , clock : Time
  , animation : Animation
  , animations : List (Time -> Animation)
  }


type Action
  = Arrows { x : Int, y : Int }
  | Tick Time
  | Shake
  | NoOp
  | SetColor Color


shakeAnimation : Time -> Animation
shakeAnimation t =
  animation t
    |> from 0
    |> to 40
    |> duration (500 * Time.millisecond)


shakeAnimation' : Time -> Animation
shakeAnimation' t =
  animation t
    |> from 40
    |> to -20
    |> duration (500 * Time.millisecond)


shakeAnimation'' : Time -> Animation
shakeAnimation'' t =
  animation t
    |> from -20
    |> to 10
    |> duration (500 * Time.millisecond)


shakeAnimation''' : Time -> Animation
shakeAnimation''' t =
  animation t
    |> from 10
    |> to 0
    |> duration (500 * Time.millisecond)


animations : List (Time -> Animation)
animations =
  [ shakeAnimation
  , shakeAnimation'
  , shakeAnimation''
  , shakeAnimation'''
  ]


initialModel : Model
initialModel =
  { points = [ ( 0, 0 ) ]
  , x = 0
  , y = 0
  , arrows = { x = 0, y = 0 }
  , clock = 0
  , animation = static 0
  , color = red
  , animations = []
  }


update : Action -> Model -> Model
update action model =
  case action of
    Arrows arrows ->
      { model
        | arrows = arrows
      }

    Tick dt ->
      let
        newX =
          model.x + model.arrows.x

        newY =
          model.y + model.arrows.y

        ( newPoints, newAnimation, newAnimations ) =
          case (isDone model.clock model.animation) of
            True ->
              let
                nextAnimation =
                  case List.head model.animations of
                    Just animation ->
                      animation model.clock

                    Nothing ->
                      static 0

                nextAnimations =
                  (List.tail model.animations) |> Maybe.withDefault ([])

                justFinished =
                  nextAnimation
                    `equals` (static 0)
                    && not (model.animation `equals` (static 0))

                nextPoints =
                  case justFinished of
                    True ->
                      []

                    False ->
                      model.points
              in
                ( nextPoints, nextAnimation, nextAnimations )

            False ->
              ( model.points, model.animation, model.animations )

        newPoints' =
          case ( model.arrows.x, model.arrows.y ) of
            ( 0, 0 ) ->
              newPoints

            _ ->
              ( newX, newY ) :: newPoints

        model' =
          { model
            | points = ( newX, newY ) :: newPoints'
            , clock = model.clock + dt
            , animation = newAnimation
            , animations = newAnimations
          }
      in
        { model'
          | x = newX
          , y = newY
        }

    Shake ->
      { model
        | animations = animations
      }

    SetColor color ->
      { model
        | color = color
      }

    NoOp ->
      model


arrows : Signal Action
arrows =
  Signal.map Arrows Keyboard.arrows


clock : Signal Action
clock =
  Signal.map Tick (Time.fps 30)


events : Signal Action
events =
  Signal.mergeMany
    [ arrows
    , clock
    , buttonActions.signal
    ]


model : Signal Model
model =
  Signal.foldp update initialModel events


buttonActions : Signal.Mailbox Action
buttonActions =
  Signal.mailbox NoOp


shakeButton : Element
shakeButton =
  button (Signal.message buttonActions.address Shake) "Shake it good"


colorButton : Color -> String -> Element
colorButton color label =
  button (Signal.message buttonActions.address (SetColor color)) label


view : Model -> Element
view model =
  let
    angle =
      animate model.clock model.animation
  in
    flow
      down
      [ collage
          800
          800
          [ (rotate (degrees angle) (drawLine model.points model.color)) ]
      , shakeButton
      , flow
          right
          [ colorButton red "Red"
          , colorButton blue "Blue"
          , colorButton yellow "Yellow"
          ]
      ]


drawLine : List Point -> Color -> Form
drawLine points color =
  let
    intsToFloats : ( Int, Int ) -> ( Float, Float )
    intsToFloats ( x, y ) =
      ( toFloat x, toFloat y )

    shape =
      path (List.map intsToFloats points)
  in
    shape
      |> traced (solid color)


main : Signal Element
main =
  Signal.map view model
