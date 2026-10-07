# Hike Images VIPS

`github.com/kanryu/hike-images-vips` is a Hike module that provides a small,
native image-processing wrapper around [libvips](https://www.libvips.org/).

## License

The Hike Images VIPS wrapper is provided under the MIT License. The bundled
libvips development package is separately licensed under the GNU Lesser
General Public License, version 2.1 or later (LGPL-2.1-or-later). Any use or
redistribution that includes libvips must comply with both licenses and the
licenses of its bundled dependencies.

## Import

```hike
import "github.com/kanryu/hike-images-vips/vips"
```

## API

### Runtime

```hike
if !vips.Initialize("my-app") {
    return 1
}
defer vips.Shutdown()
```

`Initialize` starts libvips. Call `Shutdown` after all images have been closed.

### `Image`

`Image` wraps a native VipsImage. Its main public fields are:

| Field | Description |
| --- | --- |
| `Width`, `Height` | Image dimensions in pixels |
| `Bands` | Number of bands: 3 for RGB, 4 for RGBA/ARGB |
| `BitsPerBand` | Bits stored in one band |
| `BitsPerPixel` | Total bits stored in one pixel |
| `Format` | `VipsBandFormat` |
| `Coding` | `VipsCoding` |
| `Interpretation` | `VipsInterpretation` |
| `Layout` | `PixelLayoutRGB/RGBA/ARGB` |
| `Data` | Pointer to the first byte of the bitmap |
| `BytesPerStride` | Actual number of bytes in one bitmap row |

Always use `BytesPerStride` when advancing between rows. Do not recompute the
stride from the width and pixel format.

### Loading and saving files

```hike
image := vips.LoadRGB(
    "input.jpg",
    vips.VipsInterpretationSRGB,
    vips.PixelLayoutRGB,
    vips.VipsBandFormatUChar,
)
if image != nil {
    vips.Save(image, "output.png")
    image.Close()
}
```

`LoadRGB` selects a loader from the input filename and normalizes the result to
the requested interpretation, layout, and band format. `Save` selects the
output format from the filename extension.

### Loading a GPU-generated bitmap

For an uncompressed bitmap produced by a GPU or another renderer, pass the
data and its metadata together as a `Bitmap` value. This is not a compressed
image loader.

```hike
bitmap := vips.Bitmap{
    Data: data,
    Width: width,
    Height: height,
    BytesPerStride: bytesPerStride,
    Coding: vips.VipsCodingNone,
    Interpretation: vips.VipsInterpretationSRGB,
    Layout: vips.PixelLayoutRGB,
    Format: vips.VipsBandFormatUChar,
}
image := vips.LoadRGBFromBytes(bitmap)
```

VIPS memory images assume packed rows. If the source stride contains padding,
the wrapper copies each row into an internal packed buffer. For packed input,
the source buffer is wrapped directly, so it must remain alive while the
returned `Image` is in use.

### Thumbnails

```hike
thumbnail := vips.Thumbnail(
    "input.jpg",
    64, 64,
    vips.VipsSizeDown,
    vips.VipsInterpretationSRGB,
    vips.PixelLayoutRGB,
    vips.VipsBandFormatUChar,
)
```

`Thumbnail` combines file loading and reduction. A `height` of 0 preserves the
aspect ratio; a positive `height` enables a centered crop to fill the target
frame.

Use the receiver form when creating a thumbnail from an existing image:

```hike
thumbnail := image.Thumbnail(
    64, 64,
    vips.VipsSizeDown,
    vips.VipsInterpretationSRGB,
    vips.PixelLayoutRGB,
    vips.VipsBandFormatUChar,
)
```

`VipsSizeDown` prevents upscaling smaller images, while `VipsSizeBoth` allows
both upscaling and downscaling. `ThumbnailImage` is retained as a compatibility
package function.

### Resize

```hike
large := image.Resize(1.5, vips.VipsKernelLanczos3)
```

`Resize` supports both enlargement and reduction. Available `VipsKernel`
values include `VipsKernelLanczos3` and `VipsKernelMKS2021`.

### Combined transforms

`Transform` is a small matrix value, so no transform pointer needs to be
allocated. Compose transforms with `Then`, then apply the result with
`Image.Transform` as one affine operation.

```hike
transform := vips.TransformScale(2.0, vips.VipsInterpolationBicubic)
transform = transform.Then(vips.TransformRotate90(
    vips.VipsInterpolationBicubic,
))
transform = transform.Then(vips.TransformFlipHorizontal(
    vips.VipsInterpolationBicubic,
))
result := image.Transform(transform)
```

`TransformRotate` accepts radians. The common fixed angles
`TransformRotation90`, `TransformRotation180`, and `TransformRotation270` are
also provided.

### Crop, blur, and insert

```hike
cropped := image.Crop(100, 50, 640, 480)
blurred := image.Blur(3.0)
composed := image.Insert(overlay, 100, 50)
```

- `Crop(x, y, width, height)` extracts a rectangle without resampling.
- `Blur(sigma)` applies a Gaussian blur.
- `Insert(sub, x, y)` places `sub` at the specified position.

These operations leave the input unchanged and return a new `Image`. They
return `nil` on failure or invalid arguments.

### Releasing images

```hike
image.Close()
```

`Close` releases the native VipsImage reference. Close every derived image
individually as well.

### Main constants

- `VipsBandFormat*`: Band formats such as UChar, UShort, Float, and Double
- `VipsCoding*`: Coding values such as `VipsCodingNone`
- `VipsInterpretation*`: Interpretations such as sRGB, RGB, RGB16, and Grey16
- `PixelLayoutRGB`, `PixelLayoutRGBA`, `PixelLayoutARGB`: In-memory band order
- `VipsKernel*`: Resampling kernels for resize operations
- `VipsInterpolation*`: Interpolators for affine transforms
- `VipsSizeBoth`, `VipsSizeUp`, `VipsSizeDown`, `VipsSizeForce`: Thumbnail policies

## Native dependency declaration

The repository currently contains the Windows development bundle in
`deps/vips-dev-8.18`. Its import libraries and runtime DLLs are used by the
following target configuration:

```hike
package ./shared {
    target windows {
        link: "deps/vips-dev-8.18/lib/libvips.lib"
        assets: "deps/vips-dev-8.18/bin/*.dll"
    }
    target linux {
        link: "-lvips"
        assets: "deps/vips-dev-8.18/lib/libvips.so*"
    }
}

package ./static {
    target windows {
        link: "deps/vips-dev-8.18/lib/libvips_static.lib"
    }
    target linux {
        link: "deps/vips-dev-8.18/lib/libvips.a"
    }
}
```

The Windows bundle also contains libvips plugin dependencies, so the asset
pattern includes every DLL in the bundle. A Linux release should provide the
matching `libvips.so` bundle or use the system libvips installation.

## Selecting the native libvips SKU

The blank import below activates the `shared` package defined by the
dependency module's `hike.mod`:

```hike
// Blank-import shared to drive the native build pipeline and copy the
// required libvips DLLs beside the executable automatically.
import _ "github.com/kanryu/hike-images-vips/shared"
```

Importing `shared` causes the declared link and asset resources to be linked
and copied during the build. End users can switch the blank import to another
package such as `static` or `debug` to select another SKU without changing the
image-processing code.

## Examples

- `examples/load_image`: Load an image and save it in another format.
- `examples/resample`: Enlarge a 720p SVG to 1080p, create a 64x64 thumbnail,
  and generate a rotate-plus-flip output.
