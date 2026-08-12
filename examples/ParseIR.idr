module Main

import LLVM

%default total

irSource : String
irSource = """
define i32 @parse_add(i32 %a, i32 %b) {
entry:
  %sum = add i32 %a, %b
  ret i32 %sum
}
"""

main : IO ()
main = withContext $ \context => do
  parsed <- withParsedIR context irSource moduleIR
  case parsed of
    Left error => putStrLn $ "parse failed: " ++ show error
    Right ir => putStrLn ir
