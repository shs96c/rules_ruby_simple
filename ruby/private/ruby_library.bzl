load(":providers.bzl", "RubyInfo")
load(":utils.bzl", "workspace_name")

def _ruby_library_impl(ctx):
    prefix = "%s/" % ctx.label.workspace_name if ctx.label.workspace_name else "./"

    info = RubyInfo(
        transitive_sources = depset(
            ctx.files.srcs,
            transitive = [d[RubyInfo].transitive_srcs for d in ctx.attr.deps],
        ),
        paths = depset(
            ["%s%s" % (prefix, ctx.label.package)],
            transitive = [d[RubyInfo].paths for d in ctx.attr.deps],
        ),
    )

    print(info)

    return [
        DefaultInfo(
            runfiles = ctx.runfiles(ctx.files.srcs),
        ),
        info,
    ]

ruby_library = rule(
    _ruby_library_impl,
    attrs = {
        "srcs": attr.label_list(allow_files = True),
        "deps": attr.label_list(
            providers = [
                [RubyInfo],
            ],
        ),
    },
)
