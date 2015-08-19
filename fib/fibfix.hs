{-# LANGUAGE BangPatterns #-}
module Main (main) where
import Data.List

-- Infinite loop trap
x :: Integer
x = x + 1

-- Fibonnacci sequence with accum. param.
fiba :: Integer
fiba =  fib 300000 0 1
  where fib 0 _ b = b
        fib n !a b = fib (n - 1) b (a + b)
        -- strictify one of fib's accum. param.
 
-- Infinite loop
inf1 = inf x
  where inf n = 0
  -- avoid strictifyig n

-- Fibonnacci sequence with accum. param.
fibb :: Integer
fibb =  fib 300000 0 1
  where fib 0 _ b = b
        fib n !a b = fib (n - 1) b (a + b)
 
-- Infinite loop
inf2 = inf x
  where inf n = 0

-- Fibonnacci sequence with accum. param.
fibc :: Integer
fibc =  fib 300000 0 1
  where fib 0 _ b = b
        fib n !a b = fib (n - 1) b (a + b)
 
-- Infinite loop
inf3 = inf x
  where inf n = 0

-- Fibonnacci sequence with accum. param.
fibd :: Integer
fibd =  fib 300000 0 1
  where fib 0 _ b = b
        fib n !a b = fib (n - 1) b (a + b)

showSum :: IO ()
showSum = print (fiba + fibb + fibc + fibd + inf1 + inf2 + inf3)

main = showSum
