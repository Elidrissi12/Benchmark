# Analyse du Projet Benchmark-REST

## 📋 Vue d'ensemble

Ce projet est un **benchmark de performance** comparant trois approches différentes d'implémentation d'APIs REST en Java :
- **Variant A** : JAX-RS (Jersey) + JPA/Hibernate
- **Variant C** : Spring Boot + @RestController + JPA/Hibernate
- **Variant D** : Spring Boot + Spring Data REST

**Auteurs** : Yahia Charif, Ikram Gafai

---

## 🏗️ Architecture du Projet

### Structure Maven Multi-Module

```
rest-performance-benchmark (parent POM)
├── variant-a-jersey          (Module Jersey)
├── variant-c-spring-mvc      (Module Spring MVC)
└── variant-d-spring-data-rest (Module Spring Data REST)
```

### Technologies Utilisées

| Composant | Technologies |
|-----------|-------------|
| **Java** | JDK 17 |
| **Build** | Maven 3.x |
| **Base de données** | PostgreSQL 14 |
| **ORM** | Hibernate 6.2.13 / JPA |
| **Connection Pool** | HikariCP 5.0.1 |
| **Sérialisation JSON** | Jackson 2.15.3 |
| **Conteneurisation** | Docker & Docker Compose |
| **Monitoring** | Prometheus, Grafana, InfluxDB |
| **Tests de charge** | Apache JMeter 5.6+ |
| **Frameworks REST** | Jersey 3.1.3, Spring Boot 3.1.5 |

---

## 📦 Modules Détaillés

### 1. Variant A - JAX-RS Jersey

**Caractéristiques** :
- Serveur HTTP : Grizzly 2
- Injection de dépendances : HK2
- Gestion manuelle des EntityManager (pas de contexte transactionnel automatique)
- Métriques : JMX Exporter (port 9090)
- Port : 8081

**Structure** :
```
variant-a-jersey/
├── src/main/java/com/benchmark/jersey/
│   ├── JerseyApplication.java          # Point d'entrée
│   ├── config/
│   │   └── EntityManagerProducer.java  # Factory pour EntityManager
│   ├── resource/
│   │   ├── CategoryResource.java       # Endpoints REST
│   │   └── ItemResource.java
│   ├── repository/
│   │   ├── CategoryRepository.java     # Accès données (manuel)
│   │   └── ItemRepository.java
│   ├── entity/
│   │   ├── Category.java
│   │   └── Item.java
│   └── dto/
│       └── PageResponse.java           # Pagination personnalisée
```

**Points clés** :
- Gestion manuelle des transactions (`EntityTransaction`)
- Création/fermeture explicite des `EntityManager` par requête
- Support du mode "optimized" avec `JOIN FETCH` pour éviter N+1 queries
- Pas de framework Spring, stack légère

### 2. Variant C - Spring Boot @RestController

**Caractéristiques** :
- Framework : Spring Boot 3.1.5
- Contrôleurs : `@RestController` avec Spring MVC
- Data Access : Spring Data JPA
- Métriques : Spring Actuator + Micrometer Prometheus
- Port : 8082

**Structure** :
```
variant-c-spring-mvc/
├── src/main/java/com/benchmark/springmvc/
│   ├── SpringMvcApplication.java       # Application Spring Boot
│   ├── controller/
│   │   ├── CategoryController.java     # Contrôleurs REST
│   │   └── ItemController.java
│   ├── repository/
│   │   ├── CategoryRepository.java     # Spring Data JPA
│   │   └── ItemRepository.java
│   └── entity/
│       ├── Category.java
│       └── Item.java
```

**Points clés** :
- Gestion automatique des transactions (`@Transactional` implicite)
- Repository Spring Data JPA avec méthodes dérivées
- Support de deux modes de requête :
  - **Baseline** : requêtes standard (risque N+1)
  - **Optimized** : requêtes avec `JOIN FETCH`
- Configuration via `application.yml`
- Actuator pour monitoring

### 3. Variant D - Spring Data REST

**Caractéristiques** :
- Framework : Spring Boot 3.1.5
- API REST : Génération automatique via Spring Data REST
- Pas de contrôleurs explicites
- Métriques : Spring Actuator + Micrometer Prometheus
- Port : 8083

**Structure** :
```
variant-d-spring-data-rest/
├── src/main/java/com/benchmark/springdatarest/
│   ├── SpringDataRestApplication.java
│   ├── repository/
│   │   ├── CategoryRepository.java     # Interface avec @RepositoryRestResource
│   │   └── ItemRepository.java
│   └── entity/
│       ├── Category.java
│       └── Item.java
```

**Points clés** :
- **Aucun code de contrôleur** : Spring Data REST génère automatiquement les endpoints
- Configuration via annotations `@RepositoryRestResource`
- API HAL (Hypermedia Application Language) par défaut
- Endpoints standards : `/categories`, `/items`, `/categories/{id}/items`
- Moins de contrôle sur le comportement, mais développement minimal

