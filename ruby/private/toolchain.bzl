def _ruby_toolchain_impl(ctx):
    return platform_common.ToolchainInfo(
        interpreter = ctx.executable.interpreter,
        interpreter_runfiles = ctx.runfiles(ctx.files.interpreter).merge(
            ctx.attr.interpreter[DefaultInfo].default_runfiles,
        ),
        bundle = ctx.executable.bundle,
        bundle_runfiles = ctx.runfiles(ctx.files.bundle).merge(
            ctx.attr.bundle[DefaultInfo].default_runfiles,
        ),
    )

_ruby_toolchain = rule(
    _ruby_toolchain_impl,
    attrs = {
        "interpreter": attr.label(
            doc = "`ruby` binary to execute",
            allow_files = True,
            executable = True,
            cfg = "exec",
        ),
        "bundle": attr.label(
            doc = "`bundle` to execute",
            allow_files = True,
            executable = True,
            cfg = "exec",
        ),
    },
)

def ruby_toolchain(name, interpreter, bundle):
    toolchain_name = "%s_toolchain" % name

    _ruby_toolchain(
        name = toolchain_name,
        interpreter = interpreter,
        bundle = bundle,
    )

    native.toolchain(
        name = name,
        toolchain = ":%s" % toolchain_name,
        toolchain_type = "@rules_ruby//ruby:toolchain_type",
    )
