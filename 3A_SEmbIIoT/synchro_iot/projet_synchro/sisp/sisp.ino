// DecaDuinoReceiver
// This sketch shows how to use the DecaDuino library to receive messages over the UWB radio.
// The sketch prints the received bytes in HEX; it can be used as a frame sniffer.
// by Adrien van den Bossche <vandenbo@univ-tlse2.fr>
// This sketch is a part of the DecaDuino Project - please refer to the DecaDuino LICENCE file for licensing details

#include <SPI.h>
#include <DecaDuino.h>

#define MAX_FRAME_LEN 120
uint8_t txData[MAX_FRAME_LEN];
uint8_t rxData[MAX_FRAME_LEN];
uint16_t rxLen;
int rxFrames;

int p = 1000;
uint64_t shared_clock; // clock logique reçu/partagé
uint64_t local_clock; // clock logique interne

#ifdef ARDUINO_DWM1001_DEV
DecaDuino decaduino(SS1, DW_IRQ);
#define LED_ON LOW
#define LED_OFF HIGH
#else
DecaDuino decaduino;
#define LED_ON HIGH
#define LED_OFF LOW
#endif

void sendClock(){
  // make dummy data, send it and wait the end of the transmission.
  Serial.println("Sending msg sisp");
  digitalWrite(LED_BUILTIN, LED_ON);
  txData[0] = 'a';
  txData[1] = 's';
  txData[2] = 'S';
  decaduino.encodeUint64(shared_clock, &txData[3]);
  Serial.print("clock sent : "); Serial.println(shared_clock,HEX);
  decaduino.pdDataRequest(txData, MAX_FRAME_LEN);
  while (!decaduino.hasTxSucceeded()) { decaduino.engine(); };
  digitalWrite(LED_BUILTIN, LED_OFF);
}

void receiv_msg(){
  // Affichage du message reçu (si il commence par 'a''s')
    if (rxLen >= 2 && rxData[0] == 'a' && rxData[1] == 's') {
      Serial.print("#"); Serial.print(++rxFrames); Serial.print(" ");
      Serial.print(rxLen);
      Serial.print(" bytes received: |");
      for (int i = 0; i < rxLen; i++) {
        if (rxData[i] < 16) Serial.print("0");
        Serial.print(rxData[i], HEX);
        Serial.print("|");
      }
      Serial.println();
    
    // vérifie si msg "Sisp"
    if(rxData[2] == 'S'){
      shared_clock = (decaduino.decodeUint64(&rxData[3]) + shared_clock ) / 2;
      Serial.print("new clock is : "); Serial.print(shared_clock,HEX);
      Serial.println();
    }
  }
}

void setup() {
  pinMode(LED_BUILTIN, OUTPUT); // Internal LED (pin LED_BUILTIN on DecaWiNo board)
  Serial.begin(115200); // Init Serial port
  #ifndef ARDUINO_DWM1001_DEV
  SPI.setSCK(14); // Set SPI clock pin (pin 14 on DecaWiNo board)
  #endif

  // Init DecaDuino and blink if initialisation fails
  if ( !decaduino.init() ) {
    Serial.println("decaduino init failed");
    while(1) { digitalWrite(LED_BUILTIN, LED_ON); delay(50); digitalWrite(LED_BUILTIN, LED_OFF); delay(50); }
  }
  // Set RX buffer and enable RX
  decaduino.setRxBuffer(rxData, &rxLen);
  decaduino.plmeRxEnableRequest();
  rxFrames = 0;
  shared_clock = 0;
  local_clock = 0;

}

void loop() {
  local_clock += 1;
  shared_clock += 1;
  if((local_clock % p) != 0){
    if (decaduino.rxFrameAvailable() ) {
    digitalWrite(LED_BUILTIN, LED_ON);
    receiv_msg();
    digitalWrite(LED_BUILTIN, LED_OFF);
    }
  }else {
    Serial.print("Lclock is : ");Serial.println(local_clock,HEX);
    digitalWrite(LED_BUILTIN, LED_ON);
      sendClock();
      // Réactiver RX après TX
      decaduino.plmeRxEnableRequest();    
      digitalWrite(LED_BUILTIN, LED_OFF);
  }
  delay(1);
}




