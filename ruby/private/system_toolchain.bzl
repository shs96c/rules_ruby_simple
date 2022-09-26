SYSTEM_TOOLCHAIN_NAME = "rules_ruby_system_toolchain"

def _system_toolchain_impl(rctx):
    false_binary = rctx.which("false")

    ruby = rctx.which("ruby")
    if not ruby:
        ruby = false_binary
    rctx.symlink(ruby, "ruby")

    bundle = rctx.which("bundle")
    if not bundle:
        bundle = false_binary
    rctx.symlink(bundle, "bundle")

    rctx.file(
        "BUILD.bazel",
        content = """
package(default_visibility = ["//visibility:public"])

load("@rules_ruby//ruby:defs.bzl", "ruby_toolchain")

ruby_toolchain(
    name = "toolchain",
    interpreter = "ruby",
    bundle = "bundle",
)
""",
    )

    pass

system_toolchain = repository_rule(
    _system_toolchain_impl,
)
