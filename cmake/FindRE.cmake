find_package(PkgConfig QUIET)
pkg_check_modules(PC_LIBRE QUIET libre)
pkg_check_modules(PC_LIBREM QUIET librem)

find_path(RE_INCLUDE_DIR
  NAME re.h
  HINTS
    ../re/include
    ${PC_LIBRE_INCLUDEDIR}
    ${PC_LIBRE_INCLUDE_DIRS}
  PATHS /usr/local/include/re /usr/include/re
)

find_library(RE_LIBRARY
  NAMES re libre re-static
  HINTS
    ../re
    ../re/build
    ../re/build/Debug
    ${PC_LIBRE_LIBDIR}
    ${PC_LIBRE_LIBRARY_DIRS}
  PATHS /usr/local/lib64 /usr/lib64 /usr/local/lib /usr/lib
)

# Some distributions/builds split media (rtp/sdp/aubuf) into a separate library
# called librem or rem. If present, find it and include it in RE_LIBRARIES.
find_library(REM_LIBRARY
  NAMES rem librem rem-static
  HINTS
    ../re
    ../re/build
    ../re/build/Debug
    ${PC_LIBREM_LIBDIR}
    ${PC_LIBREM_LIBRARY_DIRS}
    ${PC_LIBRE_LIBDIR}
    ${PC_LIBRE_LIBRARY_DIRS}
  PATHS /usr/local/lib64 /usr/lib64 /usr/local/lib /usr/lib
)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(RE DEFAULT_MSG RE_LIBRARY RE_INCLUDE_DIR)

mark_as_advanced(RE_INCLUDE_DIR RE_LIBRARY REM_LIBRARY)

set(RE_INCLUDE_DIRS ${RE_INCLUDE_DIR})
set(RE_LIBRARIES ${RE_LIBRARY})
if(REM_LIBRARY)
  list(APPEND RE_LIBRARIES ${REM_LIBRARY})
endif()
