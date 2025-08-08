#
# CMakeLists.txt
#
# Copyright (C) 2022 Sebastian Reimers
#

project(selftest)

include_directories(${RE_INCLUDE_DIRS} ${BARESIP_INCLUDE_DIRS})

add_executable(${PROJECT_NAME}
  account.c
  call.c
  cmd.c
  contact.c
  bevent.c
  jbuf.c
  jbuf_gnack.c
  menu.c
  message.c
  net.c
  play.c
  stunuri.c
  ua.c
  video.c

  mock/dnssrv.c

  sip/aor.c
  sip/auth.c
  sip/domain.c
  sip/location.c
  sip/sipsrv.c
  sip/user.c

  mock/cert.c

  mock/mock_aucodec.c
  mock/mock_auplay.c
  mock/mock_mnat.c
  mock/mock_vidcodec.c
  mock/mock_vidisp.c

  test.c

  main.c
)

if(TARGET rem::rem)
  set(_REM_TARGET rem::rem)
elseif(TARGET librem::librem)
  set(_REM_TARGET librem::librem)
endif()

if(_REM_TARGET)
  message(STATUS "Selftest linking with REM target: ${_REM_TARGET}")
  target_link_libraries(${PROJECT_NAME} baresip ${_REM_TARGET} ${RE_LIBRARIES})
else()
  target_link_libraries(${PROJECT_NAME} baresip ${RE_LIBRARIES})
endif()
