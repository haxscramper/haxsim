import haxsim/[hl_lexer, hl_parser, hl_eval_ast, hl_eval_stack]
import std/[unittest]

const str0 = """
for i in [1, 2, 3] {
  print(i + 2);
  if ((i + 2) == 4) {
    print("Found 2");
  } else {
    print(i);
  }
}

"""

const str1 = "print(2 + 3 * 4);"
const str = str1

suite "Base tokenizer":
  test "Tokenize":
    let tokens = tokenize(str)
    for tok in tokens:
      echo tok.lispRepr()

suite "Parser":
  test "Parse infix":
    echo tokenize("print(2 + 3 * 4);").parse().treeRepr()
    echo tokenize("print(3 * 4 + 2);").parse().treeRepr()

  test "Parse":
    let tokens = tokenize(str)
    let tree = parse(tokens)
    echo treeRepr(tree)

suite "Eval AST":
  test "Eval AST":
    let tokens = tokenize(str)
    let tree = parse(tokens)
    var ctx: HLAstEvalCtx
    ctx.pushScope()
    discard evalAST(tree, ctx)

suite "Eval stack":
  test "Eval stack":
    let tokens = tokenize(str0)
    let tree = parse(tokens)
    let ops = compileStack(tree)
    var ctx: HLStackEvalCtx
    ctx.pushScope()
    discard evalStack(ops, ctx)
