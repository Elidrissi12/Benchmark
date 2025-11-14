# Vérification de Conformité - Devoir Benchmark REST

## ✅ Checklist de Conformité

### Modèle de Données
- [x] **Category** : id, code (VARCHAR 32, UNIQUE), name (VARCHAR 128), updated_at
- [x] **Item** : id, sku (VARCHAR 64, UNIQUE), name, price (NUMERIC 10,2), stock, category_id (FK), updated_at, description
- [x] **Index** : idx_item_category, idx_item_updated_at, idx_category_code
- [x] **Relations JPA** : @ManyToOne(fetch=LAZY) sur Item, @OneToMany sur Category
- [x] **Données** : 2000 catégories, 100 000 items (~50/catégorie)

### Variantes Implémentées
- [x] **Variant A** : JAX-RS Jersey + JPA/Hibernate
- [x] **Variant C** : Spring Boot @RestController + JPA/Hibernate
- [x] **Variant D** : Spring Boot Spring Data REST

### Endpoints (tous implémentés)
- [x] **Category** :
  - [x] GET /categories?page=&size=
  - [x] GET /categories/{id}
  - [x] POST /categories
  - [x] PUT /categories/{id}
  - [x] DELETE /categories/{id}
- [x] **Item** :
  - [x] GET /items?page=&size=
  - [x] GET /items/{id}
  - [x] GET /items?categoryId=&page=&size=
  - [x] POST /items
  - [x] PUT /items/{id}
  - [x] DELETE /items/{id}
- [x] **Relation** :
  - [x] GET /categories/{id}/items?page=&size=
  - [x] Spring Data REST expose aussi /items/{id}/category (automatique)

### Scénarios JMeter
- [x] **1. READ-heavy** : 50→100→200 threads, 60s ramp-up, 10 min/palier
  - [x] 50% GET /items?page=&size=50
  - [x] 20% GET /items?categoryId=...&page=&size=
  - [x] 20% GET /categories/{id}/items?page=&size=
  - [x] 10% GET /categories?page=&size=
- [x] **2. JOIN-filter** : 60→120 threads, 60s ramp-up, 8 min/palier
  - [x] 70% GET /items?categoryId=...&page=&size=
  - [x] 30% GET /items/{id}
- [x] **3. MIXED** : 50→100 threads, 60s ramp-up, 10 min/palier
  - [x] 40% GET /items
  - [x] 20% POST /items (1 KB)
  - [x] 10% PUT /items/{id} (1 KB)
  - [x] 10% DELETE /items/{id}
  - [x] 10% POST /categories (0.5-1 KB)
  - [x] 10% PUT /categories/{id}
- [x] **4. HEAVY-body** : 30→60 threads, 60s ramp-up, 8 min/palier
  - [x] 50% POST /items (5 KB)
  - [x] 50% PUT /items/{id} (5 KB)

### Configuration Technique
- [x] **Java 17** : ✅
- [x] **PostgreSQL 14+** : ✅ (14-alpine)
- [x] **HikariCP** : ✅ (maxPoolSize=20, minIdle=10)
- [x] **Prometheus + JMX Exporter** : ✅ (Variant A)
- [x] **Spring Actuator + Micrometer** : ✅ (Variants C & D)
- [x] **Grafana** : ✅ (dashboards JVM)
- [x] **InfluxDB v2** : ✅ (Backend Listener JMeter)
- [x] **Cache L2 Hibernate désactivé** : ✅
- [x] **Mode optimized/baseline** : ✅ (variable QUERY_MODE)

### Bonnes Pratiques JMeter
- [x] **CSV Data Set Config** : ✅ (categories.csv, items.csv)
- [x] **HTTP Request Defaults** : ✅
- [x] **Backend Listener InfluxDB** : ⚠️ À vérifier dans les .jmx
- [x] **Listeners lourds désactivés** : ⚠️ À vérifier

### Points d'Attention Techniques
- [x] **N+1 queries** : ✅ Mode JOIN FETCH vs baseline
- [x] **Pagination identique** : ✅ (page/size)
- [x] **Bean Validation** : ✅ (@Valid, @NotNull, etc.)
- [x] **Jackson** : ✅ (même version 2.15.3)
- [x] **Un seul service par run** : ✅ (profils Docker Compose)

---

## ⚠️ Points à Vérifier/Compléter

1. **Backend Listener InfluxDB** dans les fichiers .jmx
2. **Payloads de test** : Vérifier que payload-1kb.json et payload-5kb.json sont utilisés
3. **Dashboards Grafana** : Vérifier que les dashboards JVM et JMeter sont configurés
4. **Exports CSV** : Préparer les exports depuis Grafana/Prometheus
5. **Résultats** : Exécuter les benchmarks et remplir les tableaux T0-T7

