load("//ruby/private:system_toolchain.bzl", "SYSTEM_TOOLCHAIN_NAME", "system_toolchain")

def ruby_deps():
    system_toolchain(
        name = SYSTEM_TOOLCHAIN_NAME,
    )
