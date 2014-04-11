import Data.Bits
import GHC.Word
import qualified Data.ByteString as BS
import qualified Data.ByteString.Char8 as BSC
import qualified Language.Haskell.TH.Ppr as TP

splitByIndex :: Int -> [a] -> ([a], [a])
splitByIndex ind l = (take ind l, drop ind l)
splitHalf l = splitByIndex (length l `div` 2) l

(.>>.)  x y = shiftR x y
(.<<.)  x y = shiftL x y
(.>>>.) x y = rotateR x y
(.<<<.) x y = rotateL x y

bytes = BS.unpack . BSC.pack
chars = TP.bytesToString

mxor m k = map (\(x, y) -> x `xor` y) $ zip m k

feistel processbranches f (k:ks) m
    | null ks = m2' ++ m1'
    | otherwise = feistel processbranches f ks (m1' ++ m2')
    where 
        (m1, m2) = splitHalf m
        (m1', m2') = processbranches f k m1 m2

processEncode f k m1 m2 = (m1', m2')
    where
        m2' = m1 `mxor` k
        m1' = m2 `mxor` (f k m2') --`mxor` m2

processDecode f k m1 m2 = (m1', m2')
    where
        m2' = m1 `mxor` k
        m1' = m2 `mxor` f k m1 --`mxor` m2

twow8tow16 :: Word8 -> Word8 -> Word16
twow8tow16 x y = ((fromIntegral x) .<<. 8) + (fromIntegral y) 
w16to2w8 :: Word16 -> (Word8, Word8)
w16to2w8 x = (fromIntegral (x .>>. 8), fromIntegral ((x .<<. 8) .>>. 8))
twow16tow32 :: Word16 -> Word16 -> Word32
twow16tow32 x y = ((fromIntegral x) .<<. 16) + (fromIntegral y) 
w32to2w16 :: Word32 -> (Word16, Word16)
w32to2w16 x = (fromIntegral (x .>>. 16), fromIntegral ((x .<<. 16) .>>. 16))
twow32tow64 :: Word32 -> Word32 -> Word64
twow32tow64 x y = ((fromIntegral x) .<<. 32) + (fromIntegral y) 
w64to2w32 :: Word64 -> (Word32, Word32)
w64to2w32 x = (fromIntegral (x .>>. 32), fromIntegral ((x .<<. 32) .>>. 32))

f1 [k1, k2, k3, k4] [m1, m2, m3, m4] = [m1', m2', m3', m4']
    where
        k1' = twow8tow16 k1 k2
        k2' = twow8tow16 k3 k4
        (m1', m2') = w16to2w8 . complement $ (twow8tow16 m3 m4) .>>>. 5
        (m3', m4') = w16to2w8 $ (twow8tow16 m1 m2) .<<<. 7

getKey :: Word64 -> Int -> [Word8]
getKey mainKey i = [k1, k2, k3, k4]
    where 
        (t1, t2) = w32to2w16 $ fromIntegral $ mainKey .<<<. (3 * i) .>>>. 32
        (k1, k2) = w16to2w8 t1
        (k3, k4) = w16to2w8 t2

getKeys mainKey = map (getKey mainKey) [0..9]

groupByLen len [] = []
groupByLen len lst = (take len lst) : groupByLen len (drop len lst)

encode keys m = concatMap (feistel processEncode f1 keys) m'
    where
        rst = (length m) `mod` 8
        additional = if rst > 0 then 8 - rst else 0
        m' = groupByLen 8 (m ++ (bytes $replicate additional  ' '))

decode keys m = concatMap (feistel processDecode f1 (reverse keys)) m'
    where m' = groupByLen 8 m

main = do
    print "Start"
    let key_txt = "qwerty12"
    let (k1:k2:k3:k4:k5:k6:k7:k8:_) = bytes key_txt
    let keys = getKeys ( twow32tow64 (twow16tow32 (twow8tow16 k1 k2) (twow8tow16 k3 k4)) (twow16tow32 (twow8tow16 k5 k6) (twow8tow16 k7 k8)))
    --let txt = "nothing to say\nnothing to do"
    txt <- readFile "spamdata"
    --print $ encode keys $ bytes txt
    --print $ chars $ encode keys $ bytes txt
    print $ length $ chars $ decode keys $ encode keys $ bytes txt

