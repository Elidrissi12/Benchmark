# Guide d'Exécution - Benchmark REST

## 🚀 Démarrage Rapide

### 1. Prérequis

Vérifier que vous avez installé :
- Java 17+
- Maven 3.6+
- Docker & Docker Compose
- JMeter 5.6+ (dans le PATH)

### 2. Initialisation

```bash
# Rendre les scripts exécutables (Linux/Mac)
chmod +x setup.sh run-benchmark.sh

# Exécuter le setup
./setup.sh
```

Le script `setup.sh` va :
- Vérifier les prérequis
- Compiler les applications
- Démarrer l'infrastructure (PostgreSQL, Prometheus, Grafana, InfluxDB)
- Initialiser la base de données

### 3. Exécution des Benchmarks

#### Exécuter tous les scénarios sur une variante

```bash
# Variant A (Jersey)
./run-benchmark.sh a all

# Variant C (Spring MVC)
./run-benchmark.sh c all

# Variant D (Spring Data REST)
./run-benchmark.sh d all
```

#### Exécuter un scénario spécifique

```bash
# Scénario READ-heavy sur Variant A
./run-benchmark.sh a 1-read-heavy

# Scénario JOIN-filter sur Variant C
./run-benchmark.sh c 2-join-filter

# Scénario MIXED sur Variant D
./run-benchmark.sh d 3-mixed-writes

# Scénario HEAVY-body sur Variant A
./run-benchmark.sh a 4-heavy-body
```

### 4. Consultation des Résultats

#### Rapports JMeter HTML

Les rapports sont générés automatiquement dans :
```
jmeter/results/[scenario]-[variant]-report/index.html
```

Ouvrir dans un navigateur pour voir :
- Summary Report (RPS, latence, erreurs)
- Response Times Over Time
- Throughput Over Time
- Custom Graphs

#### Métriques Prometheus

**Grafana** : http://localhost:3000
- Login : `admin` / `admin`
- Dashboards pré-configurés pour JVM

**Prometheus** : http://localhost:9090
- Requêtes PromQL pour métriques détaillées

#### Métriques Exportées

Les métriques sont exportées dans :
```
jmeter/results/metrics-[variant]-[timestamp].txt
```

---

## 📊 Collecte des Données pour les Tableaux

### T2 - Résultats JMeter

1. Ouvrir le rapport HTML : `jmeter/results/[scenario]-[variant]-report/index.html`
2. Section **"Summary Report"** :
   - **RPS** = Throughput (req/s)
   - **p50** = Median (ms)
   - **p95** = 90th pct (ms)
   - **p99** = 99th pct (ms)
   - **Err %** = Error % (KO Rate)

### T3 - Ressources JVM

#### Via Grafana

1. Se connecter à Grafana : http://localhost:3000
2. Ouvrir le dashboard JVM
3. Noter les valeurs moyennes et pics pour :
   - CPU (%)
   - Heap (MB)
   - GC Time (ms/s)
   - Threads actifs
   - HikariCP connections

#### Via Prometheus (PromQL)

**CPU** :
```promql
rate(process_cpu_seconds_total{job="variant-a-jersey"}[5m]) * 100
```

**Heap** :
```promql
jvm_memory_used_bytes{job="variant-a-jersey", area="heap"} / 1024 / 1024
```

**GC Time** :
```promql
rate(jvm_gc_pause_seconds_sum{job="variant-a-jersey"}[5m]) * 1000
```

**Threads** :
```promql
jvm_threads_live_threads{job="variant-a-jersey"}
```

**HikariCP** :
```promql
hikaricp_connections_active{job="variant-c-spring-mvc"}
hikaricp_connections_max{job="variant-c-spring-mvc"}
```

### T4 & T5 - Détails par Endpoint

Dans le rapport JMeter HTML :
1. Section **"Custom Graphs"** ou **"Response Times Over Time"**
2. Filtrer par nom de requête HTTP
3. Extraire les métriques pour chaque endpoint

**Pour les observations (JOIN, N+1)** :
- Activer temporairement `show-sql: true` dans `application.yml`
- Observer les logs SQL générés
- Compter le nombre de requêtes pour détecter N+1

### T6 - Incidents / Erreurs

Dans le rapport JMeter HTML :
1. Section **"Errors"**
2. Noter le type d'erreur (HTTP 500, timeout, etc.)
3. Calculer le pourcentage d'erreurs

