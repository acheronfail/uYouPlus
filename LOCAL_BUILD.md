# Local build on macOS

This project needs Xcode, Homebrew, Theos, theos-jailed, the patched iOS 16.5 SDK, Meson, and Ninja. The commands below keep the toolchain in the ignored `.build-tools/` directory. The YouTube IPA stays local and is ignored by Git.

From the repository root, run once:

```sh
brew install ldid dpkg make
git submodule update --init --recursive
mkdir -p .build-tools
git clone --recursive https://github.com/theos/theos.git .build-tools/theos
git -C .build-tools/theos/vendor/logos fetch --depth=1 origin 31d2271046810dacedcbcd92b7780ec5da600e96
git -C .build-tools/theos/vendor/logos checkout --detach 31d2271046810dacedcbcd92b7780ec5da600e96
git clone -n --depth=1 --filter=tree:0 https://github.com/theos/sdks.git .build-tools/sdk-source
git -C .build-tools/sdk-source sparse-checkout set --no-cone iPhoneOS16.5.sdk
git -C .build-tools/sdk-source checkout
mv .build-tools/sdk-source/iPhoneOS16.5.sdk .build-tools/theos/sdks/
git clone --recursive https://github.com/qnblackcat/theos-jailed.git .build-tools/theos-jailed
THEOS="$PWD/.build-tools/theos" .build-tools/theos-jailed/install
python3 -m venv .build-tools/decoder-venv
.build-tools/decoder-venv/bin/pip install meson ninja
```

Put a decrypted `YouTube.ipa` at the repository root, then build:

```sh
./build-local.sh
```

You can pass another IPA path as the first argument. The script reads its YouTube version, builds YTUHD's libvpx and dav1d libraries when their pinned source revisions change, builds the app incrementally, and writes the result to `packages/`. To keep a diagnostic log, run `./build-local.sh > .build-tools/local-build.log 2>&1`.

The Makefile sets `CODESIGN_IPA = 0`; sign the generated IPA with your installation method before installing it on a device.
