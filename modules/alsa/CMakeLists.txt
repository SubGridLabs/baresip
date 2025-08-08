project(alsa)

# Prefer Conan's CMake package (CMakeDeps) if available, fallback to system FindALSA
find_package(ALSA CONFIG QUIET)
if(NOT ALSA_FOUND)
  find_package(ALSA QUIET)
endif()

if(NOT ALSA_FOUND)
  return()
endif()

list(APPEND MODULES_DETECTED ${PROJECT_NAME})
set(MODULES_DETECTED ${MODULES_DETECTED} PARENT_SCOPE)

set(SRCS alsa.c alsa_play.c alsa_src.c)

if(STATIC)
  add_library(${PROJECT_NAME} OBJECT ${SRCS})
else()
  add_library(${PROJECT_NAME} MODULE ${SRCS})
endif()

# When using Conan (ALSA::ALSA target), includes and link flags are propagated by the target
if(TARGET ALSA::ALSA)
  target_link_libraries(${PROJECT_NAME} PRIVATE ALSA::ALSA)
else()
  target_include_directories(${PROJECT_NAME} PRIVATE ${ALSA_INCLUDE_DIRS})
  target_link_libraries(${PROJECT_NAME} PRIVATE ${ALSA_LIBRARIES})
endif()
