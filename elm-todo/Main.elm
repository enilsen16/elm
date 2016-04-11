module Main (..) where

import StartApp.Simple exposing (start)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onKeyPress, on, targetValue, targetChecked, onClick)


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


update : Action -> Model -> Model
update action model =
  case action of
    Add ->
      { model
        | todos = model.todo :: model.todos
        , todo = { newTodo | identifier = model.nextIdentifier }
        , nextIdentifier = model.nextIdentifier + 1
      }

    Clear ->
      { model | todos = List.filter (\todo -> todo.completed == False) model.todos }

    Complete todo ->
      let
        updateTodo thisTodo =
          if thisTodo.identifier == todo.identifier then
            { todo | completed = True }
          else
            thisTodo
      in
        { model
          | todos = List.map updateTodo model.todos
        }

    Uncomplete todo ->
      let
        updateTodo thisTodo =
          if thisTodo.identifier == todo.identifier then
            { todo | completed = False }
          else
            thisTodo
      in
        { model
          | todos = List.map updateTodo model.todos
        }

    Delete todo ->
      { model | todos = List.filter (\mappedTodo -> todo.identifier /= mappedTodo.identifier) model.todos }

    Filter filterState ->
      { model | filter = filterState }

    UpdateTitle str ->
      let
        todo =
          model.todo

        updatedTodo =
          { todo | title = str }
      in
        { model | todo = updatedTodo }

    NoOp ->
      model


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


main =
  StartApp.Simple.start
    { model = initialModel
    , update = update
    , view = view
    }
