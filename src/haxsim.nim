import std/[macros, sequtils]
import hmisc/other/oswrap except getAppFilename

import haxsim/[
  hl_lexer, hl_parser, hl_eval_ast, hl_eval_stack, hl_semcheck,
  hl_eval_register
]

# import argparse

# var p = newParser:
#   command "lex": arg("file")
#   command "parse": arg("file")
#   command "polish": arg("file")
#   command "typed": arg("file")
#   command "eval":
#     arg("file")
#     flag("--ops")
#     flag("--stack")

proc typedTree(str: string): HLNode =

  result = str.tokenize().parse(str)

  var ctx = HLSemContext()
  ctx.pushScope()
  ctx.procTable = newProcTable()
  result.updateTypes(ctx)



proc main*(args: varargs[string]) =
  # var opts = p.parse(toSeq(args))
  let text = ""
  case "lex":
    of "lex":
      for tok in hl_lexer.tokenize(text):
        echo tok.lispRepr()

    of "parse":
      let tree = text.tokenize().parse(text)
      echo treeRepr(tree)

    of "typed":
      echo text.typedTree().treeRepr()

    of "polish":
      let tree = text.typedTree()
      let ops = compileStack(tree)
      echo ops

    of "eval":
      let tree = text.typedTree()
      let ops = compileStack(tree)
      var ctx = newStackEvalCtx()
      ctx.pushScope()
      discard evalStack(
        ops, ctx,
        false# opts.eval.get().ops
        ,
        false # opts.eval.get().stack
      )

when isMainModule:
  main(paramStrs())
