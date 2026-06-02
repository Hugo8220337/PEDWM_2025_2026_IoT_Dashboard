# 📚 Documentação Completa do Backend

## Índice
1. [Visão Geral](#visão-geral)
2. [Stack Tecnológico](#stack-tecnológico)
3. [Arquitetura](#arquitetura)
4. [Estrutura de Pastas](#estrutura-de-pastas)
5. [Componentes Principais](#componentes-principais)
6. [Fluxo de Dados](#fluxo-de-dados)
7. [Base de Dados](#base-de-dados)
8. [API GraphQL](#api-graphql)
9. [Integração MQTT](#integração-mqtt)
10. [Configuração e Deploy](#configuração-e-deploy)

---

## Visão Geral

Este é um backend implementado em **Scala** que funciona como um middleware para:
- **Receber dados de sensores IoT** através do protocolo **MQTT** (usando Sparkplug B)
- **Processar e armazenar** esses dados em PostgreSQL
- **Expor uma API GraphQL** em tempo real para consultar sensores e métricas
- **Fazer broadcast de dados vivos** para clientes conectados via GraphQL subscriptions

### Principais Características
- ✅ Processamento assíncrono e reativo (ZIO)
- ✅ Suporte a Sparkplug B (protocolo industrial MQTT)
- ✅ API GraphQL com subscriptions em tempo real
- ✅ Persistência em PostgreSQL com migrations automáticas (Flyway)
- ✅ Node registry em memória para resolução rápida de métricas
- ✅ Containerizado com Docker

---

## Stack Tecnológico

| Componente | Versão | Propósito |
|-----------|--------|----------|
| **Scala** | 3.8.3 | Linguagem principal |
| **ZIO** | 2.1.14 | Efeitos assincronos, gerenciamento de recursos |
| **Doobie** | 1.0.0-RC4 | Acesso a banco de dados |
| **PostgreSQL** | 42.7.3 | Base de dados relacional |
| **Flyway** | 9.22.3 | Versionamento e migrations de BD |
| **Caliban** | 2.9.0 | GraphQL server |
| **ZIO HTTP** | 3.0.0 | HTTP server |
| **Eclipse Paho** | 1.2.5 | Cliente MQTT |
| **ScalaPB** | - | Protobuf para Sparkplug B |

---

## Arquitetura

O projeto segue a **Arquitetura Hexagonal (Ports & Adapters)** com separação clara de camadas:

```
┌─────────────────────────────────────────────┐
│     Apresentação: GraphQL API               │
├─────────────────────────────────────────────┤
│  Aplicação: Use Cases & Event Handlers      │
│  (Business Logic)                           │
├─────────────────────────────────────────────┤
│  Domínio: Entidades & Regras Puras         │
│  (Models & Repositories)                    │
├─────────────────────────────────────────────┤
│  Infraestrutura: Implementações Concretas  │
│  (BD, MQTT, GraphQL, Memória)              │
└─────────────────────────────────────────────┘
```

### Principios
- **Inversão de Controlo**: Ports (traits) definem interfaces
- **Injeção de Dependência**: ZIO Layers gerem dependências
- **Separação de Concerns**: Cada camada tem responsabilidade única

---

## Estrutura de Pastas

```
backend/
├── src/main/scala/
│   ├── Main.scala                           # Ponto de entrada da aplicação
│   ├── aspect/
│   │   └── LoggingAspect.scala             # Cross-cutting concerns (logging, timing)
│   ├── domain/                              # Camada de Domínio
│   │   ├── model/
│   │   │   ├── Sensor.scala                # Entidade: sensor IoT
│   │   │   ├── MetricReading.scala         # Entidade: leitura de métrica
│   │   │   └── SparkplugEvent.scala        # Sealed traits de eventos
│   │   └── repository/
│   │       ├── SensorRepository.scala      # Interface de persistência
│   │       └── MetricReadingRepository.scala # Interface de persistência
│   ├── application/                         # Camada de Aplicação
│   │   ├── port/
│   │   │   ├── NodeRegistry.scala          # Port: Registro de nós em memória
│   │   │   ├── MetricBroadcast.scala       # Port: Broadcasting de métricas
│   │   │   ├── RawMqttMessage.scala        # Port: Mensagem MQTT
│   │   │   ├── MessageProcessor.scala      # Port: Processador de mensagens
│   │   │   └── EventHandler.scala          # Port: Handler de eventos
│   │   └── usecase/
│   │       ├── SparkplugMessageProcessor.scala  # Processa mensagens Sparkplug B
│   │       ├── SparkplugEventHandler.scala      # Manipula eventos gerados
│   │       ├── MessageProcessor.scala           # Trait da port
│   │       └── EventHandler.scala               # Trait da port
│   └── infrastructure/                      # Camada de Infraestrutura
│       ├── config/
│       │   ├── DatabaseConfig.scala        # Config da BD (vars de ambiente)
│       │   ├── MqttConfig.scala            # Config do MQTT
│       │   └── LogConfig.scala             # Config de logging
│       ├── database/
│       │   └── Database.scala              # Setup Doobie, pool de conexões, Flyway
│       ├── repository/
│       │   ├── PostgresSensorRepository.scala
│       │   └── PostgresMetricReadingRepository.scala
│       ├── mqtt/
│       │   └── MqttSubscriber.scala        # Cliente MQTT com ZIO
│       ├── sparkplug/
│       │   ├── SparkplugDecoder.scala      # Decoder de protobuf
│       │   └── SparkplugTopic.scala        # Parser de topics Sparkplug B
│       ├── memory/
│       │   ├── InMemoryNodeRegistry.scala  # Implementação de NodeRegistry
│       │   └── InMemoryMetricBroadcast.scala # Implementação de MetricBroadcast
│       └── graphql/
│           ├── GraphQLApi.scala            # Definição do schema GraphQL
│           └── GraphQLServer.scala         # Servidor HTTP
├── project/
│   └── build.properties                    # Configurações de build
├── build.sbt                               # Definição de dependências
├── Dockerfile                              # Container multi-stage
├── docker-compose.yml                      # Serviços (BD, MQTT)
├── .env.example                            # Template de variáveis de ambiente
└── src/main/resources/
    └── db/migration/                       # Scripts SQL (Flyway)
```

---

## Componentes Principais

### 1. **Domain Models** 📦

#### `Sensor.scala`
```scala
case class Sensor(
  id: UUID,
  groupId: String,        // Ex: "Industrial"
  nodeId: String,         // Ex: "Node-1"
  sensorName: String,     // Ex: "Temperatura"
  variableName: String,   // Ex: "Celsius"
  dataType: String,       // Ex: "Double"
  discoveredAt: Instant,  // Quando foi descoberto
  isAvailable: Boolean    // Estado atual
)
```
- Representa um sensor físico/lógico no sistema
- Persistido em PostgreSQL

#### `MetricReading.scala`
```scala
case class MetricReading(
  id: UUID,
  sensorId: UUID,         // Referência ao sensor
  timestamp: Instant,     // Quando foi medido
  value: Double          // Valor da métrica
)
```
- Leitura individual de um sensor
- Histórico completo guardado na BD

#### `SparkplugEvent.scala` (Sealed Trait Pattern)
```scala
sealed trait SparkplugEvent

case class NodeDiscovered(groupId: String, nodeId: String, sensors: List[Sensor]) 
  extends SparkplugEvent
case class MetricReceived(sensor: Sensor, value: Double, timestamp: Long) 
  extends SparkplugEvent
case class NodeLost(groupId: String, nodeId: String) 
  extends SparkplugEvent
```
- Eventos imutáveis gerados pelo processamento MQTT
- Usados para reatividade e propagação de estado

---

### 2. **Application Ports** 🚪

São interfaces (traits) que definem contratos entre camadas:

#### `NodeRegistry`
```scala
trait NodeRegistry:
  def register(groupId: String, nodeId: String, sensors: List[Sensor]): Task[Unit]
  def resolve(groupId: String, nodeId: String, metricName: String): Task[Option[Sensor]]
  def remove(groupId: String, nodeId: String): Task[Unit]
```
- Mantém em memória um índice rápido de sensores por nó
- Implementação: `InMemoryNodeRegistry`

#### `MetricBroadcast`
```scala
trait MetricBroadcast:
  def publish(event: MetricReceived): UIO[Unit]
  def subscribe: ZStream[Any, Nothing, MetricReceived]
```
- Pub/sub para métricas em tempo real
- Implementação: `InMemoryMetricBroadcast` (com Queue)

#### `MessageProcessor` & `EventHandler`
- Processam mensagens MQTT → eventos
- Implementações Sparkplug-específicas

---

### 3. **Use Cases** 🎯

#### `SparkplugMessageProcessor`
**Responsabilidade**: Converter mensagens MQTT em eventos de domínio

Fluxo:
1. Recebe mensagem MQTT bruta
2. Parse do topic Sparkplug B (`spBv1.0/GROUP/NODE/DCMD|NBIRTH|NDEATH|NDATA`)
3. Decode do payload (protobuf)
4. Roteamento por tipo:
   - **NBirth** (Node Birth): Novo nó + sensores descob
   - **NData**: Dados de métrica
   - **NDeath**: Nó desapareceu

```scala
class SparkplugMessageProcessor(registry: NodeRegistry):
  def process(msg: RawMqttMessage): Task[List[SparkplugEvent]] = ...
```

#### `SparkplugEventHandler`
**Responsabilidade**: Persistir eventos e fazer broadcast

```scala
class SparkplugEventHandler(
  metricReadingRepo: MetricReadingRepository,
  broadcast: MetricBroadcast
):
  def handle(event: SparkplugEvent): Task[Unit] =
    event match
      case NodeDiscovered(...) => // Log apenas
      case MetricReceived(sensor, value, timestamp) => 
        // Insere na BD + publica no broadcast
      case NodeLost(...) => // Log + marca indisponível
```

---

### 4. **Infrastructure Adapters** 🔌

#### **MQTT Subscriber**
```scala
class MqttSubscriber(queue: Queue[RawMqttMessage]):
  val messages: ZStream[RawMqttMessage]
```
- Conecta ao broker MQTT (via Eclipse Paho)
- Subscreve a `spBv1.0/#` (todos os tópicos Sparkplug)
- Enfileira mensagens para processamento assíncrono
- Reconecta automaticamente em caso de falha

#### **Database Layer (Doobie)**
```scala
object Database:
  val transactorLayer: ZLayer[DatabaseConfig, Throwable, Transactor[Task]]
```
- Setup HikariCP (pool de conexões)
- Flyway migrations automáticas
- Transactional queries com Doobie

#### **PostgreSQL Repositories**
Exemplo: `PostgresSensorRepository`
```scala
class PostgresSensorRepository(xa: Transactor[Task]):
  def upsert(sensor: Sensor): Task[Sensor] = 
    // INSERT ... ON CONFLICT ... DO UPDATE (upsert idempotente)
  
  def findByNode(groupId: String, nodeId: String): Task[List[Sensor]] = ...
  def setAvailability(...): Task[Unit] = ...
```
- Queries SQL com type-safety (Doobie)
- Logging automático de timing (Aspect)

#### **In-Memory Services**
- `InMemoryNodeRegistry`: Cache de sensores por nó (rápido!)
- `InMemoryMetricBroadcast`: ZStream para subscriptions GraphQL

#### **GraphQL Server**
- Schema automático com Caliban
- Queries: nós, sensores, histórico de métricas
- Subscriptions: Métricas em tempo real
- HTTP server com ZIO HTTP

---

## Fluxo de Dados

```
┌─────────────────┐
│   MQTT Broker   │
└────────┬────────┘
         │ spBv1.0/GROUP/NODE/NBIRTH
         │ {"metrics": [...]}
         │
    ┌────▼─────────────────────────────────┐
    │ MqttSubscriber                        │
    │ (Eclipse Paho)                        │
    └────┬─────────────────────────────────┘
         │ RawMqttMessage
         │
    ┌────▼──────────────────────────────────────┐
    │ SparkplugMessageProcessor                 │
    │ 1. Parse topic                            │
    │ 2. Decode protobuf                        │
    │ 3. Gera eventos (NodeDiscovered/etc)      │
    └────┬───────────────────────────────────────┘
         │ List[SparkplugEvent]
         │
    ┌────▼──────────────────────────────────────┐
    │ SparkplugEventHandler                     │
    │ 1. Valida evento                          │
    │ 2. Insere em BD (MetricReading)           │
    │ 3. Publica no broadcast                   │
    └────┬───────────────────────────────────────┘
         │ MetricReceived (publicado)
         │
    ┌────▼────────────────────────┐
    │ InMemoryMetricBroadcast     │
    │ (ZStream)                   │
    └────┬───────────────────────┬┘
         │                       │
    ┌────▼─────┐            ┌────▼──────────┐
    │GraphQL    │            │PostgreSQL      │
    │Subscriptions           │(Persistência)  │
    │(tempo real)│            │               │
    └──────────┘            └────────────────┘
```

### Exemplo Prático
1. **Sensor envia**: `spBv1.0/Industrial/Node-1/NDATA` com temperatura=22.5°C
2. **MqttSubscriber recebe** e enfileira
3. **SparkplugMessageProcessor**:
   - Parse: `groupId="Industrial"`, `nodeId="Node-1"`
   - Lookup em `NodeRegistry`: Encontra sensor "Temperatura/Celsius"
   - Cria evento: `MetricReceived(sensor, 22.5, timestamp)`
4. **SparkplugEventHandler**:
   - Insere `MetricReading` na BD
   - Publica no broadcast
5. **Cliente GraphQL subscrito** recebe atualização em tempo real

---

## Base de Dados

### Schema (via Flyway Migrations)
```sql
-- sensor
CREATE TABLE sensor (
    id UUID PRIMARY KEY,
    group_id VARCHAR(255) NOT NULL,
    node_id VARCHAR(255) NOT NULL,
    sensor_name VARCHAR(255) NOT NULL,
    variable_name VARCHAR(255) NOT NULL,
    data_type VARCHAR(255),
    discovered_at TIMESTAMP NOT NULL,
    is_available BOOLEAN DEFAULT true,
    UNIQUE(group_id, node_id, sensor_name, variable_name)
);

-- metric_reading
CREATE TABLE metric_reading (
    id UUID PRIMARY KEY,
    sensor_id UUID NOT NULL REFERENCES sensor(id),
    timestamp TIMESTAMP NOT NULL,
    value DOUBLE PRECISION NOT NULL
);

-- Índices para queries rápidas
CREATE INDEX ON metric_reading(sensor_id, timestamp DESC);
CREATE INDEX ON sensor(group_id, node_id);
```

### Acesso (Doobie + HikariCP)
- **Connection Pool**: Até 10 conexões simultâneas (configurável)
- **Type Safety**: Queries compiladas em tempo de compilação
- **Transações**: Automáticas com Doobie

---

## API GraphQL

### Endpoint
`http://localhost:8080/graphql`

### Schema
```graphql
type Query {
  nodes: [NodeView!]!
  sensors(groupId: String!, nodeId: String!): [SensorView!]!
  readings(sensorId: String!, limit: Int): [ReadingView!]!
}

type Subscription {
  liveReadings(sensorId: String!): ReadingView!
}

type SensorView {
  id: String!
  groupId: String!
  nodeId: String!
  sensorName: String!
  variableName: String!
  dataType: String!
  isAvailable: Boolean!
}

type ReadingView {
  id: String!
  sensorId: String!
  timestamp: Long!      # Epoch millis
  value: Double!
}

type NodeView {
  nodeId: String!
  isAvailable: Boolean!
  sensors: [SensorView!]!
}
```

### Exemplos de Queries

**Listar todos os nós e sensores:**
```graphql
query {
  nodes {
    nodeId
    isAvailable
    sensors {
      sensorName
      variableName
      dataType
    }
  }
}
```

**Histórico de leituras (últimas 100):**
```graphql
query {
  readings(sensorId: "abc123", limit: 100) {
    timestamp
    value
  }
}
```

**Subscrição em tempo real:**
```graphql
subscription {
  liveReadings(sensorId: "abc123") {
    timestamp
    value
  }
}
```

---

## Integração MQTT

### Broker Configuration
```env
MQTT_BROKER_URL=tcp://mqtt:1883
MQTT_CLIENT_ID=pedwm-backend
MQTT_PORT=1883
```

### Topic Structure (Sparkplug B)
```
spBv1.0/GROUP/NODE/TYPE/...

Exemplos:
- spBv1.0/Industrial/Node-1/NBIRTH    # Nó nasceu (com sensores)
- spBv1.0/Industrial/Node-1/NDATA     # Dados de métrica
- spBv1.0/Industrial/Node-1/NDEATH    # Nó morreu

Tipos reconhecidos:
- NBIRTH: Node Birth (discovery)
- NDEATH: Node Death
- NDATA: Node Data (métricas)
```

### Payload (Protobuf)
Usa `scalapb` + `eclipse-tahu` para decode automático de Sparkplug B payload.

Cada métrica em NDATA tem:
- `name`: "SensorName/VariableName"
- `datatype`: Tipo (DOUBLE, INT32, BOOLEAN, etc.)
- `timestamp`: When measured
- `value`: Valor (tipo dinâmico)

---

## Configuração e Deploy

### Variáveis de Ambiente
```env
# Database
POSTGRES_DB=pedwm
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres
POSTGRES_PORT=5432
DB_URL=jdbc:postgresql://localhost:5432/pedwm
DB_USER=postgres
DB_PASSWORD=postgres

# MQTT
MQTT_BROKER_URL=tcp://mqtt:1883
MQTT_CLIENT_ID=pedwm-backend
MQTT_PORT=1883
```

### Docker Compose
```yaml
services:
  postgres:
    image: postgres:16
    environment:
      POSTGRES_DB: ${POSTGRES_DB}
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data

  mqtt:
    image: eclipse-mosquitto:latest
    ports:
      - "1883:1883"
    volumes:
      - ./mosquitto.conf:/mosquitto/config/mosquitto.conf

  backend:
    build: ./backend
    ports:
      - "8080:8080"
    environment:
      DB_URL: jdbc:postgresql://postgres:5432/pedwm
      DB_USER: ${POSTGRES_USER}
      DB_PASSWORD: ${POSTGRES_PASSWORD}
      MQTT_BROKER_URL: tcp://mqtt:1883
    depends_on:
      - postgres
      - mqtt
```

### Build e Deploy

**Compile (SBT):**
```bash
sbt compile
```

**Criar JAR assembly:**
```bash
sbt assembly
```

**Docker build:**
```bash
docker build -t pedwm-backend:latest .
```

**Correr com Docker Compose:**
```bash
docker-compose up --build
```

### Dockerfile (Multi-stage)
1. **Builder stage**: Instala SBT, compila código, cria JAR
2. **Runtime stage**: Copia JAR, runs com Java 21

---

## Como Funciona (Resumido)

### Startup
1. **Main.scala** é executado
2. Carrega layers ZIO (BD, MQTT, repositórios, etc.)
3. Inicia `GraphQLServer` (HTTP port 8080)
4. Inicia `MqttSubscriber` (conecta ao broker, começa a receber mensagens)
5. Cria stream de processamento:
   - MQTT messages → SparkplugMessageProcessor
   - Events → SparkplugEventHandler
   - Handler persiste + broadcast

### During Operation
- Mensagens MQTT chegam continuamente
- Processadas assincronamente (sem bloquear)
- Armazenadas em BD
- Clientes GraphQL veem dados em tempo real

### Vantagens desta Arquitetura
✅ **Responsabilidade única**: Cada class faz uma coisa  
✅ **Testável**: Ports facilitam mocking  
✅ **Type-safe**: Scala + Doobie + Caliban  
✅ **Escalável**: Async/await com ZIO  
✅ **Resiliente**: Auto-reconexão MQTT, transactions BD  

---

## Troubleshooting

| Problema | Solução |
|----------|---------|
| Conexão BD falha | Verificar `DB_URL`, credenciais, postgres está up |
| Mensagens MQTT não chegam | Verificar `MQTT_BROKER_URL`, subscription a `spBv1.0/#` |
| GraphQL retorna erro | Verificar logs, validar queries, checar subscriptions |
| Memory leak | Verificar queue sizes, broadcast subscribers |
| Slow queries | Verificar índices, analisar queries com EXPLAIN |

---

## Referências Rápidas

- **ZIO Docs**: https://zio.dev
- **Doobie**: https://tpolecat.github.io/doobie
- **Caliban**: https://ghostdogpr.github.io/caliban
- **Sparkplug B**: https://sparkplug.eclipse.org

