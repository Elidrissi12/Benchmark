# 📦 Installation des Prérequis - Windows

## ✅ Checklist des Prérequis

Avant de lancer les benchmarks, vérifie que tu as installé :

- [ ] **Java 17+**
- [ ] **Maven 3.6+**
- [ ] **Docker Desktop**
- [ ] **JMeter 5.6+**
- [ ] **Git Bash** (optionnel, pour les scripts .sh)

---

## 🔍 Vérification Rapide

Ouvre **PowerShell** et exécute ces commandes pour vérifier ce qui est déjà installé :

```powershell
# Vérifier Java
java -version

# Vérifier Maven
mvn -version

# Vérifier Docker
docker --version

# Vérifier Docker Compose
docker compose version

# Vérifier JMeter
jmeter --version
```

Si une commande retourne une erreur "command not found", il faut installer ce logiciel.

---

## 📥 Installation des Prérequis

### 1. Java 17+ (JDK)

**Option A : Oracle JDK**
- Télécharger : https://www.oracle.com/java/technologies/downloads/#java17
- Installer et ajouter au PATH

**Option B : OpenJDK (Recommandé - Gratuit)**
- Télécharger : https://adoptium.net/ (Eclipse Temurin)
- Choisir : **JDK 17 LTS** pour Windows x64
- Installer et ajouter au PATH

**Vérification** :
```powershell
java -version
# Doit afficher : openjdk version "17.x.x" ou java version "17.x.x"
```

---

### 2. Maven 3.6+

**Téléchargement** :
- Site officiel : https://maven.apache.org/download.cgi
- Télécharger : `apache-maven-3.9.x-bin.zip`

**Installation** :
1. Extraire dans `C:\Program Files\Apache\maven`
2. Ajouter au PATH Windows :
   - Panneau de configuration → Système → Variables d'environnement
   - Modifier "Path" → Ajouter : `C:\Program Files\Apache\maven\bin`
3. Créer une variable `JAVA_HOME` si elle n'existe pas :
   - Variable : `JAVA_HOME`
   - Valeur : `C:\Program Files\Java\jdk-17` (ou ton chemin Java)

**Vérification** :
```powershell
mvn -version
# Doit afficher : Apache Maven 3.9.x
```

---

### 3. Docker Desktop

**Téléchargement** :
- Site officiel : https://www.docker.com/products/docker-desktop/
- Télécharger : **Docker Desktop for Windows**

**Installation** :
1. Exécuter l'installateur
2. Redémarrer l'ordinateur si demandé
3. Démarrer Docker Desktop (icône dans la barre des tâches)
4. Attendre que Docker soit prêt (icône Docker stable)

**Vérification** :
```powershell
docker --version
docker compose version
# Doit afficher les versions installées
```

**Important** : Docker Desktop doit être **démarré** avant d'exécuter les benchmarks !

---

### 4. Apache JMeter 5.6+

**Téléchargement** :
- Site officiel : https://jmeter.apache.org/download_jmeter.cgi
- Télécharger : `apache-jmeter-5.6.x.tgz` ou `.zip`

**Installation** :
1. Extraire dans `C:\apache-jmeter-5.6` (ou autre emplacement)
2. Ajouter au PATH Windows :
   - Panneau de configuration → Système → Variables d'environnement
   - Modifier "Path" → Ajouter : `C:\apache-jmeter-5.6\bin`

**Vérification** :
```powershell
jmeter --version
# Doit afficher : Apache JMeter 5.6.x
```

**Alternative** : Si tu ne veux pas modifier le PATH, tu peux utiliser le chemin complet :
```powershell
C:\apache-jmeter-5.6\bin\jmeter.bat --version
```

---

### 5. Git Bash (Optionnel)

**Téléchargement** :
- Site officiel : https://git-scm.com/download/win
- Télécharger : **Git for Windows**

**Installation** :
- Suivre l'installateur (options par défaut OK)
- Git Bash sera disponible dans le menu contextuel (clic droit)

**Note** : Pas obligatoire si tu utilises les scripts PowerShell (`.ps1`)

---

## 🚀 Après l'Installation

### 1. Redémarrer PowerShell

Ferme et rouvre PowerShell pour que les changements de PATH soient pris en compte.

### 2. Vérifier Tous les Prérequis

```powershell
# Vérifier tout d'un coup
Write-Host "Java:" ; java -version
Write-Host "`nMaven:" ; mvn -version
Write-Host "`nDocker:" ; docker --version
Write-Host "`nDocker Compose:" ; docker compose version
Write-Host "`nJMeter:" ; jmeter --version
```

### 3. Démarrer Docker Desktop

**Important** : Docker Desktop doit être démarré avant de lancer les benchmarks !

1. Chercher "Docker Desktop" dans le menu Démarrer
2. Lancer l'application
3. Attendre que l'icône Docker dans la barre des tâches soit stable (pas animée)

### 4. Lancer le Setup

Une fois tout installé et Docker démarré :

```powershell
# Aller dans le dossier du projet
cd "C:\Users\ABDO EL IDRISSI\Desktop\Benchmark-REST"

# Exécuter le setup
.\setup.ps1
```

Le script va :
- ✅ Vérifier que tout est installé
- ✅ Compiler les applications
- ✅ Démarrer l'infrastructure (PostgreSQL, Prometheus, Grafana, InfluxDB)
- ✅ Initialiser la base de données

---

## 🐛 Problèmes Courants

### "java: command not found"

**Solution** :
1. Vérifier que Java est installé : `where java`
2. Si installé mais pas trouvé, ajouter au PATH manuellement
3. Redémarrer PowerShell

### "mvn: command not found"

**Solution** :
1. Vérifier que Maven est installé : `where mvn`
2. Vérifier que `JAVA_HOME` est défini
3. Ajouter Maven au PATH
4. Redémarrer PowerShell

### "docker: command not found"

**Solution** :
1. Vérifier que Docker Desktop est installé
2. **Démarrer Docker Desktop** (très important !)
3. Attendre que Docker soit prêt
4. Redémarrer PowerShell

### "jmeter: command not found"

**Solution** :
1. Vérifier que JMeter est installé : `where jmeter`
2. Ajouter JMeter au PATH
3. Ou utiliser le chemin complet : `C:\apache-jmeter-5.6\bin\jmeter.bat`

### Docker Desktop ne démarre pas

**Solutions** :
1. Vérifier que la virtualisation est activée dans le BIOS
2. Vérifier que WSL 2 est installé (requis pour Docker Desktop)
3. Redémarrer l'ordinateur
4. Réinstaller Docker Desktop si nécessaire

---

## ✅ Checklist Finale

Avant de lancer les benchmarks, vérifie :

- [ ] Java 17+ installé et dans le PATH
- [ ] Maven installé et dans le PATH
- [ ] Docker Desktop installé et **démarré**
- [ ] JMeter installé et dans le PATH (ou chemin connu)
- [ ] PowerShell redémarré après les installations
- [ ] Toutes les commandes de vérification fonctionnent

---

## 🎯 Une Fois Tout Installé

Tu peux maintenant lancer les benchmarks :

```powershell
# Setup (une seule fois)
.\setup.ps1

# Lancer les benchmarks
.\run-benchmark.ps1 a all  # Variant A
.\run-benchmark.ps1 c all  # Variant C
.\run-benchmark.ps1 d all  # Variant D
```

---

**Besoin d'aide ?** Si tu rencontres un problème d'installation, dis-moi quelle erreur tu obtiens et je t'aiderai à la résoudre ! 🚀

