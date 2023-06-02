module SignInModel exposing (SignInModel, SignInMsg(..))

import Browser.Navigation as N
import Client exposing (Client)
import Http


type alias SignInModel =
    { client : Client
    , navKey : N.Key
    , submitting : Bool
    }


type SignInMsg
    = NoOp
    | GotClientId String
    | InputEmail String
    | InputPassword String
    | DismissKeyboard
    | Submit
    | SubmitResponse (Result Http.Error Client)
