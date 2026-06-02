#pragma once
#include "config.hpp"
#include "sparkplug_b.pb.h"
#include <mqtt/client.h>
#include <atomic>
#include <chrono>
#include <random>
#include <string>
#include <vector>
#include <cstdint>

class NodeSimulator
{
public:
    NodeSimulator(const std::string &group, const Node &node, mqtt::client &client);
    void publish_birth();
    void run(const std::atomic<bool> &running);

private:
    struct VarState
    {
        std::string metric_name;
        float min_val;
        float max_val;
        int interval_s;
        std::chrono::steady_clock::time_point last_published;
    };

    std::string group_;
    std::string node_name_;
    int tick_s_;
    mqtt::client &client_;
    std::vector<VarState> vars_;
    std::mt19937 rng_;
    uint64_t seq_ = 0;

    std::string nbirth_topic() const;
    std::string ndata_topic() const;
    float random_value(float min_val, float max_val);
    void tick();
};
