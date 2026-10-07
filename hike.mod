module github.com/kanryu/hike-images-vips

hike 1.0

// Native link and runtime asset settings are attached to the package that
// activates them through a blank import.
package ./shared {
    target windows {
        link: "deps/vips-dev-8.18/lib/libvips.lib"
        link: "deps/vips-dev-8.18/lib/libgobject-2.0.lib"
        link: "deps/vips-dev-8.18/lib/libglib-2.0.lib"
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
