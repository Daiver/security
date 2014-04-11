import Data.List
import Data.Maybe
import System.Random
import Data.FixedPoint
import GHC.Word
import Math.NumberTheory.Primes.Counting
import Math.NumberTheory.Primes.Testing
import qualified Data.ByteString as BS
import qualified Data.ByteString.Char8 as BSC
import qualified Language.Haskell.TH.Ppr as TP
import Data.Char
import Numeric
import Data.Bits

unpackWord item_bits x = unfoldr f (x, shift_bits)
    where 
        shift_bits = (bitSize x `div` item_bits) -1 
        f (b, i) 
            | i == -1 = Nothing
            | otherwise = Just (
                fromIntegral $ 
                    shiftR 
                        (shiftL b (((shift_bits - i) * item_bits))) 
                        (shift_bits * item_bits)
                , (b, i - 1))

packWord x = foldl f 0 $ zip x (reverse [0..(length x) - 1])
    where 
        item_bits = bitSize $ head x
        f r (x, i) = r + (shiftL  (fromIntegral x) (i * item_bits)) -- * 2^(i*64) 

bytes = BS.unpack . BSC.pack
chars = TP.bytesToString

groupByLength _ [] = []
groupByLength l li = (take l li) : (groupByLength l $ drop l li)

prep :: [Word64] -> [Integer]
prep = map packWord . groupByLength 8 --(packWord $ take 8 l):(prep $ drop 8 l)

align a b x = a + (x `mod` b)

invm :: Integer -> Integer -> Integer
invm m a
    | g /= 1 = error "No inverse exists"
    | otherwise = x `mod` m
    where (g,x,_) = gcde a m

expm :: Integer -> Integer -> Integer -> Integer
expm m b k =
    let
        ex a k s
            | k == 0 = s
            | k `mod` 2 == 0 = ((ex (a*a `mod` m)) (k `div` 2)) s
            | otherwise = ((ex (a*a `mod` m)) (k `div` 2)) (s*a `mod` m)
    in ex b k 1

primeTest :: [Integer] -> [(Integer, Integer)]
primeTest (n:a:xs) -- = (1,1)
        | n' `mod` a' == 0  = (n', a') : primeTest xs
        | a' > 10 && millerRabinV 196 n' && isFermatPP n' a' 
            && isStrongFermatPP n' a' && bailliePSW n'  = [(n', a')]
        | otherwise       = (n', a') : primeTest (n:xs)
    where
        n' = if n `mod` 2 == 0 then n + 1 else n
        a' = n' `mod` a--align 0 (n' `div` 2) a

genRSAKey :: Integer -> Integer -> (RSAPrivateKey,RSAPublicKey)
genRSAKey p q =
    let
        phi = (p-1)*(q-1)
        n = p*q
        e = find (phi `div` 5) -- 6, 5, 4
        d = invm phi e
        find x
            | g == 1 = x
            | otherwise = find ((x+1) `mod` phi)
            where (g,_,_) = gcde x phi
    in
        (PRIV n d,PUB n e)

gcde :: Integer -> Integer -> (Integer,Integer,Integer)
gcde a b =
    let
        gcd_f (r1,x1,y1) (r2,x2,y2)
            | r2 == 0 = (r1,x1,y1)
            | otherwise =
            let
                q = r1 `div` r2
                r = r1 `mod` r2
            in
                gcd_f (r2,x2,y2) (r,x1 - q * x2, y1 - q*y2)
        (d,x,y) = gcd_f (a,1,0) (b,0,1)
    in
        if d < 0
        then (-d, -x, -y)
        else (d,x,y)

data RSAPublicKey = PUB Integer Integer deriving Show
data RSAPrivateKey = PRIV Integer Integer deriving Show

ersa :: RSAPublicKey -> Integer -> Word1024
ersa (PUB n e) x =  fromIntegral $ expm n x e

drsa :: RSAPrivateKey -> Integer -> Word1024
drsa (PRIV n d) x = fromIntegral $ expm n x d

do_rsa func = concatMap (chars . unpackWord 8 . func . fromIntegral . pcked) 
    . groupByLength 128 . bytes 
    where pcked = packWord :: [Word8] -> Word1024

e_rsa pub = do_rsa (ersa pub)
d_rsa priv = do_rsa (drsa priv)

textAlign n txt = txt ++ replicate additional ' '
    where
        rst = (length txt) `mod` n
        additional = if rst > 0 then n - rst else 0

testKeys (priv, pub) = foldr1 (&&) . map inner $ set
    where
        inner word = 
            let
                txt = textAlign 128 word
                enc = e_rsa pub txt
                dnc = d_rsa priv enc
            in dnc == txt && enc /= txt
                
        set = ["nope", "nothing", "ifoiwefoihweifuhwieuhfieuhfiuwehfuihwefuihweiufhiw"
            ++ "fweijfoeijfoiwejfijsldkfjsldkjflsdkjfijewofiwjeofijweijfwoeijfowwiejf" 
            ++ "123qweasd", "123qweasd",
            "Hi its Kate how is your evening? I hope i can see you "]

bruteGoodKeys = do
    g1 <- newStdGen 
    g2 <- newStdGen 
    let 
        extractPrime = fst . last . primeTest . prep . randoms
        (priv, pub) = genRSAKey (extractPrime g1) (extractPrime g2)
    if testKeys (priv, pub) --dnc == txt && enc /= txt
        then return (priv, pub)
    else do
        ans <- bruteGoodKeys
        return ans

computeRSAKey phi e =
    let
        --phi = (p-1)*(q-1)
        (g,_,_) = gcde e phi
        n = 0
        d = invm phi e
    in
        if (g /= 1)
        then error "Public exponent not acceptable"
        else (PRIV n d,PUB n e)


main = do
    {-(priv, pub) <- bruteGoodKeys
    print (priv, pub)
    orig_txt <- readFile "data"
    let txt = textAlign 128 orig_txt --"haskell"
    let pckedTxt = packWord $ bytes txt :: Word1024
    let enc = e_rsa pub txt
    let dnc = d_rsa priv enc
    print "Encoded"
    print enc
    print "Decoded"
    print dnc
    print $ (length enc, length dnc)
    print $ dnc == txt-}
    -- 2432371 212885833
    print $ computeRSAKey 471090588977520 12377
    --print $ computeRSAKey 517817111181840 12331
    --print $ computeRSAKey 565569710361496 12341
    --print $ computeRSAKey ((2432363 - 1)*(212885833 - 1)) 12371
    --print $ computeRSAKey 517817111181840 12331
    --print $ computeRSAKey 471110347164960 12397
    --print $ filter (\x -> x `mod` 491383914273672 == 1) . map (*12977) $ [37865755897..37865755897 + 10000000000]

