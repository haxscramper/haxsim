import haxsim/[hl_lexer, hl_parser, hl_eval_ast, hl_eval_stack]
import std/[unittest]

const str = """
for i in [1, 2, 3] {
  print(i + 2);
  if ((i + 2) == 4) {
    print("Found 2");
  } else {
    print(i);
  }
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

  test "Eval AST":
    let tokens = tokenize(str)
    let tree = parse(tokens)
    var ctx: HLAstEvalCtx
    ctx.pushScope()
    discard evalAST(tree, ctx)

  test "Eval stack":
    let tokens = tokenize(str)
    let tree = parse(tokens)
    var ctx: HLStackEvalCtx
    ctx.pushScope()
    discard evalStack(tree, ctx)
