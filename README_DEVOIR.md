# 📚 Guide Complet - Devoir Benchmark REST

## 🎯 Vue d'Ensemble

Ce projet implémente un benchmark de performance comparant 3 approches REST en Java, conforme aux exigences du devoir du Pr. LACHGAR.

**Variantes implémentées** :
- ✅ **Variant A** : JAX-RS Jersey + JPA/Hibernate
- ✅ **Variant C** : Spring Boot @RestController + JPA/Hibernate  
- ✅ **Variant D** : Spring Boot Spring Data REST

---

## 📋 Documents Disponibles

### 1. `ANALYSE_PROJET.md`
Analyse technique complète du projet :
- Architecture détaillée
- Technologies utilisées
- Structure de chaque variante
- Points d'attention et recommandations

### 2. `CONFORMITE_DEVOIR.md`
Vérification de conformité avec les exigences du devoir :
- ✅ Checklist complète
- ⚠️ Points à vérifier/compléter
- Instructions pour collecter les données

### 3. `TABLEAUX_DEVOIR.md`
Templates prêts à remplir pour les tableaux T0-T7 :
- T0 : Configuration matérielle/logicielle
- T1 : Scénarios (déjà rempli)
- T2 : Résultats JMeter
- T3 : Ressources JVM
- T4 : Détails JOIN-filter
- T5 : Détails MIXED
- T6 : Incidents/Erreurs
- T7 : Synthèse & Conclusion

### 4. `GUIDE_EXECUTION.md`
Guide pratique pour exécuter les benchmarks :
- Commandes d'exécution
- Collecte des données
- Dépannage

---

## 🚀 Démarrage Rapide

### Étape 1 : Initialisation

```bash
# Rendre les scripts exécutables (Linux/Mac)
chmod +x setup.sh run-benchmark.sh

# Windows PowerShell
# Les scripts .sh nécessitent Git Bash ou WSL

# Exécuter le setup
./setup.sh
```

### Étape 2 : Exécuter les Benchmarks

```bash
# Tester toutes les variantes, tous les scénarios
./run-benchmark.sh a all  # Variant A
./run-benchmark.sh c all  # Variant C
./run-benchmark.sh d all  # Variant D
```

### Étape 3 : Consulter les Résultats

- **Rapports JMeter** : `jmeter/results/*/index.html`
- **Grafana** : http://localhost:3000 (admin/admin)
- **Prometheus** : http://localhost:9090

### Étape 4 : Remplir les Tableaux

Ouvrir `TABLEAUX_DEVOIR.md` et remplir avec vos résultats.

---

## ✅ Conformité aux Exigences

### Modèle de Données
- ✅ Tables Category et Item conformes
- ✅ Index créés
- ✅ Relations JPA (@ManyToOne LAZY, @OneToMany)
- ✅ 2000 catégories, 100 000 items

### Endpoints
- ✅ Tous les endpoints demandés implémentés
- ✅ Pagination identique
- ✅ Validation Bean Validation
- ✅ Support payloads 1KB et 5KB

### Scénarios JMeter
- ✅ 4 scénarios conformes (READ-heavy, JOIN-filter, MIXED, HEAVY-body)
- ✅ Distribution des requêtes correcte
- ✅ Paliers de charge conformes
- ✅ CSV Data Set Config configuré
- ✅ Backend Listener InfluxDB configuré

### Infrastructure
- ✅ Docker Compose avec tous les services
- ✅ Prometheus + JMX Exporter (Variant A)
- ✅ Spring Actuator + Micrometer (Variants C & D)
- ✅ Grafana avec dashboards
- ✅ InfluxDB v2 pour métriques JMeter

### Optimisations
- ✅ Mode optimized (JOIN FETCH) vs baseline
- ✅ Variable d'environnement QUERY_MODE
- ✅ Cache L2 Hibernate désactivé

---

## 📊 Workflow Recommandé pour le Devoir

### 1. Préparation (30 min)

```bash
# Setup
./setup.sh

# Vérifier que tout fonctionne
curl http://localhost:8081/categories?page=0&size=1
curl http://localhost:8082/categories?page=0&size=1
curl http://localhost:8083/categories?page=0&size=1
```

### 2. Exécution des Tests (2-3 heures)

**Pour chaque variante (A, C, D)** :

```bash
# Mode optimized (recommandé)
export QUERY_MODE=optimized

# Exécuter tous les scénarios
./run-benchmark.sh a all  # ~40 min par variante
./run-benchmark.sh c all
./run-benchmark.sh d all
```

**Temps estimé** :
- READ-heavy : ~30 min (3 paliers × 10 min)
- JOIN-filter : ~16 min (2 paliers × 8 min)
- MIXED : ~20 min (2 paliers × 10 min)
- HEAVY-body : ~16 min (2 paliers × 8 min)
- **Total par variante** : ~82 min

### 3. Collecte des Données (1-2 heures)

Pour chaque run :
1. Ouvrir les rapports JMeter HTML
2. Noter les métriques (RPS, p50, p95, p99, Err %)
3. Exporter les métriques Prometheus depuis Grafana
4. Analyser les endpoints individuels
5. Remplir les tableaux T2-T6

### 4. Analyse et Rédaction (2-3 heures)

