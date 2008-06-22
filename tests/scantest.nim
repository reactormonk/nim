# We start with a comment
# This is the same comment

# This is a new one!

# This should not be allowed!

export
main

import
  lexbase, os, strutils

type
  TMyRec = record # describes a record
    x, y: int     # coordinates
    c: char       # a character
    a: int32      # an integer

  PMyRec = ref TMyRec # a reference to `TMyRec`

proc splitText(txt: string): seq[string] # splits a text into several lines
                                         # the comment continues here
                                         # this is not easy to parse!

proc anotherSplit(txt: string): list[string] =
  # the comment should belong to `anotherSplit`!
  # another problem: comments are statements!

const
  x = 0B0_10001110100_0000101001000111101011101111111011000101001101001001'f64 # x ~~ 1.72826e35
  myNan = 0B01111111100000101100000000001000'f32 # NAN
  y = """
    a rather long text.
    Over many
    lines.
  """
  s = "\xff"
  a = {0..234}
  b = {0..high(int)}
  v = 0'i32
  z = 6767566'f32

# small test program for lexbase

proc main*(infile: string, a, b: int, someverylongnamewithtype = 0,
           anotherlongthingie = 3) =
  var
    myInt: int = 0
    a b = 9
    s: sequence[string]
  # this should be an error!
  if initBaseLexer(L, infile, 30): nil
  else:
    writeln(stdout, "could not open: " & infile)
  writeln(stdout, "Success!")
  call(3, # we use 3
       12, # we use 12
       43 # we use 43
       )

main(ParamStr(1))
