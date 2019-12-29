module Pages.Elmui exposing (..)

import Common exposing (ElmuiModel)
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Html exposing (Html)
import Html.Events exposing (onClick)
import Style exposing (..)


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
    let
        content =
            column
                [ width fill
                , height fill
                , Background.color (rgb255 255 (model * 10) 0)
                ]
                [ link
                    [ Background.color <| colorBlue
                    , Font.color <| rgb255 255 255 255
                    , width (px 15)
                    , height fill
                    ]
                    { url = "/"
                    , label = Element.text ""
                    }
                , el
                    [ centerX
                    , alignBottom
                    , padding 15
                    , Background.color (rgb255 33 (model * 10) 243)
                    , Font.color (rgb255 255 255 255)
                    , Font.family
                        [ Font.typeface "Futura"
                        , Font.sansSerif
                        ]
                    ]
                    (text <| "Page " ++ String.fromInt model)
                ]
    in
    Element.layout
        []
        content


type Msg
    = Increment
    | Decrement
    | NoOp


update : Msg -> ElmuiModel -> ( ElmuiModel, Cmd Msg )
update msg model =
    case msg of
        Increment ->
            ( model + 1, Cmd.none )

        Decrement ->
            ( model - 1, Cmd.none )

        NoOp ->
            ( model, Cmd.none )
