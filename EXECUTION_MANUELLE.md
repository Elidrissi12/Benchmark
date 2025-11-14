# 🚀 Exécution Manuelle des Benchmarks (Sans Script)

## Méthode Manuelle - Étape par Étape

### Étape 1 : Démarrer la Variante

```powershell
# Aller dans le dossier docker
cd docker

# Démarrer la variante A (Jersey)
docker compose --profile variant-a up -d

# Ou variante C
docker compose --profile variant-c up -d

# Ou variante D
docker compose --profile variant-d up -d

# Revenir au dossier principal
cd ..
```

### Étape 2 : Attendre le Démarrage

```powershell
# Attendre 30-60 secondes que l'application démarre
Start-Sleep -Seconds 60
```

### Étape 3 : Vérifier que l'Application Fonctionne

Ouvre ton navigateur et teste :
- Variant A : http://localhost:8081/categories?page=0&size=1
- Variant C : http://localhost:8082/categories?page=0&size=1
- Variant D : http://localhost:8083/categories?page=0&size=1

Ou dans PowerShell :
```powershell
# Variant A
curl http://localhost:8081/categories?page=0&size=1

# Variant C
curl http://localhost:8082/categories?page=0&size=1

# Variant D
curl http://localhost:8083/categories?page=0&size=1
```

### Étape 4 : Exécuter les Scénarios JMeter

#### Scénario 1 : READ-heavy

```powershell
jmeter -n -t "jmeter\scenarios\1-read-heavy.jmx" -Jtarget.host=localhost -Jtarget.port=8081 -l "jmeter\results\1-read-heavy-variant-a.jtl" -e -o "jmeter\results\1-read-heavy-variant-a-report"
```

#### Scénario 2 : JOIN-filter

```powershell
jmeter -n -t "jmeter\scenarios\2-join-filter.jmx" -Jtarget.host=localhost -Jtarget.port=8081 -l "jmeter\results\2-join-filter-variant-a.jtl" -e -o "jmeter\results\2-join-filter-variant-a-report"
```

#### Scénario 3 : MIXED (écritures)

```powershell
jmeter -n -t "jmeter\scenarios\3-mixed-writes.jmx" -Jtarget.host=localhost -Jtarget.port=8081 -l "jmeter\results\3-mixed-writes-variant-a.jtl" -e -o "jmeter\results\3-mixed-writes-variant-a-report"
```

#### Scénario 4 : HEAVY-body

```powershell
jmeter -n -t "jmeter\scenarios\4-heavy-body.jmx" -Jtarget.host=localhost -Jtarget.port=8081 -l "jmeter\results\4-heavy-body-variant-a.jtl" -e -o "jmeter\results\4-heavy-body-variant-a-report"
```

### Étape 5 : Exporter les Métriques (Optionnel)

```powershell
# Variant A (JMX Exporter)
curl http://localhost:9091/metrics > jmeter\results\metrics-variant-a.txt

# Variants C & D (Actuator)
curl http://localhost:8082/actuator/prometheus > jmeter\results\metrics-variant-c.txt
curl http://localhost:8083/actuator/prometheus > jmeter\results\metrics-variant-d.txt
```

### Étape 6 : Arrêter la Variante

```powershell
cd docker
docker compose --profile variant-a down
cd ..
```

---

## 📋 Workflow Complet pour Variant A

```powershell
# 1. Démarrer
cd docker
docker compose --profile variant-a up -d
cd ..
Start-Sleep -Seconds 60

# 2. Scénario 1
jmeter -n -t "jmeter\scenarios\1-read-heavy.jmx" -Jtarget.host=localhost -Jtarget.port=8081 -l "jmeter\results\1-read-heavy-variant-a.jtl" -e -o "jmeter\results\1-read-heavy-variant-a-report"
Start-Sleep -Seconds 60

# 3. Scénario 2
jmeter -n -t "jmeter\scenarios\2-join-filter.jmx" -Jtarget.host=localhost -Jtarget.port=8081 -l "jmeter\results\2-join-filter-variant-a.jtl" -e -o "jmeter\results\2-join-filter-variant-a-report"
Start-Sleep -Seconds 60

# 4. Scénario 3
jmeter -n -t "jmeter\scenarios\3-mixed-writes.jmx" -Jtarget.host=localhost -Jtarget.port=8081 -l "jmeter\results\3-mixed-writes-variant-a.jtl" -e -o "jmeter\results\3-mixed-writes-variant-a-report"
Start-Sleep -Seconds 60

# 5. Scénario 4
jmeter -n -t "jmeter\scenarios\4-heavy-body.jmx" -Jtarget.host=localhost -Jtarget.port=8081 -l "jmeter\results\4-heavy-body-variant-a.jtl" -e -o "jmeter\results\4-heavy-body-variant-a-report"

# 6. Exporter métriques
curl http://localhost:9091/metrics > jmeter\results\metrics-variant-a.txt

# 7. Arrêter
cd docker
docker compose --profile variant-a down
cd ..
```

