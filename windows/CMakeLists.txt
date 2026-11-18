cmake_minimum_required(VERSION 3.14)
project(easy_player LANGUAGES CXX)

set(BINARY_NAME "EasyPlayer")

cmake_policy(SET CMP0079 NEW)

set(INSTALL_BUNDLE_DATA_DIR "${CMAKE_INSTALL_PREFIX}/data")
set(INSTALL_BUNDLE_LIB_DIR "${CMAKE_INSTALL_PREFIX}")

add_subdirectory(flutter)
add_subdirectory(runner)
