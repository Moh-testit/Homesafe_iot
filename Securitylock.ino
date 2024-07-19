#include <Servo.h>
#include <SPI.h>
#include <RFID.h>
#include "WiFiEsp.h"
#include "WiFiEspUdp.h"
#include "SoftwareSerial.h"
#include "Keypad.h"
#include <WiFiEspServer.h>

Servo head;

#define SERVO_PIN 10
#define RED_LED 11
#define GREEN_LED 12
#define RFID_SDA 48
#define RFID_RST 49

unsigned char my_rfid[] = {12, 86, 4, 56, 102};
RFID rfid(RFID_SDA, RFID_RST);

WiFiEspServer server(80);
SoftwareSerial softserial(A9, A8);

char ssid[] = "iPhone de Adewale";
char pass[] = "123456789";
int status = WL_IDLE_STATUS;

unsigned long doorOpenTime = 0;
const unsigned long doorDelay = 10000;
int DoorStatus = LOW;

const byte ROWS = 4;
const byte COLS = 4;
char hexaKeys[ROWS][COLS] = {
  {'1', '2', '3', 'A'},
  {'4', '5', '6', 'B'},
  {'7', '8', '9', 'C'},
  {'*', '0', '#', 'D'}
};
byte rowPins[ROWS] = {33, 35, 37, 39};
byte colPins[COLS] = {41, 43, 45, 47};
Keypad customKeypad = Keypad(makeKeymap(hexaKeys), rowPins, colPins, ROWS, COLS);

String inputCode = "";

void setup() {
  pinMode(RED_LED, OUTPUT);
  pinMode(GREEN_LED, OUTPUT);
  pinMode(SERVO_PIN, OUTPUT);
  pinMode(LED_BUILTIN, OUTPUT);

  Serial.begin(9600);
  softserial.begin(115200);
  softserial.write("AT+CIOBAUD=9600\r\n");
  softserial.write("AT+RST\r\n");
  softserial.begin(9600);

  SPI.begin();
  rfid.init();

  Serial.println("Initialisation du WiFi...");
  WiFi.init(&softserial);

  if (WiFi.status() == WL_NO_SHIELD) {
    Serial.println("Le module WiFi n'est pas présent");
    while (true);
  }

  while (status != WL_CONNECTED) {
    Serial.print("Tentative de connexion au SSID WPA : ");
    Serial.println(ssid);
    status = WiFi.begin(ssid, pass);
    delay(10000);
  }

  Serial.println("Connecté au réseau");
  printWifiStatus();

  server.begin();
  Serial.println("Serveur démarré");

  close_door();
}

void loop() {
  WiFiEspClient client = server.available();
  if (client) {
    Serial.println("Nouveau client");
    String request = client.readStringUntil('\r');
    Serial.println(request);
    client.flush();

    if (request.indexOf("/status") != -1) {
      String status = DoorStatus == HIGH ? "open" : "closed";
      client.print("HTTP/1.1 200 OK\r\nContent-Type: application/json\r\n\r\n{\"status\":\"" + status + "\"}");
    }
    if (request.indexOf("/open") != -1) {
      open_door();
      client.print("HTTP/1.1 200 OK\r\nContent-Type: application/json\r\n\r\n{\"status\":\"open\"}");
    }
    if (request.indexOf("/close") != -1) {
      close_door();
      client.print("HTTP/1.1 200 OK\r\nContent-Type: application/json\r\n\r\n{\"status\":\"closed\"}");
    }
    delay(1);
    client.stop();
    Serial.println("Client déconnecté");
  }

  if (rfid.isCard()) {
    Serial.println("Carte détectée !");
    if (rfid.readCardSerial()) {
      Serial.print("ID de la carte : ");
      for (int i = 0; i < 5; i++) {
        Serial.print(rfid.serNum[i]);
        Serial.print(' ');
      }
      Serial.println();
      if (compare_rfid(rfid.serNum, my_rfid)) {
        Serial.println("Correspondance RFID");
        open_door();
      } else {
        Serial.println("Pas de correspondance RFID");
        close_door();
      }
    }
    rfid.selectTag(rfid.serNum);
  }
  rfid.halt();

  char customKey = customKeypad.getKey();
  if (customKey) {
    Serial.println(customKey);
    if (customKey == '#') {
      if (inputCode == "3269") {
        Serial.println("Code correct");
        open_door();
      } else {
        Serial.println("Code incorrect");
        close_door();
      }
      inputCode = ""; // Réinitialiser le code d'entrée
    } else if (customKey == '*') {
      inputCode = ""; // Réinitialiser le code d'entrée
      Serial.println("Code réinitialisé");
    } else {
      inputCode += customKey; // Ajouter la touche au code d'entrée
    }
  }

  // Vérifier les commandes série du script Python
  if (Serial.available() > 0) {
    char command = Serial.read();
    if (command == '1') {
      open_door();
    } else if (command == '0') {
      close_door();
    }
  }

  check_door_timer();
}

void printWifiStatus() {
  Serial.print("SSID : ");
  Serial.println(WiFi.SSID());
  Serial.print("Adresse IP : ");
  Serial.println(WiFi.localIP());
  Serial.print("Signal : ");
  Serial.println(WiFi.RSSI());
}

boolean compare_rfid(unsigned char x[], unsigned char y[]) {
  for (int i = 0; i < 5; i++) {
    if (x[i] != y[i]) return false;
  }
  return true;
}

void open_door() {
  head.attach(SERVO_PIN);
  delay(300);
  head.write(360);
  delay(400);
  head.detach();
  digitalWrite(GREEN_LED, HIGH);
  digitalWrite(RED_LED, LOW);
  doorOpenTime = millis();
  DoorStatus = HIGH;
}

void close_door() {
  head.attach(SERVO_PIN);
  delay(300);
  head.write(180);
  delay(400);
  head.detach();
  digitalWrite(GREEN_LED, LOW);
  digitalWrite(RED_LED, HIGH);
  DoorStatus = LOW;
}

void check_door_timer() {
  if (DoorStatus == HIGH && millis() - doorOpenTime >= doorDelay) {
    close_door();
  }
}
