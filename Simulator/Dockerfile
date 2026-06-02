FROM debian:bookworm AS builder

ENV DEBIAN_FRONTEND=noninteractive

# build-essential gives us gcc, g++, and make in one shot
# perl is required by OpenSSL's build system (pulled in by paho-mqttpp3)
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential cmake git curl zip unzip tar pkg-config perl ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/microsoft/vcpkg /opt/vcpkg \
    && /opt/vcpkg/bootstrap-vcpkg.sh -disableMetrics

ENV VCPKG_ROOT=/opt/vcpkg

WORKDIR /app

# Copy the manifest first so vcpkg's dependency build is cached independently
# of source changes — rebuilding main.cpp won't re-run the vcpkg install step
COPY vcpkg.json .
RUN --mount=type=cache,target=/root/.cache/vcpkg \
    /opt/vcpkg/vcpkg install --triplet x64-linux --no-print-usage

COPY CMakeLists.txt .
COPY proto/ proto/
COPY src/ src/

RUN cmake -B build \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_TOOLCHAIN_FILE=/opt/vcpkg/scripts/buildsystems/vcpkg.cmake \
    -DVCPKG_TARGET_TRIPLET=x64-linux \
    && cmake --build build -j$(nproc)

# ── Runtime ───────────────────────────────────────────────────────────────────
FROM debian:bookworm-slim

WORKDIR /app

# Copy the binary and the shared libraries vcpkg built
COPY --from=builder /app/build/simulator /usr/local/bin/simulator
COPY --from=builder /app/vcpkg_installed/x64-linux/lib/ /usr/local/lib/
COPY files/ files/

# Rebuild the linker cache so the runtime can find the copied .so files
RUN ldconfig

CMD ["simulator"]
