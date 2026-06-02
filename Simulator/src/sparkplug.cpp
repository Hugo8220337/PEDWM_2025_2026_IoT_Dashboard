#include "sparkplug.hpp"
#include <chrono>

uint64_t now_ms()
{
    return std::chrono::duration_cast<std::chrono::milliseconds>(
               std::chrono::system_clock::now().time_since_epoch())
        .count();
}

std::string serialize(const org::eclipse::tahu::protobuf::Payload &payload)
{
    std::string out;
    payload.SerializeToString(&out);
    return out;
}

org::eclipse::tahu::protobuf::Payload_Metric make_metric(const std::string &name, float value, uint64_t ts)
{
    org::eclipse::tahu::protobuf::Payload_Metric m;
    m.set_name(name);
    m.set_timestamp(ts);
    m.set_float_value(value);
    m.set_datatype(9); // Float in SparkplugB spec
    return m;
}
