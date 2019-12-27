module Main exposing (main)

import Browser exposing (Document)
import Browser.Events exposing (onKeyDown)
import Browser.Navigation as Nav
import Common exposing (ElmuiModel, HomeModel, Page(..), Route(..))
import Html exposing (Html, text)
import Json.Decode as Decode
import Pages.Elmui as Elmui
import Pages.Home as Home
import Url exposing (Url)
import Url.Builder as Builder
import Url.Parser as Parser exposing ((<?>), Parser, s, string)
import Url.Parser.Query as Query


type alias Model =
    { page : Page
    , key : Nav.Key
    , url : Url
    }


view : Model -> Document Msg
view model =
    let
        content =
            case model.page of
                ElmuiPage elmui ->
                    Elmui.view elmui
                        |> Html.map GotElmuiMsg

                HomePage home ->
                    Home.view home
                        |> Html.map GotHomePageMsg

                NotFound ->
                    text "Not Found"
    in
    { title = "What is elm?"
    , body =
        [ content ]
    }


parser : Parser (Route -> a) a
parser =
    Parser.oneOf
        [ Parser.map HomeRoute Parser.top
        , Parser.map ElmuiQuery (s "elmui" <?> Query.string "q")
        ]


type Msg
    = ClickedLink Browser.UrlRequest
    | ChangedUrl Url
    | GotElmuiMsg Elmui.Msg
    | GotHomePageMsg Home.Msg
    | Increment
    | Decrement
    | NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ClickedLink urlRequest ->
            case urlRequest of
                Browser.External href ->
                    ( model, Nav.load href )

                Browser.Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )

        Increment ->
            let
                incremented val =
                    case String.toInt val of
                        Just v ->
                            String.fromInt (v + 1)

                        Nothing ->
                            "1"
            in
            case Parser.parse parser model.url of
                Just (ElmuiQuery (Just val)) ->
                    ( model, Nav.pushUrl model.key (Builder.relative [ model.url.path ] [ Builder.string "q" (incremented val) ]) )

                Just (ElmuiQuery Nothing) ->
                    ( model, Nav.pushUrl model.key (Builder.relative [ model.url.path ] [ Builder.string "q" "1" ]) )

                Nothing ->
                    ( model, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        Decrement ->
            let
                buildQuery val =
                    case String.toInt val of
                        Just v ->
                            let
                                res =
                                    v - 1
                            in
                            if res > 0 then
                                [ Builder.string "q" (String.fromInt res)
                                ]

                            else
                                []

                        Nothing ->
                            []
            in
            case Parser.parse parser model.url of
                Just (ElmuiQuery (Just val)) ->
                    ( model, Nav.pushUrl model.key (Builder.relative [ model.url.path ] (buildQuery val)) )

                Just (ElmuiQuery Nothing) ->
                    ( model, Nav.pushUrl model.key (Builder.relative [ model.url.path ] []) )

                Nothing ->
                    ( model, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        NoOp ->
            ( model, Cmd.none )

        ChangedUrl url ->
            updateUrl
                url
                model

        GotElmuiMsg foldersMsg ->
            case model.page of
                ElmuiPage folders ->
                    toFolders model (Elmui.update foldersMsg folders)

                _ ->
                    ( model, Cmd.none )

        GotHomePageMsg foldersMsg ->
            case model.page of
                HomePage folders ->
                    toHome model (Home.update foldersMsg folders)

                _ ->
                    ( model, Cmd.none )


toFolders : Model -> ( ElmuiModel, Cmd Elmui.Msg ) -> ( Model, Cmd Msg )
toFolders model ( folders, cmd ) =
    ( { model | page = ElmuiPage folders }
    , Cmd.map GotElmuiMsg cmd
    )


toHome : Model -> ( HomeModel, Cmd Home.Msg ) -> ( Model, Cmd Msg )
toHome model ( home, cmd ) =
    ( { model | page = HomePage home }
    , Cmd.map GotHomePageMsg cmd
    )


main : Program Float Model Msg
main =
    Browser.application
        { init = init
        , onUrlChange = ChangedUrl
        , onUrlRequest = ClickedLink
        , subscriptions = subscriptions
        , update = update
        , view = view
        }


init : Float -> Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    updateUrl url { page = NotFound, key = key, url = url }


subscriptions : Model -> Sub Msg
subscriptions model =
    case model.page of
        ElmuiPage elmui ->
            onKeyDown keyDecoder

        _ ->
            Sub.none


updateUrl : Url -> Model -> ( Model, Cmd Msg )
updateUrl url model =
    case Parser.parse parser url of
        Just HomeRoute ->
            ( { model | page = HomePage 10 }, Cmd.none )

        Just (ElmuiQuery Nothing) ->
            ( { model | page = ElmuiPage (Elmui.createModel "0"), url = url }, Cmd.none )

        Just (ElmuiQuery (Just val)) ->
            ( { model | page = ElmuiPage (Elmui.createModel val), url = url }, Cmd.none )

        Nothing ->
            ( { model | page = NotFound, url = url }, Cmd.none )


keyDecoder : Decode.Decoder Msg
keyDecoder =
    Decode.map toDirection (Decode.field "key" Decode.string)


toDirection : String -> Msg
toDirection string =
    case string of
        "ArrowLeft" ->
            Decrement

        "ArrowRight" ->
            Increment

        _ ->
            NoOp
