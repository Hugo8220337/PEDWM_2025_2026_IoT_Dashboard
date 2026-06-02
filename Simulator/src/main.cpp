#include <iostream>
#include <csignal>
#include <thread>
#include <vector>
#include <atomic>

#include <mqtt/client.h>
#include "config.hpp"
#include "sparkplug.hpp"
#include "node_simulator.hpp"

std::atomic<bool> running{true};
void on_signal(int) { running = false; }

int main()
{
    std::signal(SIGINT, on_signal);

    Config cfg;
    try
    {
        cfg = load_config("files/Sensors.json");
    }
    catch (const std::exception &e)
    {
        std::cerr << "Failed to load config: " << e.what() << "\n";
        return 1;
    }

    const std::string broker = "tcp://mosquitto:1883";
    // const std::string broker = "tcp://localhost:1883";
    const std::string client_id = "simulator";

    mqtt::client client(broker, client_id);
    mqtt::connect_options opts;
    opts.set_clean_session(true);

    org::eclipse::tahu::protobuf::Payload death_payload;
    death_payload.set_timestamp(now_ms());
    death_payload.set_seq(0);
    std::string death_bytes = serialize(death_payload);

    std::string lwt_topic = "spBv1.0/" + cfg.group + "/NDEATH/" + cfg.nodes[0].name;
    opts.set_will(mqtt::will_options(lwt_topic, death_bytes, 0, false));

    std::cout << "Connecting to " << broker << "...\n";
    client.connect(opts);
    std::cout << "Connected.\n";

    std::vector<NodeSimulator> simulators;
    simulators.reserve(cfg.nodes.size());
    for (auto &node : cfg.nodes)
    {
        simulators.emplace_back(cfg.group, node, client);
        simulators.back().publish_birth();
    }

    std::vector<std::thread> threads;
    threads.reserve(simulators.size());
    for (auto &sim : simulators)
    {
        threads.emplace_back(&NodeSimulator::run, &sim, std::cref(running));
    }

    for (auto &t : threads)
        t.join();

    for (const auto &node : cfg.nodes)
    {
        std::string topic = "spBv1.0/" + cfg.group + "/NDEATH/" + node.name;
        client.publish(mqtt::message(topic, death_bytes, 0, false));
        std::cout << "[" << node.name << "] NDEATH published.\n";
    }

    client.disconnect();
    std::cout << "Disconnected.\n";
    return 0;
}
