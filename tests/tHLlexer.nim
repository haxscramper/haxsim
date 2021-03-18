import haxsim/[
  hl_lexer, hl_parser, hl_eval_ast, hl_eval_stack, hl_semcheck
]

import std/[unittest]

const str0 = """



  proc test(arg: int) {

}

for i in [1, 2, 3] {
  print(i + 2);
  if ((i + 2) == 4) {
    print("Found 2");
  } else {
    print(i);
  }
}

var arr = [1, 2, 3];
arr[1] = 90;
print(arr[0]);

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
    discard tokenize("print(2 + 3 * 4);").parse()
    discard tokenize("print(3 * 4 + 2);").parse()

  test "Parse":
    let tokens = tokenize(str0)
    for tok in tokens:
      stdout.write tok.lispRepr() & " "
    let tree = parse(tokens)
    echo treeRepr(tree)

suite "Eval AST":
  test "Eval AST":
    let tokens = tokenize(str0)
    let tree = parse(tokens)
    var ctx: HLAstEvalCtx
    ctx.pushScope()
    discard evalAST(tree, ctx)

suite "Eval stack":
  test "Eval stack":
    let tokens = tokenize(str0)
    var tree = parse(tokens)

    block:
      var ctx = HLSemContext()
      ctx.pushScope()
      ctx.procTable = newProcTable()
      updateTypes(tree, ctx)

    echo treeRepr(tree)

    let ops = compileStack(tree)
    var ctx = newStackEvalCtx()
    ctx.pushScope()
    discard evalStack(ops, ctx)
