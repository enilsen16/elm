module Main (..) where

import StartApp
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onKeyPress, on, targetValue, targetChecked, onClick)
import Effects exposing (Effects)
import Json.Decode exposing ((:=))
import Json.Encode
import Task


type alias Todo =
  { title : String
  , completed : Bool
  , editing : Bool
  , identifier : Int
  }


type Todos
  = List Todo


type FilterState
  = All
  | Active
  | Completed


type alias Model =
  { todos : List Todo
  , todo : Todo
  , filter : FilterState
  , nextIdentifier : Int
  }


type Action
  = NoOp
  | Add
  | Clear
  | Complete Todo
  | Uncomplete Todo
  | Delete Todo
  | UpdateTitle String
  | Filter FilterState
  | SetModel Model


filterItemView : Signal.Address Action -> Model -> FilterState -> Html
filterItemView address model filterState =
  li
    []
    [ a
        [ classList [ ( "selected", (model.filter == filterState) ) ]
        , href "#"
        , onClick address (Filter filterState)
        ]
        [ text (toString filterState) ]
    ]


filteredTodos : Model -> List Todo
filteredTodos model =
  let
    matchesFilter =
      case model.filter of
        All ->
          (\_ -> True)

        Active ->
          (\todo -> todo.completed == False)

        Completed ->
          (\todo -> todo.completed == True)
  in
    List.filter matchesFilter model.todos


update : Action -> Model -> ( Model, Effects Action )
update action model =
  case action of
    Add ->
      let
        newModel =
          { model
            | todos = model.todo :: model.todos
            , todo = { newTodo | identifier = model.nextIdentifier }
            , nextIdentifier = model.nextIdentifier + 1
          }
      in
        ( newModel
        , sendToStorageMailbox newModel
        )

    Clear ->
      let
        newModel =
          { model
            | todos = List.filter (\todo -> todo.completed == False) model.todos
          }
      in
        ( newModel
        , sendToStorageMailbox newModel
        )

    Complete todo ->
      let
        updateTodo thisTodo =
          if thisTodo.identifier == todo.identifier then
            { todo | completed = True }
          else
            thisTodo

        newModel =
          { model
            | todos = List.map updateTodo model.todos
          }
      in
        ( newModel
        , sendToStorageMailbox newModel
        )

    Uncomplete todo ->
      let
        updateTodo thisTodo =
          if thisTodo.identifier == todo.identifier then
            { todo | completed = False }
          else
            thisTodo

        newModel =
          { model
            | todos = List.map updateTodo model.todos
          }
      in
        ( newModel
        , sendToStorageMailbox newModel
        )

    Delete todo ->
      let
        newModel =
          { model
            | todos = List.filter (\mappedTodo -> todo.identifier /= mappedTodo.identifier) model.todos
          }
      in
        ( newModel
        , sendToStorageMailbox newModel
        )

    Filter filterState ->
      let
        newModel =
          { model | filter = filterState }
      in
        ( newModel
        , sendToStorageMailbox newModel
        )

    UpdateTitle str ->
      let
        todo =
          model.todo

        updatedTodo =
          { todo | title = str }
      in
        ( { model | todo = updatedTodo }
        , Effects.none
        )

    SetModel model ->
      ( model
      , Effects.none
      )

    NoOp ->
      ( model
      , Effects.none
      )


css : String -> Html
css path =
  node "link" [ rel "stylesheet", href path ] []


todoView : Signal.Address Action -> Todo -> Html
todoView address todo =
  let
    updateCompleted =
      case todo.completed of
        True ->
          (\bool -> Signal.message address (Uncomplete todo))

        False ->
          (\bool -> Signal.message address (Complete todo))
  in
    li
      [ classList [ ( "completed", todo.completed ) ] ]
      [ div
          [ class "view" ]
          [ input
              [ class "toggle"
              , type' "checkbox"
              , checked todo.completed
              , on "change" targetChecked updateCompleted
              ]
              []
          , label [] [ text todo.title ]
          , button
              [ class "destroy"
              , onClick address (Delete todo)
              ]
              []
          ]
      ]


handleKeyPress : Int -> Action
handleKeyPress code =
  case code of
    13 ->
      Add

    _ ->
      NoOp


