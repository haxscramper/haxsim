import std/[macros, sequtils]
import hmisc/other/oswrap except getAppFilename

import haxsim/[
  hl_lexer, hl_parser, hl_eval_ast, hl_eval_stack, hl_semcheck,
  hl_eval_register
]

import argparse

var p = newParser:
  command "lex": arg("file")
  command "parse": arg("file")
  command "polish": arg("file")
  command "typed": arg("file")
  command "eval":
    arg("file")
    flag("--ops")
    flag("--stack")

proc typedTree(str: string): HLNode =

  result = str.tokenize().parse(str)

  var ctx = HLSemContext()
  ctx.pushScope()
  ctx.procTable = newProcTable()
  result.updateTypes(ctx)



proc main*(args: varargs[string]) =
  var opts = p.parse(toSeq(args))
  case opts.command:
    of "lex":
      for tok in hl_lexer.tokenize(opts.lex.get().file.readFile()):
        echo tok.lispRepr()

    of "parse":
      let str = opts.parse.get().file.readFile()
      let tree = str.tokenize().parse(str)
      echo treeRepr(tree)

    of "typed":
      echo opts.`typed`.get().file.readFile().typedTree().treeRepr()

    of "polish":
      let tree = opts.polish.get().file.readFile().typedTree()
      let ops = compileStack(tree)
      echo ops

    of "eval":
      let tree = opts.eval.get().file.readFile().typedTree()
      let ops = compileStack(tree)
      var ctx = newStackEvalCtx()
      ctx.pushScope()
      discard evalStack(
        ops, ctx,
        opts.eval.get().ops,
        opts.eval.get().stack
      )

when isMainModule:
  main(paramStrs())
