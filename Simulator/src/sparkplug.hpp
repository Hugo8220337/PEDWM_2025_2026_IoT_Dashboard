#pragma once
#include "sparkplug_b.pb.h"
#include <string>
#include <cstdint>

uint64_t now_ms();
std::string serialize(const org::eclipse::tahu::protobuf::Payload &payload);
org::eclipse::tahu::protobuf::Payload_Metric make_metric(const std::string &name, float value, uint64_t ts);
