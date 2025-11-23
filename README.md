# FB21130604: Static library produced by Xcode 26 causes link error on Xcode 16

This this the demo project for feedback FB21130604

---

**Description:**

When a static library is built with Xcode 26 (with deployment target set to iOS 13) and then linked into an app project compiled with Xcode 16, the build process fails with the following linker error:

Undefined symbols for architecture arm64:
  "_swift_coroFrameAlloc"

This occurs even though both the static library and the app project have their deployment targets set to iOS 13.0. The static library works on Xcode 26, but fails to link on Xcode 16.

This issue shows up with certain Swift syntax. For example, in my case, using a property getter and setter caused the compiler to emit a reference to _swift_coroFrameAlloc, which in turn triggered the issue.

This issue prevents us from distributing pre-built static libraries compiled with Xcode 26 to teammates who are still using Xcode 16.

This demo project includes:
- **StaticLibraryProject**: A simple Swift static library with property getter setter usage
- **AppProject**: An iOS app that links against the static library
- **verify_compatibility.sh**: An automated script to reproduce the issue

**Steps to Reproduce:**

**Method 1: Manual Build and Verification**

1. Checkout this demo project
2. Open `StaticLibraryProject/StaticLibraryProject.xcodeproj` in Xcode 26
3. Build the StaticLibraryProject for iOS device (Release configuration)
4. Locate the built `libStaticLibraryProject.a` in the build products directory
5. Copy `libStaticLibraryProject.a` to `AppProject/AppProject/` directory
6. Open `AppProject/AppProject.xcodeproj` in Xcode 16
7. Build the AppProject for iOS device

**Method 2: Automated Script**

1. Checkout this demo project
2. Edit `verify_compatibility.sh` to configure the paths to your Xcode installations:
   - Set `XCODE_26_PATH` to your Xcode 26 installation path (e.g., `/Applications/Xcode.app`)
   - Set `XCODE_16_PATH` to your Xcode 16 installation path (e.g., `/Applications/Xcode16.app`)
3. Run the script: `./verify_compatibility.sh`

The script will automatically:
- Switch to Xcode 26 and build the static library
- Inspect the static library for the `_swift_coroFrameAlloc` symbol
- Copy the built library to the AppProject
- Verify that AppProject builds successfully with Xcode 26
- Switch to Xcode 16 and attempt to build AppProject (this step will fail)

**Expected Result:**

The app project should build successfully with Xcode 16 when linking against a static library built with Xcode 26, as long as both projects have compatible deployment targets.

**Current Result:**

The build fails with the following linker error:

```Undefined symbol: swift_coroFrameAlloc```

This indicates that the static library built with Xcode 26 contains references to Swift runtime symbols that are not available or recognized by Xcode 16's toolchain, even though the deployment target is set to a version that should be compatible with both Xcode versions.

**Xcode Versions:**

- Xcode 26.0 (used to build the static library)
- Xcode 16.0 (used to build the app project, where the error occurs)