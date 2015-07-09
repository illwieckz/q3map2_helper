Q3map2 helper
=============

Description
-----------

This Q3map2 helper is a tool to simplify usual boring tasks like creating minimaps or navmeshes.

This tool was written to be used by [Unvanquished](http://unvanquished.net)'s mappers. A better one will be rewritten later.

This tool use `q3map2` from [NetRadiant](http://ingar.satgnu.net/gtkradiant/) for any tasks except it uses [`daemonmap`](https://github.com/Unvanquished/daemonmap) for navmesh generation, you can configure it to use `daemonmap` instead of `q3map2` or the opposite. This tool uses [`crunch`](https://github.com/Unvanquished/crunch) or `convert` from [ImageMagick](http://www.imagemagick.org/) to compress minimaps.

HELP
----

```
USAGE:
	./q3map2_helper.sh [OPTIONS] [PARAMETERS]

OPTIONS:
-a, --arena BSP_FILENAME LONG_NAME
	create a arena file for BSP_FILENAME (ask interactively for LONG_NAME if not given on command line)
-d, --decompile
	decompile BSP_FILENAME
-m, --minimap
	create a minimap for BSP_FILENAME
-n, --navmesh
	create navmeshes for BSP_FILENAME
-h, --help
	print this help

EXAMPLES:
./q3map2_helper.sh --arena map-sweet.pk3dir/maps/sweet.bsp "Sweet map for the lovely granger"
	create the file map-sweet.pk3dir/meta/sweep/sweet.arena
./q3map2_helper.sh --minimap map-sweet.pk3dir/maps/sweet.bsp
	create map-sweet.pk3dir/minimaps/sweet.crn and map-sweet.pk3dir/minimaps/sweet.minimap
./q3map2_helper.sh --navmesh map-sweet.pk3dir/maps/sweet.bsp
	create map-sweet.pk3dir/maps/sweet-*.navMesh files

ENVIRONMENT:

Q3MAP2=/path/to/q3map2
	override q3map2 binary path
DAEMONMAP/path/to/daemonmap
	override daemonmap binary path
CRUNCH=/path/to/crunch
	override crunch binary path
CONVERT=/path/to/convert
	override convert binary path
NOCRUNCH=y
	convert minimap to PNG instead of CRN image format
```


Warning
-------

No warranty is given, use this at your own risk.

Author
------

Thomas Debesse <dev@illwieckz.net>

Copyright
---------

This script is distributed under the highly permissive and laconic [ISC License](COPYING.md).
