#include "node_simulator.hpp"
#include "sparkplug.hpp"
#include <iostream>
#include <thread>
#include <chrono>

NodeSimulator::NodeSimulator(const std::string &group, const Node &node, mqtt::client &client)
    : group_(group), node_name_(node.name), tick_s_(node.tick_s), client_(client), rng_(std::random_device{}())
{
    auto now = std::chrono::steady_clock::now();
    for (const auto &sensor : node.sensors)
    {
        for (const auto &var : sensor.variables)
        {
            vars_.push_back({sensor.name + "/" + var.name,
                             var.min_val,
                             var.max_val,
                             var.interval_s,
                             now});
        }
    }
}

std::string NodeSimulator::nbirth_topic() const
{
    return "spBv1.0/" + group_ + "/NBIRTH/" + node_name_;
}

std::string NodeSimulator::ndata_topic() const
{
    return "spBv1.0/" + group_ + "/NDATA/" + node_name_;
}

float NodeSimulator::random_value(float min_val, float max_val)
{
    std::uniform_real_distribution<float> dist(min_val, max_val);
    return dist(rng_);
}

void NodeSimulator::publish_birth()
{
    org::eclipse::tahu::protobuf::Payload birth;
    birth.set_timestamp(now_ms());
    birth.set_seq(seq_++ % 256);

    for (const auto &v : vars_)
    {
        *birth.add_metrics() = make_metric(v.metric_name, 0.0f, now_ms());
    }

    client_.publish(mqtt::message(nbirth_topic(), serialize(birth), 0, false));
    std::cout << "[" << node_name_ << "] NBIRTH published (" << vars_.size() << " metrics)\n";
}

void NodeSimulator::tick()
{
    auto now = std::chrono::steady_clock::now();

    org::eclipse::tahu::protobuf::Payload data;
    data.set_timestamp(now_ms());
    data.set_seq(seq_ % 256);

    bool any = false;
    for (auto &v : vars_)
    {
        auto elapsed_s = std::chrono::duration_cast<std::chrono::seconds>(now - v.last_published).count();
        if (elapsed_s >= v.interval_s)
        {
            float val = random_value(v.min_val, v.max_val);
            *data.add_metrics() = make_metric(v.metric_name, val, now_ms());
            std::cout << "[" << node_name_ << "] " << v.metric_name << " = " << val << "\n";
            v.last_published = now;
            any = true;
        }
    }

    if (any)
    {
        ++seq_;
        client_.publish(mqtt::message(ndata_topic(), serialize(data), 0, false));
    }
}

void NodeSimulator::run(const std::atomic<bool> &running)
{
    std::cout << "[" << node_name_ << "] Thread started (tick=" << tick_s_ << "s)\n";
    while (running)
    {
        std::this_thread::sleep_for(std::chrono::seconds(tick_s_));
        if (running)
            tick();
    }
    std::cout << "[" << node_name_ << "] Thread stopped.\n";
}
