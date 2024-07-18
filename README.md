# Homesafe_iot
Un système de sécurisation d'un domicile utilisant la reconnaissance faciale, une application mobile, un badge RFID et un code d'accès.

Manuel de Prise en Main de la Solution Arduino avec Reconnaissance Faciale, Badge RFID et Clavier Code
Ce manuel explique comment configurer et prendre en main la solution d'accès utilisant un Arduino, un module RFID, un clavier à code, et un système de reconnaissance faciale. Les étapes incluent la configuration matérielle, le code Arduino, et l'intégration avec ThingSpeak et l'application mobile pour le contrôle à distance.

# Matériel Nécessaire
Configuration Matérielle
Installation des Logiciels Requis
Code Arduino
Configuration de ThingSpeak
Configuration de l'Application Mobile
Mise en Place du Système de Reconnaissance Faciale
Démarrage et Test
# Matériel Nécessaire
Arduino Mega 2560
Module RFID RC522
Clavier à code (4x4 Keypad)
Servo moteur
Ordinateur avec une Webcam fonctionnelle
Câbles de connexion
Accès à Internet (elle doit être la même dans le code et sur tous les appareils utilisés)

# Configuration Matérielle
1. Connecter les pins du module RFID RC522 à des pins digitaux de l'Arduino 
2. Connecter les pins du clavier à des pins digitaux de l'Arduino 
3. Connexion du Servo Moteur
Signal à Pin 3
VCC à 5V
GND à GND

# Installation des Logiciels Requis
Arduino IDE:
Télécharger et installer l'Arduino IDE.
Bibliothèques Arduino:
Installer les bibliothèques nécessaires via le gestionnaire de bibliothèques de l'IDE Arduino:
MFRC522
ESP32
WifiESP
Servo
Keypad

# Configuration de ThingSpeak
1. Créer un Compte
2. Inscrivez-vous sur ThingSpeak.
3. Créer un Nouveau Canal: créez un canal pour recevoir les signaux de validation.
4. Notez le Numéro de Canal et l'API Key: vous aurez besoin de ces informations pour le code Arduino.

# Installation de Python et des bibliothèques nécessaires

pip install opencv-python dlib requests
Faites regresser votre biblithèque numpy à la version 1.9 au moins

# Démarrage
1. Ouvrez le code Arduino dans l'IDE Arduino et téléversez-le sur votre carte Arduino.
2. Exécutez le script Python pour commencer la reconnaissance faciale.
3. Testez les différents moyens d'accès (badge RFID, clavier à code, reconnaissance faciale).
4. Assurez-vous que ThingSpeak reçoit et envoie correctement les signaux.

# Scénarios de Fonctionnement
# Accès par Carte RFID:

Étape 1: L'utilisateur présente une carte RFID au lecteur.
Étape 2: Le module RFID lit l'UID de la carte.
Étape 3: L'Arduino compare l'UID lu avec une liste d'UID autorisés stockée dans le code.
Étape 4: Si l'UID est autorisé, l'Arduino actionne le servo moteur pour déverrouiller la porte.
Étape 5: Après un délai défini, l'Arduino actionne le servo moteur pour verrouiller à nouveau la porte.

# Accès par Code Keypad:

Étape 1: L'utilisateur entre un code sur le keypad.
Étape 2: L'Arduino lit le code entré.
Étape 3: L'Arduino compare le code entré avec un code autorisé stocké dans le code.
Étape 4: Si le code est correct, l'Arduino actionne le servo moteur pour déverrouiller la porte.
Étape 5: Après un délai défini, l'Arduino actionne le servo moteur pour verrouiller à nouveau la porte.

# Accès par reconnaissance faciale

Étape 1: La webcam capture en temps réel le flux vidéo du visage de l'utilisateur.
Étape 2: Le flux vidéo est transmis à l'application mobile via une connexion réseau.
Étape 3: Python utilise des bibliothèques de reconnaissance faciale (comme OpenCV et dlib) pour analyser le flux vidéo.
Le script identifie les visages présents dans le flux et compare les caractéristiques faciales avec une base de données d'images de visages autorisés.
Étape 4: Si le visage est reconnu et correspond à un utilisateur autorisé, le script Python envoie un signal de validation.
Étape 5: Le signal de validation est envoyé à ThingSpeak, une plateforme IoT, via une requête HTTP (API).
ThingSpeak enregistre le signal et le rend accessible pour l'Arduino.
Étape 6: L'Arduino, connecté à Internet, interroge régulièrement ThingSpeak pour vérifier la présence d'un signal de validation.
Lorsqu'un signal de validation est détecté, l'Arduino procède à l'ouverture de la porte.
Étape 7: L'Arduino envoie un signal PWM au servo moteur pour déverrouiller la porte.
Après un délai défini, l'Arduino envoie un autre signal pour verrouiller la porte.
