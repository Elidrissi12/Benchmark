# 🪟 Guide d'Exécution des Benchmarks - Windows

## 📋 Prérequis

Avant de commencer, vérifiez que vous avez installé :

- ✅ **Java 17+** : `java -version`
- ✅ **Maven 3.6+** : `mvn -version`
- ✅ **Docker Desktop** : `docker --version`
- ✅ **Docker Compose** : `docker-compose --version`
- ✅ **JMeter 5.6+** : `jmeter --version`
- ✅ **Git Bash** (recommandé) ou **WSL** pour exécuter les scripts .sh

---

## 🚀 Option 1 : Avec Git Bash (Recommandé)

### Étape 1 : Ouvrir Git Bash

1. Clic droit dans le dossier du projet
2. Sélectionner **"Git Bash Here"**

### Étape 2 : Initialisation (Première fois uniquement)

```bash
# Rendre les scripts exécutables
chmod +x setup.sh run-benchmark.sh

# Exécuter le setup
./setup.sh
```

Le script va :
- ✅ Vérifier les prérequis
- ✅ Compiler les applications
- ✅ Démarrer l'infrastructure (PostgreSQL, Prometheus, Grafana, InfluxDB)
- ✅ Initialiser la base de données

**⏱️ Temps estimé : 5-10 minutes**

### Étape 3 : Vérifier que tout fonctionne

```bash
# Tester les endpoints
curl http://localhost:8081/categories?page=0&size=1
curl http://localhost:8082/categories?page=0&size=1
curl http://localhost:8083/categories?page=0&size=1
```

### Étape 4 : Exécuter les Benchmarks

#### Exécuter tous les scénarios sur une variante

```bash
# Variant A (Jersey) - Port 8081
./run-benchmark.sh a all

# Variant C (Spring MVC) - Port 8082
./run-benchmark.sh c all

# Variant D (Spring Data REST) - Port 8083
./run-benchmark.sh d all
```

#### Exécuter un scénario spécifique

```bash
# Scénario 1 : READ-heavy
./run-benchmark.sh a 1-read-heavy

# Scénario 2 : JOIN-filter
./run-benchmark.sh c 2-join-filter

# Scénario 3 : MIXED (écritures)
./run-benchmark.sh d 3-mixed-writes

# Scénario 4 : HEAVY-body (payloads 5KB)
./run-benchmark.sh a 4-heavy-body
```

**⏱️ Temps par variante (tous scénarios) : ~80-90 minutes**

---

## 🪟 Option 2 : Avec PowerShell (Alternative)

Si vous préférez PowerShell, voici les commandes équivalentes :

### Étape 1 : Initialisation

```powershell
# Aller dans le dossier du projet
cd "C:\Users\ABDO EL IDRISSI\Desktop\Benchmark-REST"

# Compiler les applications
mvn clean install -DskipTests

# Démarrer l'infrastructure
cd docker
docker-compose up -d postgres prometheus grafana influxdb
cd ..

# Attendre que les services démarrent (45 secondes)
Start-Sleep -Seconds 45

# Vérifier que PostgreSQL est prêt
docker exec benchmark-postgres pg_isready -U benchmark
```

### Étape 2 : Exécuter un Benchmark Manuellement

#### Pour Variant A (Jersey)

```powershell
# Démarrer la variante
cd docker
docker-compose --profile variant-a up -d
cd ..

# Attendre le démarrage (30 secondes)
Start-Sleep -Seconds 30

# Vérifier la santé
curl http://localhost:8081/categories?page=0&size=1

# Exécuter JMeter (exemple : scénario READ-heavy)
jmeter -n `
  -t "jmeter/scenarios/1-read-heavy.jmx" `
  -Jtarget.host=localhost `
  -Jtarget.port=8081 `
  -l "jmeter/results/1-read-heavy-variant-a.jtl" `
  -e -o "jmeter/results/1-read-heavy-variant-a-report"

