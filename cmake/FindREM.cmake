# Find the system's librem includes and library
#
#  REM_INCLUDE_DIRS - where to find rem.h
#  REM_LIBRARIES    - List of libraries when using librem
#  REM_FOUND        - True if librem found

if(NOT WIN32)
  find_package(PkgConfig QUIET)
  pkg_search_module(REM rem QUIET)
endif()

find_path(REM_INCLUDE_DIR
  NAMES rem.h rem/rem.h
  HINTS
    "${REM_INCLUDE_DIRS}"
    "${REM_HINTS}/include"
  PATHS /usr/local/include /usr/include /usr/local/include/rem /usr/include/rem
)

find_library(REM_LIBRARY
  NAMES rem librem
  HINTS
    "${REM_LIBRARY_DIRS}"
    "${REM_HINTS}/lib"
  PATHS /usr/local/lib /usr/lib /usr/local/lib64 /usr/lib64
)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(REM DEFAULT_MSG REM_LIBRARY REM_INCLUDE_DIR)

if(REM_FOUND)
  set(REM_INCLUDE_DIRS ${REM_INCLUDE_DIR})
  set(REM_LIBRARIES ${REM_LIBRARY})
else()
  set(REM_INCLUDE_DIRS)
  set(REM_LIBRARIES)
endif()

mark_as_advanced(REM_LIBRARIES REM_INCLUDE_DIRS)


