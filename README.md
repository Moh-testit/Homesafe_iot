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
