---------------------------------------------------------------------------
-- F20DP - Coursework 1
---------------------------------------------------------------------------
-- Mael GRELLIER-NEAU 
-- 1/03/24
---------------------------------------------------------------------------


module Main where

import Control.DeepSeq
import Control.Exception
import Criterion.Measurement
import Numeric
import System.Environment
import TotientRange


{-
On a normal computer:

    cabal build

then:

    cabal exec -- haskell-totient 1 10000

On the Robotarium e.g. using 4 CPU cores on a compute node:

    cabal build

then:

    srun --cpus-per-task=4 cabal exec -- haskell-totient 1 10000 +RTS -N4 -RTS

To check that your code produces the correct output,
uncomment and use the `main` function at the bottom.
To measure your runtime in seconds, uncomment and use
the `main` function directly beneat this comment.
-}

-- | time an IO action.
time_ :: IO a -> IO Double
time_ act = do
  initializeTime
  start <- getTime
  _ <- act
  end <- getTime
  return $! end - start

-- | use this function to print the execution time, in seconds.
main :: IO ()
main = do
    args <- getArgs
    let lower = read (head args) :: Int -- lower limit of the interval
        upper = read (args !! 1) :: Int -- upper limit of the interval

    -- Test or the seauential version
        theProgram = sumTotientSequential (lower, upper)
    theTime <- time_ (evaluate (force theProgram))
    putStrLn (showFFloat (Just 6) theTime "")
    putStrLn
        ( "Sum of Totients between ["
            ++ show lower
            ++ ".."
            ++ show upper
            ++ "] is "
            ++ show theProgram
        )

    -- Test for the Parallel function
    let theProgramPar = sumTotientParallel (lower, upper)
    theTimePar <- time_ (evaluate (force theProgramPar))
    putStrLn (showFFloat (Just 6) theTimePar "")
    putStrLn
        ( "Sum of Totients between using haskell ["
            ++ show lower
            ++ ".."
            ++ show upper
            ++ "] is "
            ++ show theProgramPar
        )

