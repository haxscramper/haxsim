import haxsim/[clexer, cparser]
import std/[unittest]

const str = """
for(int i = 0; 10; i) {
  puts("123");
  Test auql;
  auql.zzz;
}
"""

suite "Base tokenizer":
  test "Tokenize":
    let tokens = tokenize(str)
    for tok in tokens:
      echo tok.lispRepr()

  test "Parse":
    let tokens = tokenize(str)
    let tree = parse(tokens)
    echo treeRepr(tree)
