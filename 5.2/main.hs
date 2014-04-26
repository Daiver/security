import Control.Monad
import Data.Bitmap.Base
import Codec.Image.STB
import Data.Bitmap.Pure.Pixels
import Data.Bits

flip1 = flip xor (1::Int)
flipn1 x 
    | odd x = x + 1
    | otherwise = x - 1

mean x = sum x / fromIntegral (length x)
std l = (sum $ map (\x -> (^2) $ fromIntegral x - mean l) l) / mean l

cutBlocks :: Bitmap Word8 -> Int -> [[Word8]]
cutBlocks img block_size = map readBlock $ indxs block_size w h
    where
        (w,h) = bitmapSize img
        indxs b w h = [(x, y)| x <- [0, b .. w - 1], y <- [0, b .. h - 1]]
        readBlock (x, y) = map (\(i, j) -> fromIntegral . head $ 
                                unsafeReadPixel img (i + x, j + y)) $ 
                            indxs 1 block_size block_size

calcComp :: [Float] -> [Float] -> (Int, Int)
calcComp b1 b2 = (divide (>), divide (<))
    where divide f = length . filter (\(x, y) -> f x y) $ zip b1 b2

calcRS img = (calcComp b1 b2, calcComp b1 b3)
    where
        blocks = cutBlocks img 8
        comp f = map (\x -> std $ map (fromIntegral . f . fromIntegral . toInteger) x) blocks
        b1 = comp flip1 --(id::Int -> Int)
        b2 = comp flip1
        b3 = comp flipn1

main = do
    res <- loadImage "../5/0010.bmp"
    case res of
        (Left x) -> print "Err" >> print x
        (Right x) -> do
            let i = bitmap1 x
            let s = bitmapSize x
            print s
            print $ cutBlocks x 8
            print $ length $ cutBlocks x 8
