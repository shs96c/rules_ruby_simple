load("//ruby/private:system_toolchain.bzl", "SYSTEM_TOOLCHAIN_NAME")

def ruby_setup(toolchain = "@%s//:toolchain" % SYSTEM_TOOLCHAIN_NAME):
    native.register_toolchains(toolchain)
