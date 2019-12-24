module Pages.Elmui exposing (..)

import Browser
import Common exposing (ElmuiModel, Page, Route)
import Html exposing (..)
import Html.Events exposing (..)


initialModel : ElmuiModel
initialModel =
    0


createModel : String -> ElmuiModel
createModel val =
    let
        res =
            String.toInt val
    in
    case res of
        Just great ->
            great

        Nothing ->
            0


init : () -> ( ElmuiModel, Cmd Msg )
init _ =
    ( initialModel, Cmd.none )


view : ElmuiModel -> Html Msg
view model =
    div []
        [ button [ onClick Decrement ] [ text "-" ]
        , text (String.fromInt model)
        , button [ onClick Increment ] [ text "+" ]
        ]


type Msg
    = Increment
    | Decrement


update : Msg -> ElmuiModel -> ( ElmuiModel, Cmd Msg )
update msg model =
    case msg of
        Increment ->
            ( model + 1, Cmd.none )

        Decrement ->
            ( model - 1, Cmd.none )
