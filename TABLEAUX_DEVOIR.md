# Tableaux à Remplir - Devoir Benchmark REST

## T0 — Configuration Matérielle & Logicielle

| Élément | Valeur |
|---------|--------|
| Machine (CPU, cœurs, RAM) | _À remplir : Ex. Intel i7-10700K, 8 cœurs, 16 GB RAM_ |
| OS / Kernel | _À remplir : Ex. Windows 10 / Linux 5.15_ |
| Java version | _À remplir : Ex. OpenJDK 17.0.8_ |
| Docker/Compose versions | _À remplir : Ex. Docker 24.0, Compose 2.20_ |
| PostgreSQL version | _À remplir : Ex. 14.9_ |
| JMeter version | _À remplir : Ex. 5.6.2_ |
| Prometheus / Grafana / InfluxDB | _À remplir : Ex. Prometheus 2.45, Grafana 10.0, InfluxDB 2.7_ |
| JVM flags (Xms/Xmx, GC) | _À remplir : Ex. -Xms512m -Xmx1g -XX:+UseG1GC_ |
| HikariCP (min/max/timeout) | _À remplir : Ex. minIdle=10, maxPoolSize=20, timeout=20000_ |

---

## T1 — Scénarios

| Scénario | Mix | Threads (paliers) | Rampup | Durée/palier | Payload |
|----------|-----|-------------------|--------|--------------|---------|
| READ-heavy (relation) | 50% items list, 20% items by category, 20% cat→items, 10% cat list | 50→100→200 | 60s | 10 min | – |
| JOIN-filter | 70% items?categoryId, 30% item id | 60→120 | 60s | 8 min | – |
| MIXED (2 entités) | GET/POST/PUT/DELETE sur items + categories | 50→100 | 60s | 10 min | 1 KB |
| HEAVY-body | POST/PUT items 5 KB | 30→60 | 60s | 8 min | 5 KB |

---

## T2 — Résultats JMeter (par scénario et variante)

### READ-heavy

| Mesure | A : Jersey | C : @RestController | D : Spring Data REST |
|--------|------------|---------------------|----------------------|
| RPS | _À remplir_ | _À remplir_ | _À remplir_ |
| p50 (ms) | _À remplir_ | _À remplir_ | _À remplir_ |
| p95 (ms) | _À remplir_ | _À remplir_ | _À remplir_ |
| p99 (ms) | _À remplir_ | _À remplir_ | _À remplir_ |
| Err % | _À remplir_ | _À remplir_ | _À remplir_ |

### JOIN-filter

| Mesure | A : Jersey | C : @RestController | D : Spring Data REST |
|--------|------------|---------------------|----------------------|
| RPS | _À remplir_ | _À remplir_ | _À remplir_ |
| p50 (ms) | _À remplir_ | _À remplir_ | _À remplir_ |
| p95 (ms) | _À remplir_ | _À remplir_ | _À remplir_ |
| p99 (ms) | _À remplir_ | _À remplir_ | _À remplir_ |
| Err % | _À remplir_ | _À remplir_ | _À remplir_ |

### MIXED (2 entités)

| Mesure | A : Jersey | C : @RestController | D : Spring Data REST |
|--------|------------|---------------------|----------------------|
| RPS | _À remplir_ | _À remplir_ | _À remplir_ |
| p50 (ms) | _À remplir_ | _À remplir_ | _À remplir_ |
| p95 (ms) | _À remplir_ | _À remplir_ | _À remplir_ |
| p99 (ms) | _À remplir_ | _À remplir_ | _À remplir_ |
| Err % | _À remplir_ | _À remplir_ | _À remplir_ |

### HEAVY-body

| Mesure | A : Jersey | C : @RestController | D : Spring Data REST |
|--------|------------|---------------------|----------------------|
| RPS | _À remplir_ | _À remplir_ | _À remplir_ |
| p50 (ms) | _À remplir_ | _À remplir_ | _À remplir_ |
| p95 (ms) | _À remplir_ | _À remplir_ | _À remplir_ |
| p99 (ms) | _À remplir_ | _À remplir_ | _À remplir_ |
| Err % | _À remplir_ | _À remplir_ | _À remplir_ |

