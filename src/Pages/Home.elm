module Pages.Home exposing (..)

import Browser
import Common exposing (HomeModel, Page, Route)
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Html exposing (..)
import Html.Attributes exposing (classList, href)
import Html.Events exposing (..)
import Style exposing (..)


initialModel : HomeModel
initialModel =
    0


init : () -> ( HomeModel, Cmd Msg )
init _ =
    ( initialModel, Cmd.none )


view : HomeModel -> Html Msg
view model =
    let
        content =
            row [] [ Element.text "Hello World" ]
    in
    Element.layout
        [ height fill
        , width fill
        , Font.family
            [ Font.typeface "Avenir"
            , Font.sansSerif
            ]
        , centerX
        , centerY
        , Background.color colorGreen
        ]
        viewHeader


viewHeader : Element Msg
viewHeader =
    let
        logo =
            el
                [ paddingXY 5 15
                , Font.size 64
                , Font.color <| rgb255 255 255 255
                , Background.color <| colorPink
                ]
                (Element.text "What is elm?")

        links =
            row
                [ spacing 5
                , paddingXY 0 5
                ]
                [ link
                    [ Background.color <| colorPink
                    , Font.color <| rgb255 255 255 255
                    , padding 8
                    ]
                    { url = "/elmui"
                    , label = Element.text "elm-ui"
                    }
                ]
    in
    column
        [ centerX
        , centerY
        , width fill
        , height fill
        , padding 200
        ]
        [ logo, links ]


viewFooter : Element msg
viewFooter =
    el [] (Element.text "Hello Footer")


type Msg
    = Increment
    | Decrement


update : Msg -> HomeModel -> ( HomeModel, Cmd Msg )
update msg model =
    case msg of
        Increment ->
            ( model + 1, Cmd.none )

        Decrement ->
            ( model - 1, Cmd.none )
