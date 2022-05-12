import hmisc/core/all

import hmisc/other/oswrap
import hmisc/other/hshell

export ShellError

proc compileAsm*(infile, outfile: AbsFile) =
  let cmd = shellCmd(nasm).withIt do:
    it.opt("f", " ", "bin")
    it.opt("o", " ", $outfile)
    it.arg($infile)

  execShell(cmd)

proc compileC*(infile, outfile: AbsFile) =
  let tmpf = outfile.withExt("o")

  let gcc = makeNoSpaceShellCmd("gcc").withIt do:
    it.arg([
      "-masm=intel",
      "-nostdlib",
      "-fno-asynchronous-unwind-tables",
      "-g",
      "-fno-stack-protector",
      "-m16",
      "-o",
      $tmpf,
      $infile
    ])

  let link = makeGnuShellCmd("ld").withIt do:
    it.arg("--entry=start")
    it.arg("--oformat=binary")
    it.arg("-Ttext")
    it.arg("0x0")
    it.arg("-melf_i386")
    it.opt("o", " ", $outfile)
    it.arg(tmpf)

  echo link
  echo gcc

  execShell(gcc)
  execShell(link)
