def workspace_name(ctx):
    maybe_name = ctx.label.workspace_name
    if maybe_name:
        return maybe_name
    return ctx.workspace_name

def _ruby_binary_impl(ctx):
    toolchain = ctx.toolchains["//ruby:toolchain_type"]

    # Find the main file
    main = ctx.file.main
    if not main:
        main_file_name = "%s.rb" % ctx.attr.name
        for src in ctx.files.srcs:
            if src.basename == main_file_name:
                main = src
                break

    if not main:
        fail("Unable to find main file")

    script = ctx.actions.declare_file("{}.sh".format(ctx.label.name))
    ctx.actions.expand_template(
        template = ctx.file._launcher_template,
        output = script,
        substitutions = {
            "{workspace}": workspace_name(ctx),
            "{interpreter}": toolchain.interpreter.path,
            "{bin}": main.short_path,
            "{args}": " ".join(ctx.attr.args),
        },
    )

    return [
        DefaultInfo(
            executable = script,
            runfiles = ctx.runfiles(ctx.files.srcs + [main]).merge(toolchain.runfiles),
        ),
    ]

ruby_binary = rule(
    _ruby_binary_impl,
    executable = True,
    attrs = {
        "main": attr.label(allow_single_file = True),
        "srcs": attr.label_list(allow_files = True),
        "_launcher_template": attr.label(default = ":binary_launcher.txt", allow_single_file = True),
    },
    toolchains = [
        "//ruby:toolchain_type",
    ],
)
