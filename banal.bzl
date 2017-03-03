# Defining rule for banal command.
def _banal(ctx):
  cmd = ctx.attr.banal_cmd
  if cmd != None:
    cmd = ("PDFTOHTML="+ctx.attr.banal_pdftohtml+
           " " + ctx.attr.banal_cmd)

  return struct(command=cmd)

banal = rule(
    implementation=_banal,
    attrs={
        "banal_cmd": attr.string(mandatory=False,
                                 default="banal"),
        "banal_pdftohtml": attr.string(mandatory=False),
    },
)

# Defining rule to judge using banal.
def _banal_judge(ctx):
  pdffile = ctx.file.pdffile
  banalcmd = ctx.attr.banalcmd.command
  output = ctx.outputs.out

  options=ctx.attr.options
  opt_string = ""
  for k in options:
    opt_string += " -%s=%s" % (k,options[k])

  ctx.action(
      inputs = [pdffile],
      outputs = [output],
      command="""%s -judge %s %s | \
                 tee %s""" % (banalcmd,
                              opt_string,
                              pdffile.path,
                              output.path))

banal_judge = rule(
    implementation=_banal_judge,
    attrs={
        "pdffile": attr.label(mandatory=True,
                              allow_files=True,
                              single_file=True),
        "banalcmd": attr.label(mandatory=True,
                               providers=["command"]),
        "options": attr.string_dict(mandatory=False,
                                    default={"paper": "letter",
                                             "pages": "12",
                                             "font": "10",
                                             "leading": "12",
                                             "width": "6.99",
                                             "height": "9.25"}),
    },
    outputs={"out":"%{name}.banal_judge"},
)