---

## T3 — Ressources JVM (Prometheus)

| Variante | CPU proc. (%) moy/pic | Heap (Mo) moy/pic | GC time (ms/s) moy/pic | Threads actifs moy/pic | Hikari (actifs/max) |
|----------|----------------------|-------------------|------------------------|------------------------|---------------------|
| A : Jersey | _À remplir_ | _À remplir_ | _À remplir_ | _À remplir_ | _À remplir_ |
| C : @RestController | _À remplir_ | _À remplir_ | _À remplir_ | _À remplir_ | _À remplir_ |
| D : Spring Data REST | _À remplir_ | _À remplir_ | _À remplir_ | _À remplir_ | _À remplir_ |

---

## T4 — Détails par endpoint (scénario JOIN-filter)

| Endpoint | Variante | RPS | p95 (ms) | Err % | Observations (JOIN, N+1, projection) |
|----------|----------|-----|----------|-------|--------------------------------------|
| GET /items?categoryId= | A | _À remplir_ | _À remplir_ | _À remplir_ | _Ex. : JOIN FETCH utilisé, 1 requête SQL_ |
| GET /items?categoryId= | C | _À remplir_ | _À remplir_ | _À remplir_ | _Ex. : JOIN FETCH utilisé, 1 requête SQL_ |
| GET /items?categoryId= | D | _À remplir_ | _À remplir_ | _À remplir_ | _Ex. : HAL format, requêtes générées automatiquement_ |
| GET /categories/{id}/items | A | _À remplir_ | _À remplir_ | _À remplir_ | _Ex. : JOIN FETCH utilisé_ |
| GET /categories/{id}/items | C | _À remplir_ | _À remplir_ | _À remplir_ | _Ex. : JOIN FETCH utilisé_ |
| GET /categories/{id}/items | D | _À remplir_ | _À remplir_ | _À remplir_ | _Ex. : Endpoint auto-généré, HAL format_ |

---

## T5 — Détails par endpoint (scénario MIXED)

| Endpoint | Variante | RPS | p95 (ms) | Err % | Observations |
|----------|----------|-----|----------|-------|--------------|
| GET /items | A | _À remplir_ | _À remplir_ | _À remplir_ | _Ex. : Pagination efficace_ |
| GET /items | C | _À remplir_ | _À remplir_ | _À remplir_ | _Ex. : Spring Data JPA pagination_ |
| GET /items | D | _À remplir_ | _À remplir_ | _À remplir_ | _Ex. : HAL pagination automatique_ |
| POST /items | A | _À remplir_ | _À remplir_ | _À remplir_ | _Ex. : Validation Bean Validation_ |
| POST /items | C | _À remplir_ | _À remplir_ | _À remplir_ | _Ex. : Validation Spring_ |
| POST /items | D | _À remplir_ | _À remplir_ | _À remplir_ | _Ex. : Validation automatique_ |
| PUT /items/{id} | A | _À remplir_ | _À remplir_ | _À remplir_ | _Ex. : Transaction manuelle_ |
| PUT /items/{id} | C | _À remplir_ | _À remplir_ | _À remplir_ | _Ex. : Transaction Spring_ |
| PUT /items/{id} | D | _À remplir_ | _À remplir_ | _À remplir_ | _Ex. : Transaction automatique_ |
| DELETE /items/{id} | A | _À remplir_ | _À remplir_ | _À remplir_ | _Ex. : Suppression directe_ |
| DELETE /items/{id} | C | _À remplir_ | _À remplir_ | _À remplir_ | _Ex. : Suppression Spring Data_ |
| DELETE /items/{id} | D | _À remplir_ | _À remplir_ | _À remplir_ | _Ex. : Suppression automatique_ |
| GET /categories | A | _À remplir_ | _À remplir_ | _À remplir_ | _Ex. : Liste paginée_ |
| GET /categories | C | _À remplir_ | _À remplir_ | _À remplir_ | _Ex. : Liste paginée Spring_ |
| GET /categories | D | _À remplir_ | _À remplir_ | _À remplir_ | _Ex. : HAL collection_ |
| POST /categories | A | _À remplir_ | _À remplir_ | _À remplir_ | _Ex. : Création avec validation_ |
| POST /categories | C | _À remplir_ | _À remplir_ | _À remplir_ | _Ex. : Création Spring_ |
| POST /categories | D | _À remplir_ | _À remplir_ | _À remplir_ | _Ex. : Création HAL_ |