---

## 🗄️ Modèle de Données

### Schéma PostgreSQL

**Table `category`** :
- `id` (BIGSERIAL, PK)
- `code` (VARCHAR(32), UNIQUE)
- `name` (VARCHAR(128))
- `updated_at` (TIMESTAMP)

**Table `item`** :
- `id` (BIGSERIAL, PK)
- `sku` (VARCHAR(64), UNIQUE)
- `name` (VARCHAR(128))
- `price` (NUMERIC(10,2))
- `stock` (INT)
- `category_id` (BIGINT, FK → category.id)
- `updated_at` (TIMESTAMP)
- `description` (TEXT)

### Relations JPA

- `Category` → `Item` : OneToMany (bidirectionnel)
- `Item` → `Category` : ManyToOne

### Données de Test

- **2000 catégories** générées automatiquement
- **100 000 items** (~50 items par catégorie)
- Génération via script SQL PL/pgSQL dans `init.sql`

### Index

- `idx_item_category` sur `item(category_id)`
- `idx_item_updated_at` sur `item(updated_at)`
- `idx_category_code` sur `category(code)`

---

## 🧪 Scénarios de Test JMeter

### 1. Read Heavy (1-read-heavy.jmx)
**Distribution** :
- 50% : GET `/items?page=X&size=50` (liste paginée)
- 20% : GET `/items?categoryId=X&page=Y&size=Z` (filtrage)
- 20% : GET `/categories/{id}/items` (relation)
- 10% : GET `/categories?page=X&size=Y` (liste catégories)

**Configuration** :
- 3 paliers de charge : 50 → 100 → 150 threads
- Ramp-up : 60s par palier
- Durée : 600s (10 min) par palier

### 2. Join Filter (2-join-filter.jmx)
- Tests de requêtes avec jointures et filtres complexes

