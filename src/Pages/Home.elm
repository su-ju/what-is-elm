module Pages.Home exposing (..)

import Browser
import Common exposing (HomeModel, Page, Route)
import Html exposing (..)
import Html.Attributes exposing (classList, href)
import Html.Events exposing (..)


initialModel : HomeModel
initialModel =
    0


init : () -> ( HomeModel, Cmd Msg )
init _ =
    ( initialModel, Cmd.none )


view : HomeModel -> Html Msg
view model =
    div []
        [ viewHeader
        , button [ onClick Decrement ] [ text "-" ]
        , text (String.fromInt model)
        , button [ onClick Increment ] [ text "+" ]
        , viewFooter
        ]


viewHeader : Html Msg
viewHeader =
    let
        logo =
            h1 [] [ text "What is elm?" ]

        links =
            ul []
                [ navLink { url = "/", caption = "Home" }
                , navLink { url = "/elmui", caption = "Elmui" }
                ]

        navLink : { url : String, caption : String } -> Html msg
        navLink { url, caption } =
            li []
                [ a [ href url ] [ text caption ] ]
    in
    nav [] [ logo, links ]


viewFooter : Html msg
viewFooter =
    footer [] [ text "Footer" ]


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
