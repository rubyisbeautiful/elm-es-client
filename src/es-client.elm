import Html exposing (Html,br,button,div,h2,input,option,select,text)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Http as Http
import Json.Decode as Decode
import Table



main =
  Html.program
    { init = init, view = view, update = update, subscriptions = subscriptions  }



-- MODEL


type alias Model =
  { cluster : String
  , connected : Bool
  , errorMsg : String
  , tableState : Table.State
  , indices : List Index
  , rows : List Row
  }


type alias Index =
  { name : String
  }

type alias Row =
  { id : String
  , name : String
  }



init : (Model, Cmd Msg)
init =
  (Model "" False "" (Table.initialSort "Id") [] [], Cmd.none)



-- UPDATE


type Msg
  = Connect
  | Connected (Result Http.Error String)
  | SetTableState Table.State

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Connect ->
      (model, connectToCluster model.cluster)

    Connected (Ok newUrl) ->
      ({ model | connected = True }, Cmd.none)

    Connected (Err err) ->
      ({ model | connected = False, errorMsg = toString err }, Cmd.none)

    SetTableState newTableState ->
      ({ model | tableState = newTableState }, Cmd.none)




-- VIEW


view : Model -> Html Msg
view model =
  div []
    [ h2 [] [
      viewValidation model
    ]
    , input [ type_ "text", placeholder "Cluster URL" ] []
    , button [ onClick Connect ] [ text "Connect" ]
    , div [] [ text model.errorMsg ]
    , br [] []
    , indicesSelect model
    , br [] []
    , dataTable model
    ]


viewValidation : Model -> Html msg
viewValidation model =
  let
    (color, message) =
      if model.connected then
        ("green", "Connected")
      else
        ("red", "Not Connected")
  in
    div [ style [("color", color)] ] [ text message ]


config : Table.Config Row Msg
config =
  Table.config
    {
      toId = .id
    , toMsg = SetTableState
    , columns =
      [ Table.stringColumn "Id" .id
      , Table.stringColumn "Name" .name
      ]
    }


indicesSelect : Model -> Html Msg
indicesSelect model =
  div [] [
    select [] (List.map (\_ -> option [] [ text "yo" ]) model.indices)
  ]

dataTable : Model -> Html Msg
dataTable model =
  div [] [
    Table.view config model.tableState model.rows
  ]


-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none



-- HTTP


connectToCluster : String -> Cmd Msg
connectToCluster url =
  Http.send Connected (Http.get (url ++ "/_cluster/state/metadata") decodeUrl)

decodeUrl : Decode.Decoder String
decodeUrl =
  Decode.at ["metadata"]["indices"] Decode.dict
