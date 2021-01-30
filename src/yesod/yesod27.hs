{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeFamilies #-}
import Yesod

data App = App

mkYesod "App" [parseRoutes|
    / HomeR GET
    /setname SetNameR GET POST
    /sayhello SayHelloR GET
|]

instance Yesod App

instance RenderMessage App FormMessage where
    renderMessage _ _ = defaultFormMessage

getHomeR :: Handler Html
getHomeR = defaultLayout
    [whamlet|
        <p>
            <a href=@{SetNameR}>Set your name
        <p>
            <a href=@{SayHelloR}>Say hello
    |]

getSetNameR :: Handler Html
getSetNameR = defaultLayout
    [whamlet|
        <form method=post>
            My name is #
            <input type=text name=name>
            . #
            <input type=submit value="Set name">
    |]

postSetNameR :: Handler ()
postSetNameR = do
    name <- runInputPost $ ireq textField "name"
    setSession "name" name
    redirectUltDest HomeR

getSayHelloR :: Handler Html
getSayHelloR = do
    mname <- lookupSession "name"
    case mname of
        Nothing -> do
            setUltDestCurrent
            setMessage "Please tell me your name"
            redirect SetNameR
        Just name -> defaultLayout [whamlet|<p>Welcom #{name}|]

main :: IO ()
main = warp 3000 App