---

## 📊 Instructions pour Remplir les Tableaux

### T0 - Configuration Matérielle & Logicielle

**À remplir après avoir exécuté les tests sur votre machine :**

```bash
# CPU et RAM
# Windows : wmic cpu get name,numberofcores,numberoflogicalprocessors
# Linux : lscpu, free -h

# Java version
java -version

# Docker versions
docker --version
docker-compose --version

# PostgreSQL version (dans le conteneur)
docker exec benchmark-postgres psql --version

# JMeter version
jmeter --version

# JVM flags (dans docker-compose.yml)
# JAVA_OPTS="-Xms512m -Xmx1g -XX:+UseG1GC -XX:MaxGCPauseMillis=200"

# HikariCP (dans application.yml ou application.properties)
# maxPoolSize=20, minIdle=10
```

### T2 - Résultats JMeter

**Source : Rapports HTML JMeter dans `jmeter/results/*/index.html`**

Pour chaque scénario et variante :
1. Ouvrir le rapport HTML généré
2. Section "Summary Report" :
   - **RPS** : Throughput (req/s)
   - **p50, p95, p99** : Median, 90th pct, 99th pct (ms)
   - **Err %** : Error % (KO Rate)

**Exemple de commande pour extraire :**
```bash
# Les rapports sont dans jmeter/results/
# Ouvrir index.html dans un navigateur
```

### T3 - Ressources JVM (Prometheus)

**Source : Grafana Dashboards ou Prometheus queries**

**CPU** :
```promql
rate(process_cpu_seconds_total[5m]) * 100
```

**Heap** :
```promql
jvm_memory_used_bytes{area="heap"} / 1024 / 1024
```

**GC Time** :
```promql
rate(jvm_gc_pause_seconds_sum[5m]) * 1000
```

**Threads** :
```promql
jvm_threads_live_threads
```

**HikariCP** :
```promql
hikaricp_connections_active
hikaricp_connections_max
```

### T4 & T5 - Détails par Endpoint

**Source : JMeter - Section "Custom Graphs" ou "Response Times Over Time"**

Pour chaque endpoint, filtrer les résultats par :
- Nom de la requête HTTP
- Extraire p95, RPS, Err % depuis le rapport

**Observations** :
- Vérifier les logs SQL (si activés) pour voir les requêtes générées
- Comparer avec/sans JOIN FETCH
- Noter les différences HAL pour Spring Data REST

### T6 - Incidents / Erreurs

**Source : JMeter - Section "Errors" dans le rapport**

Types d'erreurs possibles :
- HTTP 500 : Erreur serveur
- HTTP 503 : Service unavailable
- Timeout : Connection timeout
- Database : Erreurs de connexion DB

### T7 - Synthèse & Conclusion

**À remplir après analyse complète :**

Comparer les 3 variantes sur :
1. **Débit global** : Quelle variante a le meilleur RPS moyen ?
2. **Latence p95** : Quelle variante est la plus rapide ?
3. **Stabilité** : Quelle variante a le moins d'erreurs ?
4. **Empreinte** : Quelle variante consomme le moins de ressources ?
5. **Facilité** : Quelle variante est la plus simple à exposer ?

---

## 🔧 Commandes Utiles pour Collecter les Données

### Exporter les métriques Prometheus
```bash
# Variant A (JMX Exporter)
curl http://localhost:9091/metrics > metrics-variant-a.txt

# Variants C & D (Actuator)
curl http://localhost:8082/actuator/prometheus > metrics-variant-c.txt
curl http://localhost:8083/actuator/prometheus > metrics-variant-d.txt
```

### Vérifier les connexions HikariCP
```sql
-- Dans PostgreSQL
SELECT count(*) FROM pg_stat_activity WHERE datname = 'benchmark';
```

### Capturer les requêtes SQL (pour analyse N+1)
```yaml
# Dans application.yml (temporairement)
spring:
  jpa:
    show-sql: true
    properties:
      hibernate:
        format_sql: true
```

---

## 📝 Notes Importantes

1. **Mode Optimized vs Baseline** : 
   - Tester les deux modes pour chaque variante
   - Comparer l'impact sur les performances

2. **Warm-up** : 
   - Laisser l'application tourner 1-2 minutes avant de commencer les tests
   - Les premiers résultats peuvent être faussés

3. **Isolation** : 
   - Ne tester qu'une seule variante à la fois
   - Arrêter les autres services Docker

4. **Répétabilité** : 
   - Exécuter chaque scénario 2-3 fois
   - Prendre la moyenne des résultats

5. **Environnement** : 
   - Noter les conditions (CPU, RAM disponible, autres processus)
   - Ces facteurs peuvent influencer les résultats

---

*Document créé pour faciliter le remplissage des tableaux du devoir*