# Arrêter la variante
cd docker
docker-compose --profile variant-a down
cd ..
```

#### Pour Variant C (Spring MVC)

```powershell
# Démarrer
cd docker
docker-compose --profile variant-c up -d
cd ..
Start-Sleep -Seconds 30

# Tester
curl http://localhost:8082/categories?page=0&size=1

# Exécuter JMeter
jmeter -n `
  -t "jmeter/scenarios/1-read-heavy.jmx" `
  -Jtarget.host=localhost `
  -Jtarget.port=8082 `
  -l "jmeter/results/1-read-heavy-variant-c.jtl" `
  -e -o "jmeter/results/1-read-heavy-variant-c-report"

# Arrêter
cd docker
docker-compose --profile variant-c down
cd ..
```

#### Pour Variant D (Spring Data REST)

```powershell
# Démarrer
cd docker
docker-compose --profile variant-d up -d
cd ..
Start-Sleep -Seconds 30

# Tester
curl http://localhost:8083/categories?page=0&size=1

# Exécuter JMeter
jmeter -n `
  -t "jmeter/scenarios/1-read-heavy.jmx" `
  -Jtarget.host=localhost `
  -Jtarget.port=8083 `
  -l "jmeter/results/1-read-heavy-variant-d.jtl" `
  -e -o "jmeter/results/1-read-heavy-variant-d-report"

# Arrêter
cd docker
docker-compose --profile variant-d down
cd ..
```

---

## 📊 Consulter les Résultats

### Rapports JMeter HTML

Les rapports sont générés dans :
```
jmeter/results/[scenario]-[variant]-report/index.html
```

**Exemple** :
- `jmeter/results/1-read-heavy-variant-a-report/index.html`
- `jmeter/results/1-read-heavy-variant-c-report/index.html`

**Ouvrir dans un navigateur** pour voir :
- ✅ Summary Report (RPS, latence, erreurs)
- ✅ Response Times Over Time
- ✅ Throughput Over Time
- ✅ Custom Graphs

### Grafana Dashboards

1. Ouvrir : http://localhost:3000
2. Login : `admin` / `admin`
3. Dashboards pré-configurés pour JVM

### Prometheus

1. Ouvrir : http://localhost:9090
2. Requêtes PromQL pour métriques détaillées

---

## 🔄 Workflow Complet Recommandé

### 1. Première Exécution (Setup)

```bash
# Dans Git Bash
./setup.sh
```

### 2. Exécuter les Benchmarks (Dans l'ordre)

```bash
# Variant A - Tous les scénarios (~80 min)
./run-benchmark.sh a all

# Variant C - Tous les scénarios (~80 min)
./run-benchmark.sh c all

# Variant D - Tous les scénarios (~80 min)
./run-benchmark.sh d all
```

**⏱️ Total : ~4 heures pour les 3 variantes**

### 3. Collecter les Données

Pour chaque run :
1. Ouvrir les rapports JMeter HTML
2. Noter les métriques (RPS, p50, p95, p99, Err %)
3. Remplir les tableaux dans `TABLEAUX_DEVOIR.md`

---

## ⚙️ Configuration du Mode Optimized vs Baseline

### Variant A (Jersey)

Modifier dans `docker/docker-compose.yml` ou via variable d'environnement :

```bash
# Mode optimized (JOIN FETCH) - Par défaut
QUERY_MODE=optimized ./run-benchmark.sh a all

# Mode baseline (sans JOIN FETCH)
QUERY_MODE=baseline ./run-benchmark.sh a all
```

### Variants C & D (Spring)

Modifier `application.yml` ou via variable d'environnement :

```bash
# Mode optimized
QUERY_MODE=optimized ./run-benchmark.sh c all

