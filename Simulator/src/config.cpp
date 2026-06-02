#include "config.hpp"
#include <nlohmann/json.hpp>
#include <fstream>
#include <stdexcept>

using json = nlohmann::json;

Config load_config(const std::string &path)
{
    std::ifstream f(path);
    if (!f)
        throw std::runtime_error("Cannot open config: " + path);
    json j = json::parse(f);

    Config cfg;
    cfg.group = j.at("group").get<std::string>();

    for (const auto &jnode : j.at("nodes"))
    {
        Node node;
        node.name = jnode.at("name").get<std::string>();
        node.tick_s = jnode.at("tick_s").get<int>();
        for (const auto &jsensor : jnode.at("sensors"))
        {
            Sensor sensor;
            sensor.name = jsensor.at("name").get<std::string>();
            for (const auto &jvar : jsensor.at("variables"))
            {
                Variable var;
                var.name = jvar.at("name").get<std::string>();
                var.type = jvar.at("type").get<std::string>();
                var.min_val = jvar.at("min").get<float>();
                var.max_val = jvar.at("max").get<float>();
                var.interval_s = jvar.at("interval_s").get<int>();
                sensor.variables.push_back(std::move(var));
            }
            node.sensors.push_back(std::move(sensor));
        }
        cfg.nodes.push_back(std::move(node));
    }
    return cfg;
}
