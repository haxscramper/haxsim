import haxsim/[hl_lexer, hl_parser, hl_eval_ast]
import std/[unittest]

const str = """
for i in [1, 2, 3] {
  print(i);
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

  test "Eval":
    let tokens = tokenize(str)
    let tree = parse(tokens)
    var ctx: HLEvalCtx
    ctx.pushScope()
    discard evalAST(tree, ctx)
