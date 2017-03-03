# Defining rule to execute gnuplot.
def _gnuplot(ctx):
  gnuplot_file = ctx.file.gnuplot_file
  output = ctx.outputs.out

  inputfiles = [gnuplot_file]
  inputfiles.extend(ctx.attr.inputs.files.to_list())

  otherinputs = []
  for f in ctx.attr.inputs.files:
    otherinputs.append(f.path)

  sedcmd = "sed -i \"s:^set output \\\".*$:set output \\\"%s\\\":g\"" % output.path

  ctx.action(
      inputs=inputfiles,
      outputs=[output],
      command = """cp %s .; \
                   %s %s; \
                   /usr/bin/gnuplot %s""" % (" ".join(otherinputs),
                                             sedcmd,
                                             gnuplot_file.path,
                                             gnuplot_file.path))

gnuplot = rule(
    implementation=_gnuplot,
    attrs={
        "gnuplot_file": attr.label(mandatory=True,
                                   allow_files=True,
                                   single_file=True),
        "inputs": attr.label(mandatory=True),
        "output": attr.string(mandatory=True),
    },
    outputs={"out":"%{output}"},
)
