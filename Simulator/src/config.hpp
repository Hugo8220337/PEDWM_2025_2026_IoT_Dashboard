#pragma once
#include <string>
#include <vector>

struct Variable
{
    std::string name;
    std::string type;
    float min_val;
    float max_val;
    int interval_s;
};

struct Sensor
{
    std::string name;
    std::vector<Variable> variables;
};

struct Node
{
    std::string name;
    int tick_s;
    std::vector<Sensor> sensors;
};

struct Config
{
    std::string group;
    std::vector<Node> nodes;
};

Config load_config(const std::string &path);
