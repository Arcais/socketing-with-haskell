import System.Environment       ( getArgs )
import System.IO                ( BufferMode(LineBuffering)
                                , Handle
                                , hClose
                                , hFlush
                                , hGetLine
                                , hPutStrLn
                                , hSetBuffering
                                )
import Network                  ( PortID(PortNumber)
                                , Socket
                                , connectTo
                                , accept
                                , listenOn
                                , withSocketsDo
                                )
import System.Console.Haskeline ( runInputT, defaultSettings, getInputChar )

messageListener :: Handle -> String -> IO ()
messageListener handle username = do
  msg <- runInputT defaultSettings $ getInputChar ""
  let input = show (username,msg)
  hPutStrLn handle input
  hFlush handle
  s <- hGetLine handle
  putStrLn s
  messageListener handle username


main :: IO ()
main = withSocketsDo $ do
  args <- getArgs
  let serverHost = head args
  let username   = head $ tail args
  handle <- connectTo serverHost (PortNumber 8181)
  hSetBuffering handle LineBuffering
  messageListener handle username