### 3. Mixed Writes (3-mixed-writes.jmx)
- Tests de création/modification/suppression (opérations d'écriture)

### 4. Heavy Body (4-heavy-body.jmx)
- Tests avec payloads volumineux (1KB, 5KB)

---

## 🐳 Infrastructure Docker

### Services Docker Compose

1. **PostgreSQL** (port 5432)
   - Image : `postgres:14-alpine`
   - Base : `benchmark`
   - Initialisation automatique via `init.sql`

2. **Prometheus** (port 9090)
   - Collecte de métriques JVM et application
   - Configuration : `prometheus.yml`

3. **Grafana** (port 3000)
   - Dashboards de visualisation
   - Datasources : Prometheus, InfluxDB
   - Provisioning automatique

4. **InfluxDB** (port 8086)
   - Stockage des métriques JMeter
   - Version 2.7

5. **Variantes d'application** (ports 8081, 8082, 8083)
   - Profils Docker Compose pour isoler chaque variante
   - Configuration JVM : G1GC, 512MB-1GB heap

### Configuration JVM

Toutes les variantes utilisent :
```bash
JAVA_OPTS="-Xms512m -Xmx1g -XX:+UseG1GC -XX:MaxGCPauseMillis=200"
```

---

## 📊 Monitoring et Métriques

### Prometheus

**Variant A (Jersey)** :
- Métriques via JMX Exporter (agent Java)
- Port : 9091 (exposé depuis le conteneur)

**Variants C & D (Spring)** :
- Métriques via Spring Actuator
- Endpoint : `/actuator/prometheus`
- Intégration Micrometer

### Métriques Collectées

- **JVM** : mémoire, GC, threads
- **HTTP** : requêtes, latence, erreurs
- **Base de données** : connexions, requêtes
- **Application** : métriques custom

### Grafana Dashboards

- Dashboard JVM pré-configuré (`jvm-dashboard.json`)
- Visualisation des métriques Prometheus
- Comparaison entre variantes

---

## 🔧 Scripts d'Automatisation

### `setup.sh`
- Vérifie les prérequis (Java, Maven, Docker, JMeter)
- Compile les applications (`mvn clean install`)
- Démarre l'infrastructure (PostgreSQL, Prometheus, Grafana, InfluxDB)
- Vérifie la santé des services
- Initialise la base de données

### `run-benchmark.sh`
- Démarre une variante spécifique (a, c, ou d)
- Exécute les scénarios JMeter
- Exporte les métriques Prometheus
- Génère des rapports HTML JMeter
- Nettoie les ressources après exécution

**Usage** :
```bash
./run-benchmark.sh a all          # Tous les scénarios sur Variant A
./run-benchmark.sh c 1-read-heavy # Un scénario sur Variant C
```

---

## 🎯 Optimisations Implémentées

### Mode "Optimized" vs "Baseline"

**Problème N+1 Queries** :
- Sans optimisation : 1 requête principale + N requêtes pour les relations
- Avec optimisation : 1 requête avec `JOIN FETCH`

**Exemple (Variant A)** :
```java
// Baseline
"SELECT i FROM Item i WHERE i.category.id = :categoryId"

// Optimized
"SELECT i FROM Item i JOIN FETCH i.category WHERE i.category.id = :categoryId"
```

**Configuration** :
- Variable d'environnement : `QUERY_MODE=optimized|baseline`
- Par défaut : `optimized`

---

## 📈 Points d'Analyse du Benchmark

### Métriques Clés

1. **Throughput** : Requêtes/seconde
2. **Latence** : Temps de réponse (p50, p95, p99)
3. **Erreurs** : Taux d'erreur HTTP
4. **Ressources** : CPU, mémoire, GC
5. **Base de données** : Temps de requête, connexions

### Comparaisons Attendues

| Aspect | Variant A (Jersey) | Variant C (Spring MVC) | Variant D (Spring Data REST) |
|--------|-------------------|------------------------|------------------------------|
| **Légèreté** | ✅ Plus léger | ⚠️ Framework complet | ⚠️ Framework complet |
| **Contrôle** | ✅ Contrôle total | ✅ Bon contrôle | ❌ Moins de contrôle |
| **Productivité** | ❌ Plus de code | ✅ Annotations | ✅✅ Minimal |
| **Performance** | À mesurer | À mesurer | À mesurer |
| **Flexibilité** | ✅✅ Maximale | ✅ Bonne | ❌ Limitée |

---

## 🔍 Points d'Attention Identifiés

### 1. Variant A (Jersey)
- ✅ Gestion manuelle des EntityManager (bon pour le contrôle)
- ⚠️ Risque de fuites de connexions si mal géré
- ✅ Pas de surcharge framework
- ⚠️ Plus de code boilerplate

### 2. Variant C (Spring MVC)
- ✅ Gestion automatique des transactions
- ✅ Spring Data JPA simplifie l'accès données
- ✅ Configuration centralisée
- ⚠️ Overhead du framework Spring

### 3. Variant D (Spring Data REST)
- ✅ Développement minimal (zéro code REST)
- ✅ API HAL standardisée
- ❌ Moins de contrôle sur les endpoints
- ❌ Personnalisation limitée
- ⚠️ Peut générer plus de requêtes que nécessaire

### 4. Base de Données
- ✅ Index bien définis
- ✅ Pool de connexions HikariCP configuré
- ⚠️ Pas de cache L2 Hibernate (désactivé intentionnellement)
- ✅ Données de test réalistes (100K items)

### 5. Tests de Charge
- ✅ Scénarios variés (read, write, heavy body)
- ✅ Distribution réaliste des requêtes
- ✅ Paliers de charge progressifs
- ⚠️ Pas de warm-up explicite dans les scripts

---

## 🚀 Utilisation

### 1. Initialisation
```bash
chmod +x setup.sh run-benchmark.sh
./setup.sh
```

### 2. Exécution d'un Benchmark
```bash
# Variant A, tous les scénarios
./run-benchmark.sh a all

# Variant C, scénario spécifique
./run-benchmark.sh c 1-read-heavy
```

### 3. Consultation des Résultats
- **Rapports JMeter** : `jmeter/results/*/index.html`
- **Grafana** : http://localhost:3000 (admin/admin)
- **Prometheus** : http://localhost:9090
- **Métriques exportées** : `jmeter/results/metrics-*.txt`

---

## 📝 Recommandations

### Pour l'Analyse des Résultats

1. **Comparer les métriques** :
   - Throughput moyen et pic
   - Latence p95 et p99
   - Utilisation mémoire et CPU
   - Temps de GC

2. **Analyser les différences** :
   - Impact du mode optimized vs baseline
   - Overhead des frameworks
   - Efficacité des requêtes SQL générées

3. **Considérer le contexte** :
   - Complexité du code
   - Maintenabilité
   - Temps de développement
   - Flexibilité future

### Améliorations Possibles

1. **Cache** : Ajouter Redis pour comparer avec/sans cache
2. **Connection Pool** : Tester différentes tailles de pool
3. **Batch Processing** : Optimiser les opérations en lot
4. **Compression** : Activer gzip pour les réponses
5. **Warm-up** : Ajouter une phase de warm-up avant les tests

---

## 📚 Conclusion

Ce projet est une **excellente base** pour comparer différentes approches REST en Java. Il couvre :
- ✅ Trois frameworks majeurs
- ✅ Infrastructure complète (DB, monitoring, tests)
- ✅ Scénarios de test réalistes
- ✅ Automatisation complète

Les résultats permettront de déterminer quel framework offre le meilleur compromis entre **performance**, **productivité** et **maintenabilité** selon les besoins spécifiques.

---

*Analyse générée le : $(date)*

