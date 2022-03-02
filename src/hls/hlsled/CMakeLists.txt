cmake_minimum_required(VERSION 3.14)
project(hlsled)

add_hls_project(hlsled
  TOP HlsLED
  VERSION 1.0
  VENDOR nodamushi
  NAME "HLS LED Chika"
  PERIOD 10 # 100MHz
  PART xc7z007sclg400-1
  SOURCES hlsled.cpp
  # Test
  TB_SOURCES tb.cpp
)

add_test(
  NAME test_hlsled
  COMMAND $<TARGET_FILE:test_hlsled>)
