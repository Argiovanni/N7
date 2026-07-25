// DecaDuinoReceiver
// This sketch shows how to use the DecaDuino library to receive messages over the UWB radio.
// The sketch prints the received bytes in HEX; it can be used as a frame sniffer.
// by Adrien van den Bossche <vandenbo@univ-tlse2.fr>
// This sketch is a part of the DecaDuino Project - please refer to the DecaDuino LICENCE file for licensing details

#include <SPI.h>
#include <DecaDuino.h>

#define MAX_FRAME_LEN 120
uint8_t rxData[MAX_FRAME_LEN];
uint8_t txData[MAX_FRAME_LEN];
uint16_t rxLen;
uint64_t master_clock;
uint64_t last_rxTimeStamp;
uint64_t offset;
int rxFrames;
#ifdef ARDUINO_DWM1001_DEV
DecaDuino decaduino(SS1, DW_IRQ);
#define LED_ON LOW
#define LED_OFF HIGH
#else
DecaDuino decaduino;
#define LED_ON HIGH
#define LED_OFF LOW
#endif

uint64_t get_local_clock(){
  return decaduino.getSystemTimeCounter() + offset;
}

void setup()
{
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
}


void loop() {
  decaduino.engine();

  if (decaduino.rxFrameAvailable()) {
    digitalWrite(LED_BUILTIN, LED_ON);

    // Affichage du message reçu (si il commence par 'a''s')
    if (rxLen >= 2 && rxData[0] == 'a' && rxData[1] == 's' && rxData[2]=='c') {
      rx_clk = getLastRxTimestamp();
      if (rxLen > 3){
        shared_clk = rxData[3];
        offset = shared_clk - rx_clk;
      }
      
      Serial.print("#"); Serial.print(++rxFrames); Serial.print(" ");
      Serial.print(rxLen);
      Serial.print(" bytes received: |");
      for (int i = 0; i < rxLen; i++) {
        if (rxData[i] < 16) Serial.print("0");
        Serial.print(rxData[i], HEX);
        Serial.print("|");
      }
      Serial.println();
    // vérifie si msg "clap" et si pas le premier msg reçu
    if(rxData[2] == 'c' && rxFrames > 1){
      master_clock = decaduino.decodeUint64(&rxData[3]);
      Serial.print("Local clock was : ");
      Serial.print(get_local_clock(),HEX);
      Serial.println();
      offset = offset + (master_clock - last_rxTimeStamp);
      Serial.print("offset is : ");
      Serial.print(offset,HEX);
      Serial.println();
      Serial.print("new clock is : ");
      Serial.print(get_local_clock(),HEX);
      Serial.println();

    }
    last_rxTimeStamp = decaduino.getLastRxTimestamp();
  }
  // Réactiver RX après TX
  decaduino.plmeRxEnableRequest();    
  digitalWrite(LED_BUILTIN, LED_OFF);

    
  }
}



