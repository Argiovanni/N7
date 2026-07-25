// DecaDuinoTWR_server
// A simple implementation of the TWR protocol, server side
// Contributors: Adrien van den Bossche, Réjane Dalcé, Ibrahim Fofana, Robert Try, Thierry Val
// This sketch is a part of the DecaDuino Project - please refer to the DecaDuino LICENCE file for licensing details

#include <SPI.h>
#include <DecaDuino.h>

// Timeout parameters
#define TIMEOUT_WAIT_ACK_SENT 5 //ms
#define TIMEOUT_SEND_RELY 5 //ms
#define ACK_DATA_REPLY_INTERFRAME 10 //ms
#define TRANSMITION_DELAY 1000000000000/15.65*0.1*5E-3 // 0.1ms

// TWR server states state machine enumeration: see state diagram on documentation for more details
enum { TWR_ENGINE_STATE_INIT, TWR_ENGINE_STATE_WAIT_START, TWR_ENGINE_STATE_MEMORISE_T2,
TWR_ENGINE_STATE_SEND_REPLY, TWR_ENGINE_STATE_REPLY_SEND};

// Message types of the TWR protocol
#define TWR_MSG_TYPE_UNKNOWN 0
#define TWR_MSG_TYPE_START 1
#define TWR_MSG_TYPE_ACK 2
#define TWR_MSG_TYPE_DATA_REPLY 3

#define delaiReponse 3000 //3ms


uint64_t t2, t3;
uint64_t t3_wanted;

#ifdef ARDUINO_DWM1001_DEV
DecaDuino decaduino(SS1, DW_IRQ);
#else
DecaDuino decaduino;
#endif

uint8_t txData[128];
uint8_t rxData[128];
uint16_t rxLen;
int state;
uint32_t timeout;


void setup()
{
  pinMode(13, OUTPUT); // Internal LED (pin 13 on DecaWiNo board)
  Serial.begin(115200); // Init Serial port
#ifndef ARDUINO_DWM1001_DEV
  SPI.setSCK(14); // Set SPI clock pin (pin 14 on DecaWiNo board)
#endif
  // Init DecaDuino and blink if initialisation fails
  if ( !decaduino.init() ) {
    Serial.println("decaduino init failed");
    while(1) { digitalWrite(13, HIGH); delay(50); digitalWrite(13, LOW); delay(50); }
  }

  // Set RX buffer
  decaduino.setRxBuffer(rxData, &rxLen);
  state = TWR_ENGINE_STATE_INIT;
}


void loop()
{
  decaduino.engine();

  switch (state) {
   
    case TWR_ENGINE_STATE_INIT:
      decaduino.plmeRxEnableRequest();
      state = TWR_ENGINE_STATE_WAIT_START;
      break;

    case TWR_ENGINE_STATE_WAIT_START:
      if ( decaduino.rxFrameAvailable() ) {
        if ( rxData[2] == TWR_MSG_TYPE_START && rxData[0]=='a' && rxData[1]=='s'  ) {
          state = TWR_ENGINE_STATE_MEMORISE_T2;
        } else {
					state = TWR_ENGINE_STATE_INIT;
				}
      }
      break;

    case TWR_ENGINE_STATE_MEMORISE_T2:
      t2 = decaduino.getLastRxTimestamp();
      Serial.println(t2);
      state = TWR_ENGINE_STATE_SEND_REPLY;
      break;

    case TWR_ENGINE_STATE_SEND_REPLY:
      txData[0]='a';
      txData[1]='s';
      txData[2] = TWR_MSG_TYPE_DATA_REPLY;


      //t3_wanted = t2 + delaiReponse;
      
      t3 = decaduino.alignDelayedTransmission(TRANSMITION_DELAY);
      Serial.println(t3);
      
      decaduino.encodeUint40(t2, &txData[3]); // octets 1..5
      decaduino.encodeUint40(t3, &txData[8]); // octets 6..10

      // retarder TX à time=t3
      decaduino.pdDataRequest(txData, 13, /*delayed=*/1, /*time=*/t3);

      //decaduino.pdDataRequest(txData, 1);
      timeout = millis() + TIMEOUT_SEND_RELY;

      state = TWR_ENGINE_STATE_REPLY_SEND;
      decaduino.plmeRxEnableRequest();
      
      break;
 		
    case TWR_ENGINE_STATE_REPLY_SEND:
      if ((millis()>timeout) || (decaduino.hasTxSucceeded())){
        state = TWR_ENGINE_STATE_INIT;
      }
      break;

    default:
      state = TWR_ENGINE_STATE_INIT;
      break;
  }
}


