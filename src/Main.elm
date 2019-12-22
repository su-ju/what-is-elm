module Main exposing (main)

import Browser exposing (Document)
import Browser.Navigation as Nav
import Html exposing (Html, a, footer, h1, li, nav, text, ul)
import Html.Attributes exposing (classList, href)
import Html.Lazy exposing (lazy)
import Pages.Elmui as Elmui
import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser, s, string)


type alias Model =
    { page : Page
    , key : Nav.Key
    }


type Page
    = ElmuiPage Elmui.Model
    | HomePage
    | NotFound


type Route
    = HomeRoute
    | ElmuiRoute


view : Model -> Document Msg
view model =
    let
        content =
            case model.page of
                ElmuiPage elmui ->
                    Elmui.view elmui
                        |> Html.map GotElmuiMsg

                HomePage ->
                    text "HomePage"

                NotFound ->
                    text "Not Found"
    in
    { title = "Photo Groove, SPA Style"
    , body =
        [ lazy viewHeader model.page
        , content
        , viewFooter
        ]
    }


viewHeader : Page -> Html Msg
viewHeader page =
    let
        logo =
            h1 [] [ text "Photo Groove" ]

        links =
            ul []
                [ navLink HomeRoute { url = "/", caption = "Home" }
                , navLink ElmuiRoute { url = "/elmui", caption = "Elmui" }
                ]

        navLink : Route -> { url : String, caption : String } -> Html msg
        navLink route { url, caption } =
            li [ classList [ ( "active", isActive { link = route, page = page } ) ] ]
                [ a [ href url ] [ text caption ] ]
    in
    nav [] [ logo, links ]


parser : Parser (Route -> a) a
parser =
    Parser.oneOf
        [ Parser.map HomeRoute Parser.top
        , Parser.map ElmuiRoute (s "elmui")
        ]


isActive : { link : Route, page : Page } -> Bool
isActive { link, page } =
    case ( link, page ) of
        ( HomeRoute, HomePage ) ->
            True

        ( HomeRoute, _ ) ->
            False

        ( ElmuiRoute, ElmuiPage _ ) ->
            True

        ( ElmuiRoute, _ ) ->
            False


viewFooter : Html msg
viewFooter =
    footer [] [ text "One is never alone with a rubber duck. -Douglas Adams" ]


type Msg
    = ClickedLink Browser.UrlRequest
    | ChangedUrl Url
    | GotElmuiMsg Elmui.Msg


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


toFolders : Model -> ( Elmui.Model, Cmd Elmui.Msg ) -> ( Model, Cmd Msg )
toFolders model ( folders, cmd ) =
    ( { model | page = ElmuiPage folders }
    , Cmd.map GotElmuiMsg cmd
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
            ( { model | page = HomePage }, Cmd.none )

        Just ElmuiRoute ->
            toFolders model (Elmui.init ())

        Nothing ->
            ( { model | page = NotFound }, Cmd.none )