# Mode baseline
QUERY_MODE=baseline ./run-benchmark.sh c all
```

---

## 🐛 Dépannage

### Erreur : "jmeter: command not found"

**Solution** : Ajouter JMeter au PATH

1. Trouver le chemin d'installation JMeter (ex: `C:\apache-jmeter-5.6\bin`)
2. Ajouter au PATH Windows :
   - Panneau de configuration → Système → Variables d'environnement
   - Modifier "Path" → Ajouter le chemin vers `bin`

Ou utiliser le chemin complet :
```bash
"C:\apache-jmeter-5.6\bin\jmeter.bat" -n -t ...
```

### Erreur : "docker-compose: command not found"

**Solution** : Utiliser `docker compose` (sans tiret) sur les nouvelles versions

```bash
# Remplacer
docker-compose --profile variant-a up

# Par
docker compose --profile variant-a up
```

### L'application ne démarre pas

```bash
# Vérifier les logs
docker logs benchmark-variant-a

# Vérifier que PostgreSQL est prêt
docker exec benchmark-postgres pg_isready -U benchmark

# Vérifier les ports
netstat -ano | findstr :8081
netstat -ano | findstr :8082
netstat -ano | findstr :8083
```

### JMeter ne trouve pas les fichiers CSV

**Vérifier les chemins** dans les fichiers .jmx :
- Les chemins sont relatifs au répertoire `jmeter/scenarios/`
- Format : `../test-data/categories.csv`

Si problème, utiliser des chemins absolus ou modifier dans JMeter GUI.

### Port déjà utilisé

```powershell
# Trouver le processus utilisant le port
netstat -ano | findstr :8081

# Tuer le processus (remplacer PID)
taskkill /PID [PID] /F
```

---

## 📝 Commandes Utiles

### Vérifier l'état des services

```bash
# Services Docker
docker ps

# Logs d'une variante
docker logs benchmark-variant-a -f

# Arrêter tous les services
cd docker
docker-compose down
cd ..
```

### Exporter les métriques

```bash
# Variant A (JMX Exporter)
curl http://localhost:9091/metrics > metrics-variant-a.txt

# Variants C & D (Actuator)
curl http://localhost:8082/actuator/prometheus > metrics-variant-c.txt
curl http://localhost:8083/actuator/prometheus > metrics-variant-d.txt
```

### Nettoyage

```bash
# Arrêter toutes les variantes
cd docker
docker-compose --profile variant-a down
docker-compose --profile variant-c down
docker-compose --profile variant-d down
docker-compose down  # Infrastructure
cd ..

# Nettoyer les résultats (optionnel)
# rm -rf jmeter/results/*
```

---

## ⏱️ Temps Estimés

| Action | Temps |
|--------|-------|
| Setup initial | 5-10 min |
| Scénario READ-heavy | ~30 min (3 paliers) |
| Scénario JOIN-filter | ~16 min (2 paliers) |
| Scénario MIXED | ~20 min (2 paliers) |
| Scénario HEAVY-body | ~16 min (2 paliers) |
| **Total par variante** | **~80-90 min** |
| **Total pour 3 variantes** | **~4-5 heures** |

---

## 💡 Conseils

1. **Exécuter les tests la nuit** ou quand vous n'utilisez pas votre PC (tests longs)
2. **Ne pas fermer le terminal** pendant l'exécution
3. **Vérifier l'espace disque** (les rapports peuvent être volumineux)
4. **Fermer les applications lourdes** pour des résultats plus fiables
5. **Exécuter chaque variante séparément** (une à la fois)

---

## ✅ Checklist Avant de Commencer

- [ ] Java 17+ installé
- [ ] Maven installé
- [ ] Docker Desktop démarré
- [ ] JMeter installé et dans le PATH
- [ ] Git Bash installé (ou WSL)
- [ ] Au moins 10 GB d'espace disque libre
- [ ] Au moins 8 GB de RAM disponible

---

**Bon courage pour vos benchmarks ! 🚀**

*En cas de problème, consultez les logs Docker ou les messages d'erreur.*