view : Signal.Address Action -> Model -> Html
view address model =
  div
    []
    [ css "style.css"
    , section
        [ class "todoapp" ]
        [ header
            [ class "header" ]
            [ h1 [] [ text "todos" ]
            , input
                [ class "new-todo"
                , placeholder "What needs to be done?"
                , value model.todo.title
                , autofocus True
                , onKeyPress address handleKeyPress
                , on "input" targetValue (\str -> Signal.message address (UpdateTitle str))
                ]
                []
            ]
        , section
            [ class "main" ]
            [ ul
                [ class "todo-list" ]
                (List.map (todoView address) (filteredTodos model))
            ]
        , footer
            [ class "footer" ]
            [ span
                [ class "todo-count" ]
                [ strong [] [ text (toString (List.length (List.filter (\todo -> todo.completed == False) model.todos))) ]
                , text " items left"
                ]
            , ul
                [ class "filters" ]
                [ filterItemView address model All
                , filterItemView address model Active
                , filterItemView address model Completed
                ]
            , button
                [ class "clear-completed"
                , onClick address Clear
                ]
                [ text "Clear completed" ]
            ]
        ]
    ]


newTodo : Todo
newTodo =
  { title = ""
  , completed = False
  , editing = False
  , identifier = 0
  }


initialModel : Model
initialModel =
  { todos =
      [ { title = "The first todo"
        , completed = True
        , editing = False
        , identifier = 1
        }
      ]
  , todo = { newTodo | identifier = 2 }
  , filter = All
  , nextIdentifier = 3
  }


app =
  StartApp.start
    { init = ( initialModel, Effects.none )
    , update = update
    , view = view
    , inputs =
        [ Signal.map mapStorageInput storageInput
        ]
    }


main =
  app.html


encodeJson : Model -> Json.Encode.Value
encodeJson model =
  Json.Encode.object
    [ ( "todos", Json.Encode.list (List.map encodeTodo model.todos) )
    , ( "todo", encodeTodo model.todo )
    , ( "filter", encodeFilterState model.filter )
    , ( "nextIdentifier", Json.Encode.int model.nextIdentifier )
    ]


encodeTodo : Todo -> Json.Encode.Value
encodeTodo todo =
  Json.Encode.object
    [ ( "title", Json.Encode.string todo.title )
    , ( "completed", Json.Encode.bool todo.completed )
    , ( "editing", Json.Encode.bool todo.editing )
    , ( "identifier", Json.Encode.int todo.identifier )
    ]


encodeFilterState : FilterState -> Json.Encode.Value
encodeFilterState filterState =
  case filterState of
    All ->
      Json.Encode.string "All"

    Active ->
      Json.Encode.string "Active"

    Completed ->
      Json.Encode.string "Completed"


mapStorageInput : Json.Decode.Value -> Action
mapStorageInput modelJson =
  case (decodeModel modelJson) of
    Ok model ->
      SetModel model

    _ ->
      NoOp


decodeModel : Json.Decode.Value -> Result String Model
decodeModel modelJson =
  Json.Decode.decodeValue modelDecoder modelJson


modelDecoder : Json.Decode.Decoder Model
modelDecoder =
  Json.Decode.object4
    Model
    ("todos" := Json.Decode.list todoDecoder)
    ("todo" := todoDecoder)
    ("filter" := filterStateDecoder)
    ("nextIdentifier" := Json.Decode.int)


todoDecoder : Json.Decode.Decoder Todo
todoDecoder =
  Json.Decode.object4
    Todo
    ("title" := Json.Decode.string)
    ("completed" := Json.Decode.bool)
    ("editing" := Json.Decode.bool)
    ("identifier" := Json.Decode.int)


filterStateDecoder : Json.Decode.Decoder FilterState
filterStateDecoder =
  let
    decodeToFilterState string =
      case string of
        "All" ->
          Result.Ok All

        "Active" ->
          Result.Ok Active

        "Completed" ->
          Result.Ok Completed

        _ ->
          Result.Err ("Not a vaild FilterState: " ++ string)
  in
    Json.Decode.customDecoder Json.Decode.string decodeToFilterState


storageMailbox : Signal.Mailbox Json.Encode.Value
storageMailbox =
  Signal.mailbox (encodeJson initialModel)


sendToStorageMailbox : Model -> Effects Action
sendToStorageMailbox model =
  Signal.send storageMailbox.address (encodeJson model)
    |> Effects.task
    |> Effects.map (always NoOp)



-- Input


port storageInput : Signal Json.Decode.Value



-- Output


port storage : Signal Json.Encode.Value
port storage =
  storageMailbox.signal


port tasks : Signal (Task.Task Effects.Never ())
port tasks =
  app.tasks
