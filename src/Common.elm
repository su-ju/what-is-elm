module Common exposing (ElmuiModel, HomeModel, Page(..), Route(..))


type alias ElmuiModel =
    Int


type alias HomeModel =
    Int


type Page
    = ElmuiPage ElmuiModel
    | HomePage HomeModel
    | NotFound


type Route
    = HomeRoute
    | ElmuiRoute String
    | ElmuiQuery (Maybe String)
