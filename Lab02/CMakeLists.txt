cmake_minimum_required(VERSION 3.16)
project(ByteOrderDemo VERSION 1.0 LANGUAGES C)

set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_C_EXTENSIONS OFF)

add_library(byteorder STATIC byteorder.c)
target_include_directories(byteorder PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}")
target_compile_options(byteorder PRIVATE -Wall -Wextra -Wpedantic -Werror)

add_executable(byteorder-demo main.c)
target_link_libraries(byteorder-demo PRIVATE byteorder)
target_compile_options(byteorder-demo PRIVATE -Wall -Wextra -Wpedantic -Werror)
