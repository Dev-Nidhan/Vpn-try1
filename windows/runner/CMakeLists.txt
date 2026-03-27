# Flutter Windows Configuration
cmake_minimum_required(VERSION 3.14)
project(runner LANGUAGES CXX)

set(BINARY_NAME "tinyvpn")

# Configure build options
set(CMAKE_CONFIGURATION_TYPES "Debug;Profile;Release" CACHE STRING "" FORCE)

# Add executable
add_executable(${BINARY_NAME} WIN32
  "main.cpp"
)

# Set Windows-specific properties
set_target_properties(${BINARY_NAME} PROPERTIES
  WIN32_EXECUTABLE TRUE
  OUTPUT_NAME ${BINARY_NAME}
)
