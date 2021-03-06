#! /bin/sh

# Author:  Thomas DEBESSE <dev@illwieckz.net>
# License: ISC

TAB="$(printf '\t')"

# Override these variables to use binaries that are not in your default path or to use others instead.

if [ "x${Q3MAP2}" = 'x' ]
then
	Q3MAP2="q3map2"
fi

if [ "x${DAEMONMAP}" = 'x' ]
then
	DAEMONMAP="daemonmap"
fi

if [ "x${CRUNCH}" = 'x' ]
then
	CRUNCH="crunch"
fi

if [ "x${CONVERT}" = 'x' ]
then
	CONVERT="convert"
fi

if [ "x${NOCRUNCH}" = 'x' ]
then
	alias nocrunch=false
else
	alias nocrunch=true
fi

_prepare () {
	if ! [ -f "${1}" ]
	then
		echo "Error: file “${1}” not found"
		false
		return
	fi

	MAP_NAME="$(basename "${1}" '.bsp')"

	dir_name="$(dirname ${1})"
	if [ "$(echo "${dir_name}" | sed -e 's#.*/##g')" = 'maps' ]
	then
		MAP_DIR="${dir_name}"
		MINIMAP_DIR="${dir_name}/../minimaps"
		META_DIR="${dir_name}/../meta/${MAP_NAME}"
	else
		MAP_DIR="${dir_name}"
		MINIMAP_DIR="${dir_name}"
		META_DIR="${dir_name}"
	fi
}

_arena () {
	_prepare "${1}" || return
	mkdir -p "${META_DIR}" || return

	if [ "x${2}" = 'x' ]
	then
		printf "Enter LONG_NAME: "
		read LONG_NAME
	else
		LONG_NAME="${2}"
	fi

	echo "writing to: ${META_DIR}/${MAP_NAME}.arena"
	tee "${META_DIR}/${MAP_NAME}.arena" <<-EOF
	{
	${TAB}map${TAB}${TAB}"${MAP_NAME}"
	${TAB}longname${TAB}"${LONG_NAME}"
	${TAB}type${TAB}${TAB}"tremulous"
	}
	EOF
}

_decompile () {
	_prepare "${1}" || return

	"${Q3MAP2}" -convert -format map "${1}"
}

_navmesh () {
	_prepare "${1}" || return

	"${DAEMONMAP}" -game unv -nav "${1}"
}

_minimap () {
	_prepare "${1}" || return
	mkdir -p "${MINIMAP_DIR}" || return
	temp_file="$(mktemp /tmp/daemonmap-minimap.XXXXXXXX)"

	"${Q3MAP2}" -minimap -samples 10 -size 512 -border 0.0 "${1}" | tee "${temp_file}"

	minimap_coords="$(grep '^size_texcoords' "${temp_file}" | sed -e 's/^size_texcoords \([0-9.-]*\) \([0-9.-]*\) [0-9.-]* \([0-9.-]*\) \([0-9.-]*\) [0-9.-]*$/\1 \2 \3 \4/')"
	rm "${temp_file}"

	cat > "${MINIMAP_DIR}/${MAP_NAME}.minimap" <<-EOF
	{
	${TAB}backgroundColor 0.0 0.0 0.0 0.333

	${TAB}zone {
	${TAB}${TAB}bounds 0 0 0 0 0 0
	${TAB}${TAB}image "minimaps/${MAP_NAME}" ${minimap_coords}
	${TAB}}
	}
	EOF

	if nocrunch
	then
		convert "${MAP_DIR}/${MAP_NAME}.tga" "${MINIMAP_DIR}/${MAP_NAME}.png"
		rm "${MAP_DIR}/${MAP_NAME}.tga" 
	else
		"${CRUNCH}" -file "${MAP_DIR}/${MAP_NAME}.tga" -out "${MINIMAP_DIR}/${MAP_NAME}.crn"
		rm "${MAP_DIR}/${MAP_NAME}.tga" 
	fi
}

_help () {
	cat <<-EOF
	USAGE:
	${TAB}${0} [OPTIONS] [PARAMETERS]

	OPTIONS:
	-a, --arena BSP_FILENAME LONG_NAME
	${TAB}create a arena file for BSP_FILENAME (ask interactively for LONG_NAME if not given on command line)
	-d, --decompile
	${TAB}decompile BSP_FILENAME
	-m, --minimap
	${TAB}create a minimap for BSP_FILENAME
	-n, --navmesh
	${TAB}create navmeshes for BSP_FILENAME
	-h, --help
	${TAB}print this help

	EXAMPLES:
	${0} --arena map-sweet.pk3dir/maps/sweet.bsp "Sweet map for the lovely granger"
	${TAB}create the file map-sweet.pk3dir/meta/sweep/sweet.arena
	${0} --minimap map-sweet.pk3dir/maps/sweet.bsp
	${TAB}create map-sweet.pk3dir/minimaps/sweet.crn and map-sweet.pk3dir/minimaps/sweet.minimap
	${0} --navmesh map-sweet.pk3dir/maps/sweet.bsp
	${TAB}create map-sweet.pk3dir/maps/sweet-*.navMesh files

	ENVIRONMENT:

	Q3MAP2=/path/to/q3map2
	${TAB}override q3map2 binary path
	DAEMONMAP=/path/to/daemonmap
	${TAB}override daemonmap binary path, useful if you use a q3map2 build with navmesh support, use it instead
	CRUNCH=/path/to/crunch
	${TAB}override crunch binary path
	CONVERT=/path/to/convert
	${TAB}override convert binary path
	NOCRUNCH=y
	${TAB}convert minimap to PNG instead of CRN image format

	EOF
}

_main () {
	case "${1}" in
		-a|--arena)
			_arena "${2}" "${3}"
		;;
		-d|--decompile)
			_decompile "${2}"
		;;
		-m|--minimap)
			_minimap "${2}"
		;;
		-n|--navmesh)
			_navmesh "${2}"
		;;
		-h|--help)
			_help
		;;
	esac
}

_main "${1}" "${2}" "${3}"

#EOF
