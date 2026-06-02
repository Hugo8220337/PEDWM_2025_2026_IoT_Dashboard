<h1 align="center">Practical Work on Paradigmas Emergentes para o Desenvolvimento Web e Mobile (Emerging Paradigms for Web and Mobile Development)</h1>

<p align="center">
  <img src="http://img.shields.io/static/v1?style=for-the-badge&label=School%20year&message=2025/2026&color=GREEN"/>
  <img src="http://img.shields.io/static/v1?style=for-the-badge&label=Discipline&message=PEDWM&color=GREEN"/>
  <img src="http://img.shields.io/static/v1?style=for-the-badge&label=Grade&message=16&color=success"/>
</p>

---

## Real-Time IoT Dashboard

A real-time IoT Dashboard application designed to monitor and visualize sensor data seamlessly. Built with a reactive **Scala (ZIO)** backend and a **Flutter** frontend, utilizing **MQTT (Sparkplug B)** for device communication and **GraphQL Subscriptions** for real-time UI updates. 

Developed for the Master's in Informatics Engineering.

### Authors
* Diogo Pereira
* Hugo Guimarães

---

## Tech Stack

**Frontend (Web & Mobile):**
* Flutter & Dart
* GraphQL Subscriptions (WebSockets)
* Provider (State Management)
* Custom Interactive Dashboard Grid

**Backend & Infrastructure:**
* Scala & ZIO (Reactive Functional Programming)
* PostgreSQL (Time-series data storage)
* MQTT / Eclipse Mosquitto (Sparkplug B Protocol)
* Docker & Docker Compose

---

## Web Screenshots

<p align="center">
  <img src="docs/Relatorio_LaTeX/imagens/web_data_temporal_chart.png" alt="Web Dashboard View" width="800"/>
  <br>
  <em>Main Dashboard with real-time sensor gauges and time-series charts.</em>
</p>

---

## High-Level Architecture

The system follows a reactive, event-driven architecture designed for high scalability and real-time updates without blocking threads.

<p align="center">
  <img src="docs/Relatorio_LaTeX/imagens/architeture.jpg" alt="High-Level Architecture" width="800"/>
</p>

1. **Sensors / Simulator:** Publish telemetry data via MQTT using the Sparkplug B standard.
2. **Backend (Scala/ZIO):** Subscribes to MQTT topics, processes incoming `NDATA`/`NBIRTH` payloads concurrently using lightweight Fibers, persists history in PostgreSQL, and pushes updates.
3. **Frontend (Flutter):** Subscribes to the GraphQL endpoints via WebSockets to instantly reflect changes on the interactive dashboard.

---

## Sequence Diagram

<p align="center">
  <img src="docs/Relatorio_LaTeX/imagens/messages_sequence_diagram.png.png" alt="Sequence Diagram" width="800"/>
</p>
