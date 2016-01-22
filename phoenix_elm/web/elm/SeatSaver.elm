module SeatSaver (..) where

import Html exposing (..)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import StartApp
import Json.Decode as Json exposing (..)
import Effects exposing (Effects, Never)
import Task exposing (Task)


app =
    StartApp.start
        { init = init
        , update = update
        , view = view
        , inputs = [ incomingActions ]
        }


main : Signal Html
main =
    app.html


port tasks : Signal (Task Never ())
port tasks =
    app.tasks


type Status
    = Available
    | Pending
    | Occupied


type alias Seat =
    { seatNo : Int
    , status : Status
    }

type alias Model =
    List Seat


init : ( Model, Effects Action )
init =
    ( [], Effects.none )


view : Signal.Address Action -> Model -> Html
view address model =
    ul [ class "seats" ] (List.map (seatItem address) model)


seatItem : Signal.Address Action -> Seat -> Html
seatItem address seat =
    let
        occupiedClass =
            -- seat.status
            -- if seat.occupied then "occupied" else "available"
            case seat.status of
                Available ->
                    "available"

                Pending ->
                    "pending"

                Occupied ->
                    "occupied"
    in
        li
            [ class ("seat " ++ occupiedClass)
            , onClick address (Toggle seat)
            ]
            [ text (toString seat.seatNo) ]


type Action
    = Toggle Seat
    | SetSeats Model


update : Action -> Model -> ( Model, Effects Action )
update action model =
    case action of
        Toggle seatToToggle ->
            let
                updateSeat seatFromModel =
                    if seatFromModel.seatNo == seatToToggle.seatNo then
                        let
                            nextStatus =
                                case seatFromModel.status of
                                    Pending ->
                                        "Occupied"

                                    Occupied ->
                                        "Available"

                                    Available ->
                                        "Pending"
                        in
                            { seatFromModel | status = nextStatus }
                    else
                        seatFromModel
            in
                ( List.map updateSeat model, Effects.none )

        SetSeats seats ->
            ( seats, Effects.none )


incomingActions : Signal Action
incomingActions =
    Signal.map SetSeats seatLists


port seatLists : Signal Model
