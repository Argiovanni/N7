// DecaDuinoSender
// This sketch shows how to use the DecaDuino library to send messages over the UWB radio
// by Adrien van den Bossche <vandenbo@univ-tlse2.fr>
// This sketch is a part of the DecaDuino Project - please refer to the DecaDuino LICENCE file for licensing details

#include <SPI.h>
#include <DecaDuino.h>

#define MAX_FRAME_LEN 120
uint8_t txData[MAX_FRAME_LEN];
uint8_t rxData[MAX_FRAME_LEN];
uint16_t txLen;
uint16_t rxLen;
int rxFrames;
uint8_t nb_retries = 5;
unsigned long timeout_delay = 500;
#ifdef ARDUINO_DWM1001_DEV
DecaDuino decaduino(SS1, DW_IRQ);
#define LED_ON LOW
#define LED_OFF HIGH
#else
DecaDuino decaduino;
#define LED_ON HIGH
#define LED_OFF LOW
#endif

void setup() {
  pinMode(LED_BUILTIN, OUTPUT);
  Serial.begin(115200);  // Init Serial port
#ifndef ARDUINO_DWM1001_DEV
  SPI.setSCK(14);  // Set SPI clock pin (pin 14 on DecaWiNo board)
#endif

  // Init DecaDuino and blink if initialisation fails
  if (!decaduino.init()) {
    Serial.println("decaduino init failed");
    while (1) {
      digitalWrite(LED_BUILTIN, LED_ON);
      delay(50);
      digitalWrite(LED_BUILTIN, LED_OFF);
      delay(50);
    }
  }

  // Set RX buffer and enable RX
  rxFrames = 0;
  decaduino.setRxBuffer(rxData, &rxLen);
  decaduino.plmeRxEnableRequest();
}


void loop() {
  decaduino.engine();

  // make dummy data, send it and wait the end of the transmission.
  Serial.println("Sending msg");
  digitalWrite(LED_BUILTIN, LED_ON);
  txData[0] = 'a';
  txData[1] = 's';
  for (int i = 2; i < MAX_FRAME_LEN; i++) {
    txData[i] = i;
  }
  decaduino.pdDataRequest(txData, MAX_FRAME_LEN);
  while (!decaduino.hasTxSucceeded()) { decaduino.engine(); };
  digitalWrite(LED_BUILTIN, LED_OFF);
  
  decaduino.plmeRxEnableRequest();
  Serial.println("waiting ack");
  uint8_t retry = 0;
  unsigned long start_time;
  bool ack_received = false;
  while ((!ack_received) && (retry < nb_retries)) {
    start_time = millis();
    while ((millis() - start_time) < timeout_delay){
      decaduino.engine();
      if (decaduino.rxFrameAvailable()) {
        if (rxData[0] == 's' && rxData[1] == 'a') {  // msg is ack
          Serial.print("#"); Serial.print(++rxFrames); Serial.print(" ");
          Serial.print(rxLen);
          Serial.print(" bytes received: |");
          for (int i = 0; i < rxLen; i++) {
            if (rxData[i] < 16) Serial.print("0");
            Serial.print(rxData[i], HEX);
            Serial.print("|");
          }
          Serial.println("\n ACK received");
          ack_received = true;
          break;
        }
      }
    }
    if (!ack_received) {
      Serial.println("ACK timeout");
      retry++;
      digitalWrite(LED_BUILTIN, LED_ON);
      decaduino.engine();
      decaduino.pdDataRequest(txData, MAX_FRAME_LEN);
      while (!decaduino.hasTxSucceeded()) { decaduino.engine(); };
      digitalWrite(LED_BUILTIN, LED_OFF);
      decaduino.plmeRxEnableRequest();
    }
  }

  if (!ack_received){Serial.println("Message droped");}

  // wait 1 second
  delay(1000);
}
