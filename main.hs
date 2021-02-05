-- compile and run 
-- ghc --make -dynamic main.hs 

module Main where
import Text.ParserCombinators.Parsec hiding (spaces)
import System.Environment
import Control.Monad
import Numeric

data LispVal = Atom String
             | List  [LispVal]
             | DottedList [LispVal] LispVal
             | Number Integer
             | Float Float
             | String String
             | Bool Bool
             deriving Show

parseString :: Parser LispVal
parseString = do 
                char '"'
                x <- many (noneOf "\"")
                char '"'
                return $ String x

parseAtom :: Parser LispVal
parseAtom = do
            first <- letter <|> symbol
            rest <- many (letter <|> digit <|> symbol)
            let atom = first:rest
            return $ case atom of
                        "#t" -> Bool True
                        "#f" -> Bool False
                        _    -> Atom atom

parseNumber :: Parser LispVal
parseNumber = do
    x <- many1 digit
    return $ Number $ read x
-- parseNumber = liftM (Number . read) $ many1 digit

parseFloat :: Parser LispVal
parseFloat = do
    x <- many1 digit 
    char '.' 
    y <- many1 digit
    let atom = (x ++ "." ++ y)
    return $ Float $ read atom

parseExpr :: Parser LispVal
parseExpr = parseAtom
         <|> parseString
         <|> try parseFloat
         <|> parseNumber
         <|> parseQuoted
         <|> do char '('
                x <- try parseList <|> parseDottedList
                char ')'
                return x

parseList :: Parser LispVal
parseList = liftM List $ sepBy parseExpr space

parseDottedList :: Parser LispVal
parseDottedList = do
    head <- endBy parseExpr space
    tail <- char '.' >> spaces >> parseExpr
    return $ DottedList head tail

parseQuoted :: Parser LispVal
parseQuoted = do 
    char '\''
    x <- parseExpr
    return $ List [Atom "quote", x]


spaces :: Parser ()
spaces = skipMany1 space 

symbol :: Parser Char
symbol = oneOf "!#$%&|*+-/:<=>?@^_~"

readExpr :: String -> LispVal
readExpr input = case parse parseExpr "lisp" input of
    Left err -> String $ "No match: " ++ show err
    Right val -> val

primitives :: [(String,[LispVal] -> LispVal)]
primitives = [("+",numericBinop (+)),
            ("-",numericBinop (-)),
            ("*",numericBinop (*)),
            ("/",numericBinop  div),
            ("mod",numericBinop mod),
            ("quotient",numericBinop quot),
            ("remainder",numericBinop rem)]

numericBinop :: (Integer -> Integer -> Integer) -> [LispVal] -> LispVal
numericBinop op params = Number $ foldl1 op $ map unpackNum params

unpackNum :: LispVal -> Integer
unpackNum (Number n) = n
unpackNum (String n) = let parsed = reads n :: [(Integer,String)] in 
                        if null parsed
                            then 0
                            else fst $ parsed !! 0
unpackNum (List [n]) = unpackNum n
unpackNum _ = 0


apply :: String -> [LispVal] -> LispVal
apply func args = maybe (Bool False) ($ args) $ lookup func primitives



-- evaluator
eval :: LispVal -> LispVal
eval val@(String _) = val
eval val@(Number _) = val
eval val@(Bool _) = val 
eval (List [Atom "quote", val]) = val 
eval (List (Atom func : args)) = apply func $ map eval args

main :: IO ()
main = do
    (expr:_) <- getArgs
    putStrLn $ show $ eval $ readExpr expr