---

## 📋 Workflow pour Variant C (Spring MVC)

```powershell
# 1. Démarrer
cd docker
docker compose --profile variant-c up -d
cd ..
Start-Sleep -Seconds 60

# 2. Scénarios (même commandes, changer le port à 8082)
jmeter -n -t "jmeter\scenarios\1-read-heavy.jmx" -Jtarget.host=localhost -Jtarget.port=8082 -l "jmeter\results\1-read-heavy-variant-c.jtl" -e -o "jmeter\results\1-read-heavy-variant-c-report"
Start-Sleep -Seconds 60

jmeter -n -t "jmeter\scenarios\2-join-filter.jmx" -Jtarget.host=localhost -Jtarget.port=8082 -l "jmeter\results\2-join-filter-variant-c.jtl" -e -o "jmeter\results\2-join-filter-variant-c-report"
Start-Sleep -Seconds 60

jmeter -n -t "jmeter\scenarios\3-mixed-writes.jmx" -Jtarget.host=localhost -Jtarget.port=8082 -l "jmeter\results\3-mixed-writes-variant-c.jtl" -e -o "jmeter\results\3-mixed-writes-variant-c-report"
Start-Sleep -Seconds 60

jmeter -n -t "jmeter\scenarios\4-heavy-body.jmx" -Jtarget.host=localhost -Jtarget.port=8082 -l "jmeter\results\4-heavy-body-variant-c.jtl" -e -o "jmeter\results\4-heavy-body-variant-c-report"

# 3. Exporter métriques
curl http://localhost:8082/actuator/prometheus > jmeter\results\metrics-variant-c.txt

# 4. Arrêter
cd docker
docker compose --profile variant-c down
cd ..
```

---

## 📋 Workflow pour Variant D (Spring Data REST)

```powershell
# 1. Démarrer
cd docker
docker compose --profile variant-d up -d
cd ..
Start-Sleep -Seconds 60

# 2. Scénarios (même commandes, changer le port à 8083)
jmeter -n -t "jmeter\scenarios\1-read-heavy.jmx" -Jtarget.host=localhost -Jtarget.port=8083 -l "jmeter\results\1-read-heavy-variant-d.jtl" -e -o "jmeter\results\1-read-heavy-variant-d-report"
Start-Sleep -Seconds 60

jmeter -n -t "jmeter\scenarios\2-join-filter.jmx" -Jtarget.host=localhost -Jtarget.port=8083 -l "jmeter\results\2-join-filter-variant-d.jtl" -e -o "jmeter\results\2-join-filter-variant-d-report"
Start-Sleep -Seconds 60

jmeter -n -t "jmeter\scenarios\3-mixed-writes.jmx" -Jtarget.host=localhost -Jtarget.port=8083 -l "jmeter\results\3-mixed-writes-variant-d.jtl" -e -o "jmeter\results\3-mixed-writes-variant-d-report"
Start-Sleep -Seconds 60

jmeter -n -t "jmeter\scenarios\4-heavy-body.jmx" -Jtarget.host=localhost -Jtarget.port=8083 -l "jmeter\results\4-heavy-body-variant-d.jtl" -e -o "jmeter\results\4-heavy-body-variant-d-report"

# 3. Exporter métriques
curl http://localhost:8083/actuator/prometheus > jmeter\results\metrics-variant-d.txt

# 4. Arrêter
cd docker
docker compose --profile variant-d down
cd ..
```

---

## 📊 Consulter les Résultats

Après chaque scénario, les rapports sont générés dans :
- `jmeter\results\1-read-heavy-variant-a-report\index.html`
- `jmeter\results\2-join-filter-variant-a-report\index.html`
- etc.

Ouvre ces fichiers HTML dans ton navigateur pour voir les graphiques et statistiques.

---

## ⚠️ Notes Importantes

1. **Un seul variant à la fois** : Arrête un variant avant de démarrer un autre
2. **Temps d'attente** : Laisse 60 secondes entre chaque scénario pour laisser le système se stabiliser
3. **Ports** :
   - Variant A : 8081
   - Variant C : 8082
   - Variant D : 8083

---

## 🎯 Exemple Rapide : Un Seul Scénario

Si tu veux juste tester un scénario rapidement :

```powershell
# 1. Démarrer Variant A
cd docker
docker compose --profile variant-a up -d
cd ..
Start-Sleep -Seconds 60

# 2. Exécuter un seul scénario
jmeter -n -t "jmeter\scenarios\1-read-heavy.jmx" -Jtarget.host=localhost -Jtarget.port=8081 -l "jmeter\results\1-read-heavy-variant-a.jtl" -e -o "jmeter\results\1-read-heavy-variant-a-report"

# 3. Arrêter
cd docker
docker compose --profile variant-a down
cd ..
```

---

**C'est tout ! Tu peux copier-coller ces commandes directement dans PowerShell.** 🚀

