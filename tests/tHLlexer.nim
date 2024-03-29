import haxsim/[
  hl_lexer,
  hl_parser,
  hl_eval_ast,
  hl_eval_stack,
  hl_semcheck,
  hl_eval_register
]


import hmisc/core/all
import hmisc/preludes/unittest

const str0 = """
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

var table = new Table;
table[12] = 2;
print(table[12]);

"""

const str1 = "print(2 + 3 * 4);"
const str = str1

suite "Empty test":
  test "z":
    discard

suite "Data structures":
  test "Table":
    var t = newHLTable()
    for k in 0 .. 4:
      t[initHLValue(k)] = initHLValue(k)


  test "List":
    var l = newHLList()
    for k in 0 .. 4:
      l.add initHLValue(k)

    echo l

suite "Base tokenizer":
  test "Tokenize":
    let tokens = tokenize(str0)
    for tok in tokens:
      echo tok.lispRepr()

suite "Small parser tests":
  proc p(str: string) = echo tokenize(str).parse(str).treeRepr()

  test "Binary addition":
    p("var v = 1 + 2;")

  test "New expression":
    p("var l = new List;")

  test "Function call":
    p("test(a, b);")

  test "Comments":
    p("// comment")

  test "String literals":
    p("var v = \"some string literal\";")

  test "Unlimited parens":
    p("var v = ((((((((((((((a))))))))))))));")

  test "Complex expression":
    p("var q = 2 + 3 + 4 + 5 + 6;")

  test "Expression with function call":
    p("var z = a() + b();")
    p("var z = a(a) + b(c);")
    p("var z = test() + test2(1 + 3, 4) * 3 - 19;")

  test "Print array element":
    p("print(a[0]);")




suite "Parser":
  test "Parse":
    let tokens = tokenize(str0)
    for tok in tokens:
      stdout.write tok.lispRepr() & " "
    let tree = parse(tokens, str0)
    echo treeRepr(tree)

suite "Eval AST":
  test "Eval AST":
    let tokens = tokenize(str0)
    let tree = parse(tokens, str0)
    var ctx: HLAstEvalCtx
    ctx.pushScope()
    discard evalAST(tree, ctx)

suite "Eval stack":
  test "Eval stack":
    let tokens = tokenize(str0)
    var tree = parse(tokens, str0)

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


suite "Eval stack simple":
  test "Eval stack":
    let str0 = "var a = 10;\nprint(a + 2);"
    let tokens = tokenize(str0)
    var tree = parse(tokens, str0)

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


suite "Eval register":
  test "Eval register":
    let tokens = tokenize(str0)
    var tree = parse(tokens, str0)

    block:
      var ctx = HLSemContext()
      ctx.pushScope()
      ctx.procTable = newProcTable()
      updateTypes(tree, ctx)

    echo treeRepr(tree)

    let (ops, ctx) = compileRegister(tree)
    evalRegister(ops, ctx)
