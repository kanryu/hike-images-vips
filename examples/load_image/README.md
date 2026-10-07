# load_image

This example loads the bundled `input.svg` with libvips and writes it as
`output.png`. The SVG loader exercises the same native dependency and asset
resolution path as JPEG and PNG loaders without requiring a binary fixture.

From this directory, run:

```text
make build
make run
```

The libvips DLLs are copied from the module's `deps/vips-dev-8.18` asset
declaration when the target asset resolver is enabled.

## Selecting the native libvips SKU

The blank import below activates the `shared` package defined by the
dependency module's `hike.mod`:

```hike
// Blank-import shared to drive the native build pipeline and copy the
// required libvips DLLs beside the executable automatically.
import _ "github.com/kanryu/hike-images-vips/shared"
```

Importing `shared` causes the link and asset resources declared for that
package in `hike.mod` to be linked and copied during the build. End users can
switch the blank import to another package such as `static` or `debug` to
select a different SKU of the same native library without changing the image
processing code.

The example is deliberately format-agnostic: changing the filename suffixes
is enough to exercise another libvips loader or saver. Change `inputPath` in
`main.hike` when using a different fixture.
