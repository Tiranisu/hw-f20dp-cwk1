---------------------------------------------------------------------------
-- F20DP - Coursework 1
---------------------------------------------------------------------------
-- Mael GRELLIER-NEAU 
-- 1/03/24
---------------------------------------------------------------------------







---------------------------------------------------------------------------
-- Sequential Euler Totient Function
---------------------------------------------------------------------------
-- This program calculates the sum of the totients between a lower and an
-- upper limit.
--
-- Phil Trinder, 26/6/03
-- Based on earlier work by Nathan Charles, Hans-Wolfgang Loidl and
-- Colin Runciman
---------------------------------------------------------------------------

module TotientRange where

-- this is the module with:
--   rpar, parallel strategies for lists, etc.
--
-- See:
-- http://hackage.haskell.org/package/parallel-3.2.2.0/docs/Control-Parallel-Strategies.html
import Control.Parallel.Strategies

-----------------------------------
-- Main functions for Totient Range
-----------------------------------
-- The main function, sumTotient
-- 1. Generates a list of integers between lower and upper
-- 2. Applies Euler function to every element of the list
-- 3. Returns the sum of the results

-- sequential
sumTotientSequential :: (Int, Int) -> Int
sumTotientSequential (lower, upper) =
  sum (totients lower upper)

-- sequential, using evalList strategy
sumTotientEvalList :: (Int, Int) -> Int
sumTotientEvalList (lower, upper) =
  sum (totients lower upper `using` evalList rseq)

-- parallel
sumTotientParallel :: (Int, Int) -> Int
sumTotientParallel (lower, upper) =
  sum (totientsPar_thresh 200 [lower .. upper]) -- Call totientsPar_thresh function with the thresh value and the interval

-- parallel function for fine-tuning the value of thresh to have better performance
sumTotientParallel_thresh :: (Int, Int) -> Int -> Int
sumTotientParallel_thresh (lower, upper) thresh =
  sum (totientsPar_thresh thresh [lower .. upper])




-- TODO: add more sum totient implementations below using the
-- evaluation strategies from the Control.Parallel.Strategies module.
-- Then:
--   1. add them to the bencharmarks in bench/ParallelBenchmarks.hs
--   2. edit the application in app/Main.hs to create a parallel
--      profile for visualising with Threadscope.
--
-- They should always have the same type as the two functions above,
-- to make it easy to add to the bench/ParallelBenchmarks.s file:
--
--   (Int, Int) -> Int

-------------------
-- Totient function
-------------------

-- sequential
totients :: Int -> Int -> [Int]
totients lower upper = map euler [lower, lower + 1 .. upper]


-- V1 of the parallel version but not really an improvement
totientsPar :: (Int, Int) -> [Int]
totientsPar (lower, upper) = runEval $ do
  if lower == upper
    then return [euler lower, 0]
    else do
      a <- rpar (totientsPar (lower+1, upper)) -- Call totientsPar for the next value on an other thread
      b <- rdeepseq (euler lower) -- Calculate euler on the actual thread
      rseq(a) -- Wait for the other thread to finish
      return (b : a)


-- V2 of the parallel version with a big improvement
totientsPar_thresh :: Int -> [Int] -> [Int]
totientsPar_thresh _ [] = [] -- If empty input, return an empty array
totientsPar_thresh thresh list = runEval $ do
  let (listThresh, rest) = splitAt thresh list -- 
  resultPar <- rpar (totientsPar_thresh thresh rest)
  resultLocal <- rdeepseq (map euler listThresh)
  rseq resultPar
  return (resultLocal <> resultPar)


--------
-- euler
--------
-- The euler n function
-- 1. Generates a list [1,2,3, ... n-1,n]
-- 2. Select only those elements of the list that are relative prime to n
-- 3. Returns a count of the number of relatively prime elements

euler :: Int -> Int
euler n = length (filter (relprime n) [1 .. n -1])

-----------
-- relprime
-----------
-- The relprime function returns true if it's arguments are relatively
-- prime, i.e. the highest common factor is 1.

relprime :: Int -> Int -> Bool
relprime x y = hcf x y == 1

------
-- hcf
------
-- The hcf function returns the highest common factor of 2 integers

hcf :: Int -> Int -> Int
hcf x 0 = x
hcf x y = hcf y (rem x y)
