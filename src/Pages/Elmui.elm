module Pages.Elmui exposing (..)

import Browser
import Browser.Events exposing (onKeyDown)
import Common exposing (ElmuiModel, Page, Route)
import Html exposing (..)
import Html.Events exposing (..)
import Json.Decode as Decode


type Direction
    = Left
    | Right
    | Other


keyDecoder : Decode.Decoder Msg
keyDecoder =
    Decode.map toDirection (Decode.field "key" Decode.string)


toDirection : String -> Msg
toDirection string =
    case string of
        "ArrowLeft" ->
            Increment

        "ArrowRight" ->
            Decrement

        _ ->
            NoOp


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
    | NoOp


subscriptions : ElmuiModel -> Sub Msg
subscriptions model =
    onKeyDown keyDecoder


update : Msg -> ElmuiModel -> ( ElmuiModel, Cmd Msg )
update msg model =
    case msg of
        Increment ->
            ( model + 1, Cmd.none )

        Decrement ->
            ( model - 1, Cmd.none )

        NoOp ->
            ( model, Cmd.none )
