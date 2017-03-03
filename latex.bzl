# Defining rule to build PDF using pdflatex.
def _pdflatex(ctx):
  texfile = ctx.file.texfile
  output = ctx.outputs.out
  texcmd = ctx.attr.texcmd
  iterate_count = ctx.attr.iterate_count

  copy_command = "cp %s ./%s" %(texfile.path,
                                texfile.basename)
  inputfiles = [texfile]
  if ctx.attr.bibtex != None:
    inputfiles.append(ctx.attr.bibtex.bib)
    inputfiles.append(ctx.attr.bibtex.bbl)
    bibtex_file=(texfile.basename[:-len(texfile.extension)-1]+
                 ".bib")
    bbl_file=(texfile.basename[:-len(texfile.extension)-1]+
              ".bbl")
    copy_command += "; cp %s ./%s" % (ctx.attr.bibtex.bib.path,
                                      bibtex_file)
    copy_command += "; cp %s ./%s" % (ctx.attr.bibtex.bbl.path,
                                      bbl_file)

  otherinputs = []
  if ctx.attr.inputs != None:
    for f in ctx.attr.inputs.files:
      otherinputs.append(f.path)
    inputfiles.extend(ctx.attr.inputs.files.to_list())

  latex_output=(texfile.basename[:-len(texfile.extension)-1]+
                ".pdf")

  ctx.action(
      inputs=inputfiles,
      outputs=[output],
      command="""cp -r %s .; \
                 %s; \
                 for i in `seq 1 %d`; \
                 do %s %s; \
                 done; \
                 mv %s %s""" % (" ".join(otherinputs),
                                copy_command,
                                iterate_count,
                                texcmd,
                                texfile.basename,
                                latex_output,
                                output.path))

  return struct(output_file=output)

pdflatex = rule(
    implementation=_pdflatex,
    attrs={
        "texfile": attr.label(mandatory=True,
                              allow_files=True,
                              single_file=True),
        "texcmd": attr.string(mandatory=False,
                              default="/usr/bin/pdflatex"),
        "iterate_count": attr.int(mandatory=False,
                                  default=3),
        "bibtex": attr.label(mandatory=False,
                             providers=["bbl", "bib"]),
        "inputs": attr.label(mandatory=False),
        "output": attr.string(mandatory=False,
                              default="${texfile}.pdf"),
    },
    outputs={"out":"%{output}"},
)

# Defining rule to build auxiliary file using pdflatex.
# Then runs bibtex to get bbl file.
def _bibtex(ctx):
  aux = ctx.outputs.auxfile
  texfile = ctx.file.texfile
  texcmd = ctx.attr.texcmd

  inputfiles = [texfile]
  otherinputs = []
  if ctx.attr.inputs != None:
    for f in ctx.attr.inputs.files:
      otherinputs.append(f.path)
    inputfiles.extend(ctx.attr.inputs.files.to_list())

  latex_output=(texfile.basename[:-len(texfile.extension)-1]+
                ".aux")

  ctx.action(
      inputs=inputfiles,
      outputs=[aux],
      command="""cp -r %s .; \
                 ls -la figures; \
                 %s %s; \
                 cp %s %s""" % (" ".join(otherinputs),
                                texcmd,
                                texfile.path,
                                latex_output,
                                aux.path))

  bibfile = ctx.file.bibfile
  bblfile = ctx.outputs.bblfile
  bibcmd = ctx.attr.bibcmd
  ctx.action(
      inputs=[aux, bibfile],
      outputs=[bblfile],
      command="cp %s . ; %s %s" % (bibfile.path,
                                   bibcmd,
                                   aux.path))

  return struct(
      bbl=bblfile,
      bib=bibfile
  )

bibtex = rule(
    implementation=_bibtex,
    attrs={
        "texfile": attr.label(mandatory=True,
                              allow_files=True,
                              single_file=True),
        "bibfile": attr.label(mandatory=True,
                              allow_files=True,
                              single_file=True),
        "texcmd": attr.string(mandatory=False,
                              default="/usr/bin/pdflatex"),
        "bibcmd": attr.string(mandatory=False,
                              default="/usr/bin/bibtex"),
        "inputs": attr.label(mandatory=False),
    },
    outputs={"auxfile": "%{bibfile}.aux",
             "bblfile": "%{bibfile}.bbl"},
)
