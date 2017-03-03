# Defining rule to extract EPS from PDF.
def _pdftops(ctx):
  pdftops_cmd = ctx.attr.pdftops_cmd
  pdffile = ctx.file.pdffile
  page = ctx.attr.page
  output = ctx.outputs.out

  ctx.action(
      inputs=[pdffile],
      outputs=[output],
      command="%s -f %d -l %d -eps %s %s" % (pdftops_cmd,
                                             page, page,
                                             pdffile.path,
                                             output.path))

pdftops = rule(
    implementation=_pdftops,
    attrs={
        "pdffile": attr.label(mandatory=True,
                              allow_files=True,
                              single_file=True),
        "pdftops_cmd": attr.string(mandatory=False,
                                   default="/usr/bin/pdftops"),
        "page": attr.int(mandatory=True),
        "output": attr.string(mandatory=True),
    },
    outputs={"out":"%{output}"},
)

# Defining rule to prepare TeX file.
def _prep_file(ctx):
  texfile = ctx.file.texfile
  output = ctx.outputs.out

  # Some default unintuitive replacement to start with.
  pre_sedcmd = "sed -e \"s:\’:\':g\""
  pre_sedcmd += " -e \"s:\“:\\\":g\""
  pre_sedcmd += " -e \"s:\”:\\\":g\""

  sedcmd = "| sed -e '/end{document}/q' -e 's/\[[a-z]*]//g'"
  for sed in ctx.attr.sed_expr:
    sedcmd += " -e \""+sed+"\""

  ctx.action(
      inputs=[texfile],
      outputs=[output],
      command="""%s %s > %s.prep_sed; \
                 dos2unix --follow-symlink -n %s.prep_sed %s.unix; \
                 iconv --verbose -c -t ASCII//TRANSLIT %s.unix \
                 %s > %s """ % (pre_sedcmd,
                                texfile.path,
                                texfile.path,
                                texfile.path,
                                texfile.path,
                                texfile.path,
                                sedcmd,
                                output.path))

  return struct(file=output)

prep_file= rule(
    implementation=_prep_file,
    attrs={
        "texfile": attr.label(mandatory=True,
                              allow_files=True,
                              single_file=True),
        "sed_expr": attr.string_list(mandatory=False),
        "output": attr.string(mandatory=True),
    },
    outputs={"out":"%{output}"},
)
