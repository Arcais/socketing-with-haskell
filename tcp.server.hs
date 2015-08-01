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
  socket <- listenOn . PortNumber $ 8181
  print socket
  acceptLoop socket

acceptLoop :: Socket -> IO ()
acceptLoop socket = do
  (handle, _, _) <- accept socket
  _ <- forkIO $ ioServerLoop handle
  acceptLoop socket

ioServerLoop :: Handle -> IO ()
ioServerLoop handle = do
  hSetBuffering handle LineBuffering
  eof <- hIsEOF handle
  when (not eof) $ do
    s <- hGetLine handle
    putStrLn $ s
    hPutStrLn handle $ "Sending this back to you: " ++ s
    hFlush handle
    ioServerLoop handle

