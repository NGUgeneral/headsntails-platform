# `headsntails` Platform (`headsntails-platform`)

This repository serves as the centralized orchestration and infrastructure hub for the **`headsntails` Ecosystem** - a high-performance, containerized multi-service feature flag evaluation platform. 

It handles local multi-container composition, internal isolated networking, edge proxy routing, and local state initialization.

## System Architecture & Network Topology

The platform is designed as a localized container monolith (Service Mesh Monolith). The public internet can only access the ecosystem through the Nginx Edge Ingress. All inter-service communications happen exclusively over an isolated private Docker bridge network (`headsntails-intranet`).

```text
                  [ PUBLIC TRAFFIC ]
                          │
                          ▼
              [ Edge Ingress / Nginx:80 ]
               /          │          \
      /api/v1/flags/  /api/v1/auth/  /api/v1/limiter/
             /            │            \ (Restricted)
            ▼             ▼             ▼
       [headsntails Core] [JWT Authority] [Rate Limiter]
        (Go:8080)     (Python:3000)   (Python:8000)
         │    │                             │
         │    └─────────(Intranet)──────────┤
         ▼                                  ▼
   [PostgreSQL] ───────────────────────► [Redis]
 (Write-Through)                       (Sliding Window)
```

---

## Architectural Roadmap & Evolution Strategy

The `headsntails` ecosystem is built using a milestone-driven evolution layout. Each phase transitions the ecosystem into higher performance brackets, systematically identifying and resolving distributed systems bottlenecks.

| Phase | Milestone | Core Focus | Architecture Impact | Status |
| :--- | :--- | :--- | :--- | :--- |
| **v0.1** | **Container Monolith Base** | Orchestrated REST Core | Edge Ingress routing, multi-language container isolation | **Released** |
| **v0.2** | **Source of Truth & Hydration** | Reliable State Handling | Write-Through pattern to PostgreSQL; ultra-fast reads from Redis | *In Progress* |
| **v0.3** | **Sidecar Latency Optimization** | gRPC Communication Layer | Migrate inter-service checks to gRPC to eliminate HTTP/1.1 HoL blocking | *Planned* |
| **v0.4** | **High-Perf Edge Layer** | Global gRPC Ingress | Transition public edge routing to utilize Protocol Buffers & HTTP/2 streaming | *Planned* |
| **v0.5** | **Advanced Targeting Engine**| Contextual Flag Evaluation | Abstract rule-matching evaluation engines beyond simple primitives | *Planned* |
| **v0.6** | **Distributed Event Bus** | Real-Time Cache Sync | Integrate RabbitMQ/Kafka to synchronize cache states across cross-region nodes | *Planned* |
| **v0.7** | **Cloud-Native Scale** | Infrastructure as Code | Multi-AZ AWS ECS Fargate deployment automated via Terraform | *Planned* |

---

## Sibling Repositories
The core ecosystem is decoupled across distinct, agnostic portfolio repositories:
* **Core Flag Engine (Go):** [headsntails-core](https://github.com/NGUgeneral/headsntails-core)
* **Auth Authority (Python/FastAPI):** [jwt-authority](https://github.com/NGUgeneral/jwt-authority)
* **Rate Limiter (Python/FastAPI):** [rate-limiter](https://github.com/NGUgeneral/rate-limiter)

## Local Development Setup

### Prerequisites
Ensure your local development environment has a parent workspace folder containing all four repositories pulled down side-by-side as siblings:
```text
workspace/
├── headsntails-core/
├── rate-limiter/
├── jwt-authority/
└── headsntails-platform/  <-- You are here
```

### Spinning Up the Stack
Navigate to this directory and boot the entire ecosystem with a single command:
```bash
docker-compose up --build
```
This command automatically triggers:
1. Dynamic compilation of the Go, Python, and Node images from sibling contexts.
2. Initialization of the PostgreSQL instance and execution of `./postgres/init.sql` schema configurations.
3. Boot-up of a password-secured standalone Redis cluster container.
4. Activation of the Nginx Ingress Controller on port `:80` with embedded CORS pre-flight policies.

### Sanity Verification
Test the entry gateway health status from your host terminal:
```bash
curl http://localhost/health
```

## 🔒 Security & Access Rules
* **Public Boundary:** Only `/api/v1/flags/*` and `/api/v1/auth/refresh` pass through the edge gateway freely with integrated CORS configurations.
* **Internal Boundary:** Global routes for the `rate-limiter` (like `/docs`) and `jwt-authority` (`/validate`) are locked behind an Nginx IP whitelist rule block, rejecting external client infiltration.