1. Comparer les résultats entre variantes
2. Identifier les patterns et écarts
3. Remplir T7 (Synthèse & Conclusion)
4. Rédiger les recommandations d'usage

---

## 📝 Livrables du Devoir

### 1. Code des Variantes ✅
- ✅ Variant A (Jersey)
- ✅ Variant C (Spring MVC)
- ✅ Variant D (Spring Data REST)

### 2. Fichiers JMeter ✅
- ✅ 4 scénarios (.jmx)
- ✅ CSV de données de test
- ✅ Payloads JSON (1KB, 5KB)

### 3. Dashboards Grafana ⚠️
- ✅ Dashboard JVM pré-configuré
- ⚠️ Dashboard JMeter : À créer ou utiliser InfluxDB
- ⚠️ Exports CSV : À exporter depuis Grafana
- ⚠️ Captures d'écran : À faire après exécution

### 4. Tableaux T0-T7 ⚠️
- ✅ Templates créés dans `TABLEAUX_DEVOIR.md`
- ⚠️ À remplir avec vos résultats

### 5. Analyse et Recommandations ⚠️
- ⚠️ À rédiger dans T7 après analyse des résultats

---

## 🔍 Points d'Attention pour l'Analyse

### Comparaison des Variantes

**Variant A (Jersey)** :
- Avantages : Léger, contrôle total, pas d'overhead framework
- Inconvénients : Plus de code, gestion manuelle des transactions
- À observer : Performance brute, consommation mémoire

**Variant C (Spring MVC)** :
- Avantages : Productivité, gestion automatique, Spring Data JPA
- Inconvénients : Overhead framework, plus de dépendances
- À observer : Impact de l'abstraction Spring

**Variant D (Spring Data REST)** :
- Avantages : Développement minimal, API HAL standardisée
- Inconvénients : Moins de contrôle, format HAL plus lourd
- À observer : Coût de l'abstraction automatique

### Métriques Clés à Analyser

1. **Débit (RPS)** : Quelle variante traite le plus de requêtes/seconde ?
2. **Latence (p95)** : Quelle variante est la plus rapide ?
3. **Stabilité** : Quelle variante a le moins d'erreurs ?
4. **Ressources** : Quelle variante consomme le moins (CPU/RAM) ?
5. **Impact JOIN FETCH** : Différence entre optimized et baseline

### Observations Techniques

- **N+1 Queries** : Comparer optimized vs baseline
- **Format HAL** : Impact sur la taille des réponses (Variant D)
- **Transactions** : Gestion manuelle (A) vs automatique (C, D)
- **Pagination** : Comparer l'efficacité entre variantes

---

## 🛠️ Commandes Utiles

### Vérifier l'état des services

```bash
# Services Docker
docker ps

# Logs d'une variante
docker logs benchmark-variant-a

# Métriques Prometheus
curl http://localhost:9091/metrics  # Variant A
curl http://localhost:8082/actuator/prometheus  # Variant C
```

### Exporter les métriques

```bash
# Prometheus
curl http://localhost:9091/metrics > metrics-variant-a.txt

# Actuator
curl http://localhost:8082/actuator/prometheus > metrics-variant-c.txt
```

### Nettoyage

```bash
# Arrêter tous les services
docker-compose --profile variant-a down
docker-compose --profile variant-c down
docker-compose --profile variant-d down

# Arrêter l'infrastructure
cd docker
docker-compose down
```

---

## 📚 Ressources

- **Analyse technique** : `ANALYSE_PROJET.md`
- **Conformité** : `CONFORMITE_DEVOIR.md`
- **Tableaux** : `TABLEAUX_DEVOIR.md`
- **Guide d'exécution** : `GUIDE_EXECUTION.md`
- **Rapports JMeter** : `jmeter/results/`
- **Grafana** : http://localhost:3000
- **Prometheus** : http://localhost:9090

---

## ⚠️ Checklist Finale Avant Remise

- [ ] Tous les benchmarks exécutés (A, C, D)
- [ ] Tableaux T0-T7 remplis
- [ ] Rapports JMeter HTML générés
- [ ] Métriques Prometheus exportées
- [ ] Dashboards Grafana configurés
- [ ] Captures d'écran des dashboards
- [ ] Analyse et synthèse rédigées (T7)
- [ ] Recommandations d'usage formulées
- [ ] Code commenté et propre
- [ ] README à jour

---

## 🎓 Conseils pour la Rédaction

### Synthèse (T7)

1. **Soyez objectif** : Basez-vous sur les données mesurées
2. **Justifiez les écarts** : Expliquez pourquoi une variante est meilleure
3. **Contexte** : Mentionnez les conditions de test
4. **Recommandations** : Proposez des cas d'usage concrets

### Exemple de Justification

❌ **Mauvais** : "Variant A est meilleur"
✅ **Bon** : "Variant A offre 15% de RPS en plus que Variant C car il n'a pas l'overhead du framework Spring, mais nécessite 30% plus de code"

### Recommandations d'Usage

- **Lecture relationnelle** : Basé sur les résultats JOIN-filter
- **Forte écriture** : Basé sur les résultats MIXED
- **Exposition rapide** : Basé sur la facilité de développement

---

**Bon courage pour votre devoir ! 🚀**

*N'hésitez pas à consulter les autres documents pour plus de détails.*

