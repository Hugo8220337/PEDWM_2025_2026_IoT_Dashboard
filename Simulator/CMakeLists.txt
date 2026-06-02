cmake_minimum_required(VERSION 3.16)
project(SparkplugSimulator)

set(CMAKE_CXX_STANDARD 17)

find_package(protobuf CONFIG REQUIRED)
find_package(PahoMqttCpp CONFIG REQUIRED)
find_package(nlohmann_json CONFIG REQUIRED)

add_executable(simulator
    src/main.cpp
    src/config.cpp
    src/sparkplug.cpp
    src/node_simulator.cpp
    proto/sparkplug_b.pb.cc
)

target_include_directories(simulator PRIVATE proto/ src/)

target_link_libraries(simulator
    protobuf::libprotobuf
    PahoMqttCpp::paho-mqttpp3
    nlohmann_json::nlohmann_json
)
