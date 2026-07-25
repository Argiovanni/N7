#include <SPI.h>
#include <mcp2515.h>

struct can_frame canMessageRead;
struct can_frame canMessageSend;
struct can_frame canMessageReadPrevious ;
MCP2515 mcp2515(10);

unsigned long previousTime;
unsigned long timerDelay;
canid_t id = 0x022;

void setup() {

  //0x021 -> id arduino uno 2
  canMessageSend.can_id  = id;
  canMessageSend.can_dlc = 8;
  canMessageSend.data[0] = 0x1A;
  canMessageSend.data[1] = 0x01;
  canMessageSend.data[2] = 0x22;
  canMessageSend.data[3] = 0x00;
  canMessageSend.data[4] = 0x3D;
  canMessageSend.data[5] = 0x04;
  canMessageSend.data[6] = 0xBE;
  canMessageSend.data[7] = 0x78;


  Serial.begin(250000);
  
  mcp2515.reset();
  mcp2515.setBitrate(CAN_250KBPS);
  mcp2515.setNormalMode();
  
  timerDelay = 5000; // Défini le timerDelay entre deux envois consécutifs de messages (en ms)
}

void readCan() {
  
  Serial.println("------- CAN Read ----------");
  Serial.println("ID  DLC   DATA");
  Serial.print(canMessageRead.can_id, HEX); // print ID
  Serial.print(" "); 
  Serial.print(canMessageRead.can_dlc, HEX); // print DLC
  Serial.print(" ");

  for (int i = 0; i<canMessageRead.can_dlc; i++)  {  // print the data
    Serial.print(canMessageRead.data[i],HEX);
    Serial.print(" ");
  }

  Serial.println();   
  Serial.println();   
  
}

void sendCan() {
  previousTime = millis(); // réinitilises le timerDelay
  mcp2515.sendMessage(&canMessageSend);
  Serial.println("+++----Messages sent----+++");
  Serial.println();
}

/*void checkMessages() {
  if (canMessageRead.data[0] != canMessageReadPrevious.data[0] + 1) {
    Serial.println("########### ERREUR MESSAGE MANQUANT ##############");
    Serial.println();
  }

  canMessageReadPrevious = canMessageRead;
}*/

void loop() {
  //if (mcp2515.readMessage(&canMessageRead) == MCP2515::ERROR_OK) {
    //checkMessages();
    //if (canMessageRead.data[0] == id) {
      //readCan(); // Read data from CAN
    //}
  //}

  if (millis() - previousTime > timerDelay) {
    sendCan();
  }

}
