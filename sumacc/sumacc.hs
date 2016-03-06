{-# LANGUAGE BangPatterns #-}

ns = [1..9999999]
ns' = [1..9]

sum' :: [Integer] -> Integer -> Integer -> Integer
sum' [] n m = n
sum' (x:xs) !n m = sum' xs (x + n) (sum'' ns' n)

{- the bang before m is better than no bang at all, but needs to be rid of
when there's a bang before n. In other words, the performance ranking is: 
best = !n m, middle = n !m and !n !m, worst = n m. The reason is, m plugs 
the thunk leak in n but does extra computation for sum''. The best stratgy 
only bangs n. 
-}

sum'' :: [Integer] -> Integer -> Integer
sum'' [] n = n
sum'' (x:xs) !n = sum'' xs (x + n) 

ans = sum' ns 0 0

main = do
    putStrLn $ show ans

