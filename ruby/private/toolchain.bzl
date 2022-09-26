def _ruby_toolchain_impl(ctx):
    return platform_common.ToolchainInfo(
        interpreter = ctx.executable.interpreter,
        bundle = ctx.executable.bundle,
    )

_ruby_toolchain = rule(
    _ruby_toolchain_impl,
    attrs = {
        "interpreter": attr.label(
            doc = "`ruby` binary to execute",
            allow_single_file = True,
            executable = True,
            cfg = "exec",
        ),
        "bundle": attr.label(
            doc = "`bundle` to execute",
            allow_single_file = True,
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
