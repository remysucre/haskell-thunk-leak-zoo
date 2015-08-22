#Thunk Leaks & Treatments

To enable strictness annotation, put `{-# LANGUAGE BangPatterns #-}` at top of source. Detailed profiles and full programs are found in linked directories at the top of each example. To profile, `cd` to directory and `bash run.sh program` where `program.hs` is source. 

##fibonacci w/ accumulating parameter

[`fib`](../tree/master/fib) demonstrates how a Fibonacci sequence implemented with accumulating parameters causes thunk leak: 

```haskell
fib :: Int -> Integer -> Integer -> Integer
fib 0 _ b = b
fib n a b = fib (n - 1) b (a + b)
```

where `a` and `b` serve as accumulating parameters and will leak space if evaluated lazily. Add strictness before either `a` or `b` to fix. 

```haskell
fib :: Int -> Integer -> Integer -> Integer
fib 0 _ b = b
fib n !a b = fib (n - 1) b (a + b) -- bang a
```

##length w/ accumulating parameter

[`length`](../tree/master/length) demonstrates how a length function implemented with accumulating parameters causes thunk leak: 

```haskell
f :: [a] -> Int -> Int
f [] c = c
f (x : xs) c = f xs (c + 1)
```

where `c` serve as accumulating parameters and will leak space if evaluated lazily. Add strictness on `c` to fix. 

```haskell
f :: [a] -> Int -> Int
f [] c = c
f (x : xs) !c = f xs (c + 1) -- bang c
```

##lazy monad bind

In [`monad`](../tree/master/monad/). When threading data, e.g. a state, monads can cause thunk leak when `>>=` evaluates the threaded data lazily: 

```haskell
instance Monad Thunk where
  T (x, n) >>= f =
    let T (x', m) = f x
    in T (x', m + n)
  return x = T (x, 0)
```

where `n` in `T (x, n)` threads data along computation and can leak space. Add strictness to `x` and `n` to fix. 

```haskell
instance Monad Thunk where
  T (!x, !n) >>= f = -- bang x & n
    let T (x', m) = f x
    in T (x', m + n)
  return x = T (x, 0)
```

##recursively defined data
[`recurse`](../tree/master/recurse): recursively defined data, usually infinite, can cause thunk leak: 

```haskell
u = 0 : go (head u) (tail u)
go a as = a + 1 : go (head as) (tail as)
```

where thunks of `+` operation builds up in `a + 1`. To fix, add strictness before `a`: 

```haskell
u = 0 : go (head u) (tail u)
go !a as = a + 1 : go (head as) (tail as) -- bang a
```

##sum w/ accumulating parameter
[`sumacc`](../tree/master/sumacc) is another instance of thunk leak caused by accumulating parameter: 

```haskell
sum' :: [Integer] -> Integer -> Integer
sum' [] n = n 
sum' (x:xs) n = sum' xs (x + n)
```

where the 2nd argument to sum' `n` leaks space. Add strictness to 'n' to fix. 

```haskell
sum' :: [Integer] -> Integer -> Integer
sum' [] n = n 
sum' (x:xs) !n = sum' xs (x + n) -- bang n
```

##lazy MVar in concurrency
[`thread`](../tree/master/thread) contains a lazily evaluated `MVar` which leaks space: 

```haskell
upgraderThread :: MVar [Int] -> Int -> IO ()
upgraderThread chanMVar 0 = do
  ns <- readMVar chanMVar
  print ns
upgraderThread chanMVar n = do job 
    where
        job = do
            vlist <- takeMVar chanMVar
            let reslist = strictList $ map id vlist
            putMVar chanMVar reslist
            upgraderThread chanMVar (n - 1)

        strictList xs = if all p xs then xs else []
            where p x = x `seq` True
```

where `map` builds up thunk in `MVar`. add strictness on `reslist` to fix: 

```haskell
upgraderThread :: MVar [Int] -> Int -> IO ()
upgraderThread chanMVar 0 = do
  ns <- readMVar chanMVar
  print ns
upgraderThread chanMVar n = do job 
    where
        job = do
            vlist <- takeMVar chanMVar
            let !reslist = strictList $ map id vlist -- bang reslist
            putMVar chanMVar reslist
            upgraderThread chanMVar (n - 1)

        strictList xs = if all p xs then xs else []
            where p x = x `seq` True
```

##tick w/ accumulating parameter
[`tick`](../tree/master/tick/) is yet another specimen of thunk leak caused by accumulating parameter. 

```haskell
f [] c = c 
f (x : xs) c = f xs (uncurry (tick x) c)
tick x c0 c1
  | even x = (c0, c1 + 1)
  | otherwise = (c0 + 1, c1) 
```

we have to add strictness to `c`, `c0` and `c1` to solve the leak

```haskell
f [] c = c 
f (x : xs) !c = f xs (uncurry (tick x) c) -- bang c
tick x !c0 !c1 -- bang c0 & c1
  | even x = (c0, c1 + 1)
  | otherwise = (c0 + 1, c1) 
```