---

## 🔧 Configuration du Mode Optimized vs Baseline

### Variant A (Jersey)

```bash
# Mode optimized (JOIN FETCH)
docker-compose --profile variant-a up -e QUERY_MODE=optimized

# Mode baseline (sans JOIN FETCH)
docker-compose --profile variant-a up -e QUERY_MODE=baseline
```

### Variants C & D (Spring)

Modifier `application.yml` :
```yaml
app:
  query:
    mode: optimized  # ou baseline
```

Ou via variable d'environnement :
```bash
QUERY_MODE=baseline docker-compose --profile variant-c up
```

---

## 📝 Workflow Recommandé

### 1. Préparation

```bash
# Setup initial
./setup.sh

# Vérifier que tout fonctionne
curl http://localhost:8081/categories?page=0&size=1
curl http://localhost:8082/categories?page=0&size=1
curl http://localhost:8083/categories?page=0&size=1
```

### 2. Exécution des Tests

**Pour chaque variante (A, C, D)** :

```bash
# 1. Mode optimized
export QUERY_MODE=optimized
./run-benchmark.sh a all

# 2. Mode baseline (optionnel, pour comparaison)
export QUERY_MODE=baseline
./run-benchmark.sh a all
```

**Ordre recommandé** :
1. Variant A - tous les scénarios
2. Variant C - tous les scénarios
3. Variant D - tous les scénarios

### 3. Collecte des Données

Pour chaque run :
1. ✅ Noter les résultats JMeter (T2)
2. ✅ Exporter les métriques Prometheus (T3)
3. ✅ Analyser les endpoints individuels (T4, T5)
4. ✅ Noter les incidents (T6)

### 4. Analyse et Synthèse

1. Comparer les résultats entre variantes
2. Identifier les patterns (ex. Variant A meilleur pour X, Variant D meilleur pour Y)
3. Remplir T7 avec vos conclusions

---

## ⚠️ Points d'Attention

### Isolation des Tests

**Important** : Ne tester qu'une seule variante à la fois !

```bash
# Arrêter les autres variantes avant de tester
docker-compose --profile variant-a down
docker-compose --profile variant-c down
docker-compose --profile variant-d down

# Puis démarrer celle à tester
docker-compose --profile variant-a up -d
```

### Warm-up

Laisser l'application tourner 1-2 minutes avant de commencer les tests JMeter pour :
- Charger les classes
- Initialiser les pools de connexions
- Optimiser le JIT compiler

### Répétabilité

Pour des résultats fiables :
- Exécuter chaque scénario 2-3 fois
- Prendre la moyenne des résultats
- Noter les conditions (CPU/RAM disponible, autres processus)

### Nettoyage

Après chaque run :
```bash
# Arrêter la variante testée
docker-compose --profile variant-a down

# Nettoyer les résultats si nécessaire
# (garder les rapports HTML importants)
```

---

## 🐛 Dépannage

### L'application ne démarre pas

```bash
# Vérifier les logs
docker logs benchmark-variant-a

# Vérifier que PostgreSQL est prêt
docker exec benchmark-postgres pg_isready -U benchmark
```

### JMeter ne trouve pas les fichiers CSV

Vérifier les chemins dans les fichiers .jmx :
- Les chemins sont relatifs au répertoire `jmeter/scenarios/`
- Format : `../test-data/categories.csv`

### Prometheus ne collecte pas les métriques

```bash
# Vérifier que Prometheus peut accéder aux services
curl http://localhost:9091/metrics  # Variant A
curl http://localhost:8082/actuator/prometheus  # Variant C
curl http://localhost:8083/actuator/prometheus  # Variant D

# Vérifier la configuration Prometheus
cat docker/prometheus.yml
```

### Erreurs de connexion à la base de données

```bash
# Vérifier que PostgreSQL est démarré
docker ps | grep postgres

# Vérifier les variables d'environnement
docker exec benchmark-variant-a env | grep DB_
```

---

## 📚 Ressources

- **Rapports JMeter** : `jmeter/results/`
- **Métriques Prometheus** : http://localhost:9090
- **Dashboards Grafana** : http://localhost:3000
- **Logs Docker** : `docker logs [container-name]`

---

*Guide créé pour faciliter l'exécution des benchmarks et la collecte des données*

