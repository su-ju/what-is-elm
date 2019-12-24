module Main exposing (main)

import Browser exposing (Document)
import Browser.Navigation as Nav
import Common exposing (ElmuiModel, HomeModel, Page(..), Route(..))
import Html exposing (Html, a, footer, h1, li, nav, text, ul)
import Html.Attributes exposing (classList, href)
import Html.Lazy exposing (lazy)
import Pages.Elmui as Elmui
import Pages.Home as Home
import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser, s, string)


type alias Model =
    { page : Page
    , key : Nav.Key
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
        , Parser.map ElmuiHomeRoute (s "elmui")
        , Parser.map ElmuiRoute (s "elmui" </> Parser.string)
        ]


type Msg
    = ClickedLink Browser.UrlRequest
    | ChangedUrl Url
    | GotElmuiMsg Elmui.Msg
    | GotHomePageMsg Home.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ClickedLink urlRequest ->
            case urlRequest of
                Browser.External href ->
                    ( model, Nav.load href )

                Browser.Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )

        ChangedUrl url ->
            updateUrl url model

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
    updateUrl url { page = NotFound, key = key }


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


updateUrl : Url -> Model -> ( Model, Cmd Msg )
updateUrl url model =
    case Parser.parse parser url of
        Just HomeRoute ->
            ( { model | page = HomePage 10 }, Cmd.none )

        Just (ElmuiRoute val) ->
            ( { model | page = ElmuiPage (Elmui.createModel val) }, Cmd.none )

        Just ElmuiHomeRoute ->
            ( { model | page = ElmuiPage (Elmui.createModel "0") }, Cmd.none )

        -- toFolders model (Elmui.init ())
        Nothing ->
            ( { model | page = NotFound }, Cmd.none )
