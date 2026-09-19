# Mock Device Simulator Suite

The project includes a built-in Mock Device Simulator to test the entire application end-to-end without requiring physical hardware.

## Running the Simulators

### Option 1: Via Python CLI
```bash
python -m backend.simulator.runner
```

### Option 2: Via Docker Compose
```bash
docker compose up simulator
```

## Simulated Devices and Endpoints

| Device | Protocol | Port | Endpoint | Features |
| :--- | :--- | :--- | :--- | :--- |
| **Dashboard** | HTTP REST | `8080` | `http://localhost:8080/` | Live status of all mock targets |
| **Samsung QLED TV** | WebSocket (Tizen) | `8081` | `ws://localhost:8081/api/v2/channels/samsung.remote.control` | Token pairing handshake & key ACK |
| **LG OLED webOS** | WebSocket (SSAP) | `8082` | `ws://localhost:8082/` | Client-key registration, volume, mute |
| **Sony Bravia 4K** | HTTP REST (IRCC-IP) | `8083` | `http://localhost:8083/sony/ircc` | PSK authentication (`0000`), XML parsing |
| **Tata Play STB** | HTTP REST | `8084` | `http://localhost:8084/stb/command` | Channel tuning, power, volume state |

## Verifying Simulation
1. Start the simulator:
   ```bash
   python -m backend.simulator.runner
   ```
2. Open your browser or run curl to inspect the dashboard:
   ```bash
   curl http://localhost:8080/
   ```
3. Run the automated integration test suite:
   ```bash
   pytest backend/tests/test_simulators.py -v
   ```
