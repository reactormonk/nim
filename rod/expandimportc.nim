#
#
#           The Nimrod Compiler
#        (c) Copyright 2009 Andreas Rumpf
#
#    See the file "copying.txt", included in this
#    distribution, for details about the copyright.
#

## Simple tool to expand ``importc`` pragmas. Used for the clean up process of
## the diverse wrappers.

import 
  os, ropes, idents, ast, pnimsyn, rnimsyn, msgs, wordrecg, syntaxes, pegs

proc modifyPragmas(n: PNode, name: string) =
  if n == nil: return
  for i in countup(0, sonsLen(n) - 1): 
    var it = n.sons[i]
    if it.kind == nkIdent and whichKeyword(it.ident) == wImportc:
      var x = newNode(nkExprColonExpr)
      addSon(x, it)
      addSon(x, newStrNode(nkStrLit, name))
      n.sons[i] = x

proc getName(n: PNode): string = 
  case n.kind
  of nkPostfix: result = getName(n.sons[1])
  of nkPragmaExpr: result = getName(n.sons[0])
  of nkSym: result = n.sym.name.s
  of nkIdent: result = n.ident.s
  of nkAccQuoted: result = getName(n.sons[0])
  else: internalError(n.info, "getName()")

proc processRoutine(n: PNode) =
  var name = getName(n.sons[namePos])
  modifyPragmas(n.sons[pragmasPos], name)
  
proc processIdent(ident, prefix: string, n: PNode): string =
  var pattern = sequence(capture(?(termIgnoreCase"T" / termIgnoreCase"P")),
                         termIgnoreCase(prefix), capture(*any))
  if ident =~ pattern:
    result = matches[0] & matches[1]
  else:
    result = ident
  
proc processTree(n: PNode, prefix: string) =
  if n == nil: return
  case n.kind
  of nkEmpty..pred(nkIdent), succ(nkIdent)..nkNilLit: nil
  of nkIdent:
    if prefix.len > 0:
      n.ident = getIdent(processIdent(n.ident.s, prefix, n))
  of nkProcDef, nkConverterDef:
    processRoutine(n)
    for i in 0..sonsLen(n)-1: processTree(n.sons[i], prefix)
  else:
    for i in 0..sonsLen(n)-1: processTree(n.sons[i], prefix)

proc main(infile, outfile, prefix: string) =
  var module = ParseFile(infile)
  processTree(module, prefix)
  renderModule(module, outfile)

if paramcount() >= 1:
  var infile = addFileExt(paramStr(1), "nim")
  var outfile = changeFileExt(infile, "new.nim")
  if paramCount() >= 2:
    outfile = addFileExt(paramStr(2), "new.nim")
  var prefix = ""
  if paramCount() >= 3:
    prefix = paramStr(3)
  main(infile, outfile, prefix)
else:
  echo "usage: expand_importc filename[.nim] outfilename[.nim] [prefix]"
