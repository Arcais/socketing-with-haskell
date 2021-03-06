import System.Environment ( getArgs )
import Network            ( PortID(PortNumber)
                          , Socket
                          , connectTo
                          , accept
                          , listenOn
                          , withSocketsDo
                          )
import System.IO          ( BufferMode(LineBuffering)
                          , Handle
                          , hFlush
                          , hGetLine
                          , hIsEOF
                          , hPutStrLn
                          , hSetBuffering
                          )
import Control.Concurrent ( forkIO )
import Control.Monad      ( when )

main :: IO ()
main = withSocketsDo $ do

  args <- getArgs
  let serverHost = head args
  let username   = head $ tail args

  socket <- listenOn . PortNumber $ 8181
  print socket
  acceptLoop socket serverHost username

acceptLoop :: Socket -> String -> String -> IO ()
acceptLoop socket serverHost username = do
  (handle, _, _) <- accept socket
  _ <- forkIO $ ioServerLoop handle serverHost username
  acceptLoop socket serverHost username

ioServerLoop :: Handle -> String -> String -> IO ()
ioServerLoop handle serverHost username = do
  hSetBuffering handle LineBuffering
  eof <- hIsEOF handle
  when (not eof) $ do
    s <- hGetLine handle
    putStrLn $ s

    senderHandle <- connectTo serverHost (PortNumber 8181)
    hSetBuffering senderHandle LineBuffering

    msg <- getLine
    let input = show (username,msg)
    hPutStrLn senderHandle input
    hFlush senderHandle
    hPutStrLn handle $ "Sending this back to you: " ++ s
    hFlush handle
    ioServerLoop handle serverHost username

