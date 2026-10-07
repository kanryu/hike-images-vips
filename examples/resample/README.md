# Resample example

This example loads `source_720p.svg` at 1280x720 and creates three outputs:

- `output_1080p.png`: enlarged to 1920x1080 with `Image.Resize` and Lanczos3.
- `output_thumbnail_64.png`: a centered, exact 64x64 thumbnail.
- `output_rotate_flip.png`: a 90-degree rotation followed by a horizontal flip,
  combined into one affine transform before resampling.

Build and run from this directory:

```text
make run
```

The blank import of `shared` activates the native link settings and copies the
required libvips DLLs beside the executable automatically.