---

## T6 — Incidents / Erreurs

| Run | Variante | Type d'erreur (HTTP/DB/timeout) | % | Cause probable | Action corrective |
|-----|----------|--------------------------------|-----|----------------|-------------------|
| _Ex. : READ-heavy run 1_ | A | _Ex. : HTTP 500_ | _Ex. : 0.5%_ | _Ex. : Timeout DB_ | _Ex. : Augmenter pool size_ |
| _À remplir_ | _À remplir_ | _À remplir_ | _À remplir_ | _À remplir_ | _À remplir_ |
| _À remplir_ | _À remplir_ | _À remplir_ | _À remplir_ | _À remplir_ | _À remplir_ |

**Note** : Si aucun incident, indiquer "Aucun incident observé"

---

## T7 — Synthèse & Conclusion

| Critère | Meilleure variante | Écart (justifier) | Commentaires |
|---------|-------------------|-------------------|--------------|
| Débit global (RPS) | _À remplir : A / C / D_ | _Ex. : Variant A 15% plus rapide que C_ | _Ex. : Jersey plus léger, moins d'overhead framework_ |
| Latence p95 | _À remplir : A / C / D_ | _Ex. : Variant C 10% plus rapide que A_ | _Ex. : Spring optimise mieux les requêtes JPA_ |
| Stabilité (erreurs) | _À remplir : A / C / D_ | _Ex. : Variant D 0.1% vs 0.5% pour A_ | _Ex. : Spring Data REST gère mieux les erreurs_ |
| Empreinte CPU/RAM | _À remplir : A / C / D_ | _Ex. : Variant A consomme 30% moins de RAM_ | _Ex. : Pas de framework Spring, footprint réduit_ |
| Facilité d'expo relationnelle | _À remplir : A / C / D_ | _Ex. : Variant D 10x moins de code_ | _Ex. : Spring Data REST génère automatiquement les endpoints_ |

### Recommandations d'usage

**Pour lecture relationnelle (GET /categories/{id}/items)** :
- _À remplir : Recommandation basée sur vos résultats_
- _Ex. : Variant C avec mode optimized offre le meilleur compromis performance/maintenabilité_

**Pour forte écriture (POST/PUT fréquents)** :
- _À remplir : Recommandation basée sur vos résultats_
- _Ex. : Variant A offre les meilleures performances pour les écritures grâce au contrôle transactionnel manuel_

**Pour exposition rapide de CRUD** :
- _À remplir : Recommandation basée sur vos résultats_
- _Ex. : Variant D permet de créer une API REST complète en quelques minutes, idéal pour prototypage_

---

## 📝 Instructions de Remplissage

1. **Exécuter les benchmarks** avec `./run-benchmark.sh [variant] [scenario]`
2. **Consulter les rapports JMeter** dans `jmeter/results/*/index.html`
3. **Exporter les métriques Prometheus** depuis Grafana ou directement
4. **Analyser les logs** pour comprendre les requêtes SQL générées
5. **Comparer les résultats** entre les variantes
6. **Remplir les tableaux** avec les valeurs mesurées
7. **Rédiger la synthèse** (T7) avec vos conclusions

---

*Tableaux prêts à être remplis avec vos résultats de benchmark*

