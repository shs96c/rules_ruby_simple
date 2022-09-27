load(":providers.bzl", "RubyInfo")
load(":ruby_library.bzl", "ruby_library")
load(":utils.bzl", "workspace_name")

def _ruby_binary_impl(ctx):
    toolchain = ctx.toolchains["//ruby:toolchain_type"]

    infos = [d[RubyInfo] for d in ctx.attr.deps]

    paths = depset(transitive = [i.paths for i in infos])

    script = ctx.actions.declare_file("{}".format(ctx.label.name))
    ctx.actions.expand_template(
        template = ctx.file._launcher_template,
        output = script,
        substitutions = {
            "{workspace}": workspace_name(ctx),
            "{interpreter}": toolchain.interpreter.short_path,
            "{bin}": ctx.file.main.path,
            "{args}": " ".join(ctx.attr.args),
            "{load_path}": " ".join([p for p in sorted(paths.to_list())]),
        },
        is_executable = True,
    )

    return [
        DefaultInfo(
            executable = script,
            runfiles = ctx.runfiles(
                transitive_files = depset(transitive = [i.transitive_sources for i in infos]),
            ).merge(toolchain.interpreter_runfiles),
        ),
    ]

_ruby_binary = rule(
    _ruby_binary_impl,
    executable = True,
    attrs = {
        "main": attr.label(allow_single_file = True, mandatory = True),
        "deps": attr.label_list(
            providers = [
                [RubyInfo],
            ],
        ),
        "_launcher_template": attr.label(default = ":binary_launcher.txt", allow_single_file = True),
    },
    toolchains = [
        "//ruby:toolchain_type",
    ],
)

def ruby_binary(
        name,
        main = None,
        srcs = [],
        deps = [],
        args = None,
        data = None,
        tags = None,
        testonly = None,
        visibility = None):
    if not main and not len(srcs):
        fail("Either `main` or `srcs` must be specified")

    additional_deps = []

    if len(srcs):
        library_name = "%s-binlib" % name
        ruby_library(
            name = library_name,
            srcs = srcs,
            deps = deps,
            data = data,
            tags = tags,
            testonly = testonly,
            visibility = visibility,
        )
        additional_deps.append(":%s" % library_name)

    if not main:
        for src in srcs:
            parts = src.rsplit("/", 2)
            file_name = parts[-1]
            if file_name == "%s.rb" % name:
                main = src
                break

    if not main:
        fail("Unable to find main file")

    _ruby_binary(
        name = name,
        main = main,
        deps = deps + additional_deps,
        tags = tags,
        testonly = testonly,
        visibility = visibility,
    )
