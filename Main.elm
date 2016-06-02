module Main exposing (..)

import AnimationFrame
import Char
import Collage exposing (..)
import Color exposing (..)
import Element exposing (..)
import Html exposing (Html, div, text)
import Html.App as App
import Keyboard
import Keyboard.Extra
import List exposing (map, concat, indexedMap, head, drop)
import Task.Extra
import Text
import Time exposing (..)
import Window


type Direction
    = None
    | Right
    | Left

type alias Model =
    { x : Float
    , y : Float
    , dir : Direction
    , playerScore : Float
    , windowSize : Window.Size
    , keyboardModel : Keyboard.Extra.Model
    }


type Msg
    = WindowSize Window.Size
    | KeyboardExtraMsg Keyboard.Extra.Msg
    | Tick Time.Time


init : ( Model, Cmd Msg )
init =
    let
        ( keyboardModel, keyboardCmd ) =
            Keyboard.Extra.init

        model =
            { x = 1.0
            , y = 2.0
            , dir = None
            , playerScore = 0
            , windowSize = Window.Size 0 0
            , keyboardModel = keyboardModel
            }

        cmd =
            Cmd.batch
                [ Window.size |> Task.Extra.performFailproof WindowSize
                , Cmd.map KeyboardExtraMsg keyboardCmd
                ]
    in
        ( model, cmd )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        WindowSize newSize ->
            ( { model | windowSize = newSize }, Cmd.none )

        KeyboardExtraMsg keyMsg ->
            let
                ( keyboardModel, keyboardCmd ) =
                    Keyboard.Extra.update keyMsg model.keyboardModel

                direction =
                    case Keyboard.Extra.arrowsDirection keyboardModel of
                        Keyboard.Extra.West ->
                            Left

                        Keyboard.Extra.East ->
                            Right

                        _ ->
                            model.dir
            in
                ( { model
                    | keyboardModel = keyboardModel
                    , dir = direction
                  }
                , Cmd.map KeyboardExtraMsg keyboardCmd
                )

        Tick delta ->
            ( { model | playerScore = model.playerScore + delta }, Cmd.none )


view : Model -> Html Msg
view model =
    div []
        [ (div [] [ txt (Text.height 50) "The Joy of cats" ])
        , (div [] [ Html.text ("Score " ++ ((round model.playerScore) |> toString)) ])
        , (div [] [ renderGame model ])
        , (div [] [ Html.text "Footer" ])
        ]


renderGame : Model -> Html Msg
renderGame model =
    div [] [ Html.text (toString model.dir) ]


textGreen : Color
textGreen =
    rgb 160 200 160


txt : (Text.Text -> Text.Text) -> String -> Html string
txt f string =
    Text.fromString string
        |> Text.color textGreen
        |> Text.monospace
        |> f
        |> leftAligned
        |> toHtml


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Window.resizes WindowSize
        , Sub.map KeyboardExtraMsg Keyboard.Extra.subscriptions
        , AnimationFrame.diffs (Tick << inSeconds)
        ]


main : Program Never
main =
    App.program
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }
