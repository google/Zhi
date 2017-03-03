# Defining rule for gdrive command and config.
def _gdrive(ctx):
  gdrive_cmd = ctx.attr.gdrive_cmd
  gdrive_cfg = ctx.attr.gdrive_config

  return struct(command=gdrive_cmd,
                config=gdrive_cfg)

gdrive = rule(
    implementation=_gdrive,
    attrs={
        "gdrive_cmd": attr.string(mandatory=True),
        "gdrive_config": attr.string(mandatory=True),
    },
)

# Defining rule to export using gdrive.
def _gdrive_export(ctx):
  doc_id = ctx.attr.doc_id
  gdrive_cmd = ctx.attr.gdrive.command
  mime = ctx.attr.mime
  gdrive_config = ctx.attr.gdrive.config
  output = ctx.outputs.out

  ctx.action(
      outputs=[output],
      command="""x=`%s export --force --mime %s --config %s %s`; \
                 x=${x#*\\'}; x=${x%%\\' with*} ; \
                 mv \"${x}\" %s""" % (gdrive_cmd,
                                      mime,
                                      gdrive_config,
                                      doc_id,
                                      output.path))

  return struct(output_file=output)

gdrive_export = rule(
    implementation=_gdrive_export,
    attrs={
        "doc_id": attr.string(mandatory=True),
        "mime": attr.string(mandatory=False,
                            default="text/plain"),
        "gdrive": attr.label(mandatory=False,
                             providers=["config","command"]),
        "output": attr.string(mandatory=True),
    },
    outputs={"out":"%{output}"},
)

# Defining rule to download using gdrive.
def _gdrive_download(ctx):
  folder_id = ctx.attr.folder_id
  gdrive_cmd = ctx.attr.gdrive.command
  gdrive_config = ctx.attr.gdrive.config
  output = ctx.outputs.out

  ctx.action(
      outputs=[output],
      command="""x=`%s download --recursive --force --config %s %s`; \
                 x=${x##*-> }; x=${x%%/*}; \
                 mv \"${x}\" %s""" % (gdrive_cmd,
                                      gdrive_config,
                                      folder_id,
                                      output.path))

  return struct(output_file=output)

gdrive_download = rule(
    implementation=_gdrive_download,
    attrs={
        "folder_id": attr.string(mandatory=True),
        "gdrive": attr.label(mandatory=False,
                             providers=["config","command"]),
        "output": attr.string(mandatory=True),
    },
    outputs={"out":"%{output}"},
)

# Defining rule to update using gdrive.
def _gdrive_update(ctx):
  doc_id = ctx.attr.doc_id
  gdrive_cmd = ctx.attr.gdrive.command
  gdrive_config = ctx.attr.gdrive.config
  file_to_update = ctx.attr.output_file.output_file
  output = ctx.outputs.out

  ctx.action(
      inputs=[file_to_update],
      outputs=[output],
      command="""cp %s %s;\
                 %s update --config %s %s %s""" % (file_to_update.path,
                                                   output.path,
                                                   gdrive_cmd,
                                                   gdrive_config,
                                                   doc_id,
                                                   output.path))

  return struct(output_file=output)

gdrive_update = rule(
    implementation=_gdrive_update,
    attrs={
        "doc_id": attr.string(mandatory=True),
        "gdrive_name": attr.string(mandatory=True),
        "gdrive": attr.label(mandatory=False,
                             providers=["config","command"]),
        "output_file": attr.label(mandatory=True,
                                  providers=["output_file"]),
    },
    outputs={"out":"%{gdrive_name}"},
)



