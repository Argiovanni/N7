/* ********************************************
BE3 - ISAE F-IRT-305
******************************************** */

#include <stdio.h>
#include "ev3.h"
#include "ev3_port.h"
#include "ev3_tacho.h"
#include "coroutine.h"
#include "brick.h"
#include "main_robot.h"

#define MOTOR_A     OUTA
#define MOTOR_B     OUTB
#define MOTOR_C     OUTC
#define MOTOR_D     OUTD
#define ALL_MOTORS     ( MOTOR_A | MOTOR_B | MOTOR_C | MOTOR_D )
#define SENSOR1     IN1
#define SENSOR2     IN2
#define SENSOR3     IN3
#define SENSOR4     IN4

int Clockwise_A = 0;
int Counterclockwise_A = 0;
int Cmd_Position_A = 0;
int Cmd_Speed_A = 0;
int Value_A = 0;
int Clockwise_B = 0;
int Counterclockwise_B = 0;
int Cmd_Position_B = 0;
int Cmd_Speed_B = 0;
int Value_B = 0;
int Clockwise_C = 0;
int Counterclockwise_C = 0;
int Cmd_Position_C = 0;
int Cmd_Speed_C = 0;
int Value_C = 0;
int Clockwise_D = 0;
int Counterclockwise_D = 0;
int Cmd_Position_D = 0;
int Cmd_Speed_D = 0;
int Value_D = 0;

int alive;             /* Program is alive */

uint8_t sn_sensor1 = 0;
bool sensor1_is_present = false;
uint8_t sn_sensor2 = 0;
bool sensor2_is_present = false;
uint8_t sn_sensor3 = 0;
bool sensor3_is_present = false;
uint8_t sn_sensor4 = 0;
bool sensor4_is_present = false;

uint8_t sn_motor_a = 0;
uint8_t type_motor_a = TACHO_TYPE__NONE_;
int max_speed_motor_a = 0;
int max_position_motor_a = 0;
bool motor_a_is_present = false;
uint8_t sn_motor_b = 0;
uint8_t type_motor_b = TACHO_TYPE__NONE_;
int max_speed_motor_b = 0;
int max_position_motor_b = 0;
bool motor_b_is_present = false;
uint8_t sn_motor_c = 0;
uint8_t type_motor_c = TACHO_TYPE__NONE_;
int max_speed_motor_c = 0;
int max_position_motor_c = 0;
bool motor_c_is_present = false;
uint8_t sn_motor_d = 0;
uint8_t type_motor_d = TACHO_TYPE__NONE_;
int max_speed_motor_d = 0;
int max_position_motor_d = 0;
bool motor_d_is_present = false;

struct main_robot_ctx * robot_state;
void* cdata;

void main_robot_O_Clockwise_A(void* cdata, _boolean val) {
  Clockwise_A = val;
}
void main_robot_O_Counterclockwise_A(void* cdata, _boolean val) {
  Counterclockwise_A = val;
}
void main_robot_O_Cmd_Position_A(void* cdata, _boolean val) {
  Cmd_Position_A = val;
}
void main_robot_O_Cmd_Speed_A(void* cdata, _boolean val) {
  Cmd_Speed_A = val;
}
void main_robot_O_Value_A(void* cdata, _integer val) {
  Value_A = val;
}
void main_robot_O_Clockwise_B(void* cdata, _boolean val) {
  Clockwise_B = val;
}
void main_robot_O_Counterclockwise_B(void* cdata, _boolean val) {
  Counterclockwise_B = val;
}
void main_robot_O_Cmd_Position_B(void* cdata, _boolean val) {
  Cmd_Position_B = val;
}
void main_robot_O_Cmd_Speed_B(void* cdata, _boolean val) {
  Cmd_Speed_B = val;
}
void main_robot_O_Value_B(void* cdata, _integer val) {
  Value_B = val;
}
void main_robot_O_Clockwise_C(void* cdata, _boolean val) {
  Clockwise_C = val;
}
void main_robot_O_Counterclockwise_C(void* cdata, _boolean val) {
  Counterclockwise_C = val;
}
void main_robot_O_Cmd_Position_C(void* cdata, _boolean val) {
  Cmd_Position_C = val;
}
void main_robot_O_Cmd_Speed_C(void* cdata, _boolean val) {
  Cmd_Speed_C = val;
}
void main_robot_O_Value_C(void* cdata, _integer val) {
  Value_C = val;
}
void main_robot_O_Clockwise_D(void* cdata, _boolean val) {
  Clockwise_D = val;
}
void main_robot_O_Counterclockwise_D(void* cdata, _boolean val) {
  Counterclockwise_D = val;
}
void main_robot_O_Cmd_Position_D(void* cdata, _boolean val) {
  Cmd_Position_D = val;
}
void main_robot_O_Cmd_Speed_D(void* cdata, _boolean val) {
  Cmd_Speed_D = val;
}
void main_robot_O_Value_D(void* cdata, _integer val) {
  Value_D = val;
}

// *****************************************************************
int robot_sensor_search (int type, char* name) {
  int nb_sensor = 0;
	if ( sensor_is_plugged( SENSOR1, type )) {
	  nb_sensor++;
	  sensor1_is_present = true;
	  printf("%s sensor is present on IN1\n", name);
	}
	if ( sensor_is_plugged( SENSOR2, type )) {
	  nb_sensor++;
	  sensor2_is_present = true;
	  printf("%s sensor is present on IN2\n", name);
	}
	if ( sensor_is_plugged( SENSOR3, type )) {
	  nb_sensor++;
	  sensor3_is_present = true;
	  printf("%s sensor is present on IN3\n", name);
	}
	if ( sensor_is_plugged( SENSOR4, type )) {
	  nb_sensor++;
	  sensor4_is_present = true;
	  printf("%s sensor is present on IN4\n", name);
	}
	return(nb_sensor);
}
// *****************************************************************

// *****************************************************************
int robot_tacho_motor_search (int type, char* name) {
  int nb_motor = 0;
	if ( tacho_is_plugged( MOTOR_A, type )) {
		tacho_reset( MOTOR_A );
		motor_a_is_present = true;
		type_motor_a = type;
		printf("%s motor is present on OUTA\n", name);
		nb_motor++;
	}
	if ( tacho_is_plugged( MOTOR_B, type )) { 
		tacho_reset( MOTOR_B );
		motor_b_is_present = true;
		type_motor_b = type;
		printf("%s motor is present on OUTB\n", name);
		nb_motor++;
	}
	if ( tacho_is_plugged( MOTOR_C, type )) {  
		tacho_reset( MOTOR_C );
		motor_c_is_present = true;
		type_motor_c = type;
		printf("%s motor is present on OUTC\n", name);
		nb_motor++;
	}
	if ( tacho_is_plugged( MOTOR_D, type )) {  
		tacho_reset( MOTOR_D );
		motor_d_is_present = true;
		type_motor_d = type;
		printf("%s motor is present on OUTD\n", name);
		nb_motor++;
	}
	return(nb_motor);
}
// *****************************************************************

// *****************************************************************
int init( void )
{
  uint32_t i;
  int l_motor=0;
  int m_motor=0;
  int touch_sensor=0;
  int color_sensor=0;
  int us_sensor=0;
  
	l_motor = robot_tacho_motor_search(LEGO_EV3_L_MOTOR, "L-Motor");
        m_motor = robot_tacho_motor_search(LEGO_EV3_M_MOTOR, "M-Motor");
	if ( l_motor < 2 ) {
		printf( "Please, plug two L-MOTORS motors and try again.\n");
		/* Inoperative without two wheel motors */
		return ( 0 );
	}

	touch_sensor = robot_sensor_search(LEGO_EV3_TOUCH, "Touch");
	color_sensor = robot_sensor_search(LEGO_EV3_COLOR, "Color");
	us_sensor = robot_sensor_search(LEGO_EV3_US, "Ultrasonic");
	if (touch_sensor < 2) {
		printf( "Please, plug two touch sensors and try again.\n");
		/* Inoperative without two touch sensors */
		return ( 0 );
	}
	printf( "*** ( EV3 ) %d touch sensor found, %d color sensor found, %d ultrasonic found ***\n", touch_sensor, color_sensor, us_sensor );
	printf( "*** ( EV3 ) %d l-motor found, %d m-motor found ***\n", l_motor, m_motor );

	/* Search motor sequence numbers */
	for ( i = 0; i < DESC_LIMIT; i++ ) {
	  if ( ev3_tacho[ i ].type_inx != TACHO_TYPE__NONE_ ) {
	    if ( ev3_tacho_desc_port( i ) == OUTPUT_A ) {
	      sn_motor_a = i;
	      get_tacho_max_speed( sn_motor_a, &max_speed_motor_a );
	      if (type_motor_a == LEGO_EV3_M_MOTOR) {
		set_tacho_position( sn_motor_a, 0 );
		max_position_motor_a = 180;
	      }
	    }

	    if ( ev3_tacho_desc_port( i ) == OUTPUT_B ) {
	      sn_motor_b = i;
	      get_tacho_max_speed( sn_motor_b, &max_speed_motor_b );
	      if (type_motor_b == LEGO_EV3_M_MOTOR) {
		set_tacho_position( sn_motor_b, 0 );
		max_position_motor_b = 180;
	      }
	    }

	    if ( ev3_tacho_desc_port( i ) == OUTPUT_C ) {
	      sn_motor_c = i;
	      get_tacho_max_speed( sn_motor_c, &max_speed_motor_c );
	      if (type_motor_c == LEGO_EV3_M_MOTOR) {
		set_tacho_position( sn_motor_c, 0 );
		max_position_motor_c = 180;
	      }
	    }

	    if ( ev3_tacho_desc_port( i ) == OUTPUT_D ) {
	      sn_motor_d = i;
	      get_tacho_max_speed( sn_motor_d, &max_speed_motor_d );
	      if (type_motor_d == LEGO_EV3_M_MOTOR) {
		set_tacho_position( sn_motor_d, 0 );
		max_position_motor_d = 180;
	      }
	    }

	  }
	}

	/* Search sensor sequence numbers */
	for ( i = 0; i < DESC_LIMIT; i++ ) {
		  if ( ev3_sensor_desc_port( i ) == INPUT_1 ) {
		    sn_sensor1 = i;
		  }
		  if ( ev3_sensor_desc_port( i ) == INPUT_2 ) {
		    sn_sensor2 = i;
		  }
		  if ( ev3_sensor_desc_port( i ) == INPUT_3 ) {
		    sn_sensor3 = i;
		  }
		  if ( ev3_sensor_desc_port( i ) == INPUT_4 ) {
		    sn_sensor4 = i;
		  }
	}

	printf( "Press BACK on the EV3 brick for EXIT...\n" );

	return ( 1 );
}
// *****************************************************************

// *****************************************************************
// Coroutine of the EV3 brick keys handling
CORO_CONTEXT( handle_brick_control );

CORO_DEFINE( handle_brick_control )
{
	CORO_LOCAL uint8_t keys, pressed = EV3_KEY__NONE_;

	CORO_BEGIN();
	for ( ; ; ) {
		/* Waiting any brick's key is pressed or released */
		CORO_WAIT(( keys = brick_keys()) != pressed );
		pressed = keys;
		alive = 0;
		
		CORO_YIELD();
	}
	CORO_END();
}
// *****************************************************************


// *****************************************************************
int main( void )
{
  int val = 0;
  FLAGS_T state;

	printf( "Waiting the EV3 brick online...\n" );
	if ( !brick_init()) return ( 1 );

	printf( "*** ( EV3 ) Hello! ***\n" );
	alive = init();

	// Creation of the robot state
	robot_state = main_robot_new_ctx(cdata);

	while ( alive ) {
	  // Inputs: sensors
	  if (sensor1_is_present) {
	    get_sensor_value( 0, sn_sensor1, &val ) ;
	    main_robot_I_sensor_1(robot_state, val);
	  }
	  if (sensor2_is_present) {
	    get_sensor_value( 0, sn_sensor2, &val ) ;
	    main_robot_I_sensor_2(robot_state, val);
	  }
	  if (sensor3_is_present) {
	    get_sensor_value( 0, sn_sensor3, &val ) ;
	    main_robot_I_sensor_3(robot_state, val);
	  }
	  if (sensor4_is_present) {
	    get_sensor_value( 0, sn_sensor4, &val ) ;
	    main_robot_I_sensor_4(robot_state, val);
	  }

	  // Inputs: motor speed
	  if (motor_a_is_present) {
	    get_tacho_speed( sn_motor_a, &val ) ;
	    main_robot_I_motor_speed_sensor_a(robot_state, val);
	  }
	  if (motor_b_is_present) {
	    get_tacho_speed( sn_motor_b, &val ) ;
	    main_robot_I_motor_speed_sensor_b(robot_state, val);
	  }
	  if (motor_c_is_present) { 
	    get_tacho_speed( sn_motor_c, &val ) ;
	    main_robot_I_motor_speed_sensor_c(robot_state, val);
	  }
	  if (motor_d_is_present) {
	    get_tacho_speed( sn_motor_d, &val ) ;
	    main_robot_I_motor_speed_sensor_d(robot_state, val);
	  }
	  

	  // Lustre code
	  main_robot_step(robot_state);

	  // Motor A
	  if (motor_a_is_present) {
	    if (type_motor_a == LEGO_EV3_L_MOTOR && Cmd_Speed_A == 1) {
	      if (Value_A > max_speed_motor_a ) val = max_speed_motor_a; else val = Value_A;
	      if ( Clockwise_A == 1 ) {
		tacho_set_speed_sp( MOTOR_A, val );
		tacho_run_forever( MOTOR_A );
	      }
	      if ( Counterclockwise_A == 1 ) {
		tacho_set_speed_sp( MOTOR_A, -val );
		tacho_run_forever( MOTOR_A );
	      }
	      if ( Clockwise_A == 0 && Counterclockwise_A == 0 ) {
		tacho_stop( MOTOR_A );
	      }
	    }
	    if (type_motor_a == LEGO_EV3_M_MOTOR && Cmd_Position_A == 1) {
	      if (Value_A > max_position_motor_a ) val = max_position_motor_a; 
	      else if (Value_A < -max_position_motor_a ) val = -max_position_motor_a;
	      else val = Value_A;
	      set_tacho_speed_sp( sn_motor_a, 100 );
	      set_tacho_ramp_up_sp( sn_motor_a, 0 );
	      set_tacho_ramp_down_sp( sn_motor_a, 0 );
	      set_tacho_position_sp( sn_motor_a, val );
	      set_tacho_command_inx( sn_motor_a, TACHO_RUN_TO_ABS_POS );
	      do {
		get_tacho_state_flags( sn_motor_a, &state );
	      } while ( state );
	    }
	  }

	  // Motor B
	  if (motor_b_is_present) {
	    if (type_motor_b == LEGO_EV3_L_MOTOR && Cmd_Speed_B == 1) {
	      if (Value_B > max_speed_motor_b ) val = max_speed_motor_b; else val = Value_B;
	      if ( Clockwise_B == 1 ) {
		tacho_set_speed_sp( MOTOR_B, val );
		tacho_run_forever( MOTOR_B );
	      }
	      if ( Counterclockwise_B == 1 ) {
		tacho_set_speed_sp( MOTOR_B, -val );
		tacho_run_forever( MOTOR_B );
	      }
	      if ( Clockwise_B == 0 && Counterclockwise_B == 0 ) {
		tacho_stop( MOTOR_B );
	      }
	    }
	    if (type_motor_b == LEGO_EV3_M_MOTOR && Cmd_Position_B == 1) {
	      if (Value_B > max_position_motor_b ) val = max_position_motor_b; 
	      else if (Value_B < -max_position_motor_b ) val = -max_position_motor_b;
	      else val = Value_B;
	      set_tacho_speed_sp( sn_motor_b, 100 );
	      set_tacho_ramp_up_sp( sn_motor_b, 0 );
	      set_tacho_ramp_down_sp( sn_motor_b, 0 );
	      set_tacho_position_sp( sn_motor_b, val );
	      set_tacho_command_inx( sn_motor_b, TACHO_RUN_TO_ABS_POS );
	      do {
		get_tacho_state_flags( sn_motor_b, &state );
	      } while ( state );
	    }
	  }

	  // Motor C
	  if (motor_c_is_present) {
	    if (type_motor_c == LEGO_EV3_L_MOTOR && Cmd_Speed_C == 1) {
	      if (Value_C > max_speed_motor_c ) val = max_speed_motor_c; else val = Value_C;
	      if ( Clockwise_C == 1 ) {
		tacho_set_speed_sp( MOTOR_C, val );
		tacho_run_forever( MOTOR_C );
	      }
	      if ( Counterclockwise_C == 1 ) {
		tacho_set_speed_sp( MOTOR_C, -val );
		tacho_run_forever( MOTOR_C );
	      }
	      if ( Clockwise_C == 0 && Counterclockwise_C == 0 ) {
		tacho_stop( MOTOR_C );
	      }
	    }
	    if (type_motor_c == LEGO_EV3_M_MOTOR && Cmd_Position_C == 1) {
	      if (Value_C > max_position_motor_c ) val = max_position_motor_c; 
	      else if (Value_C < -max_position_motor_c ) val = -max_position_motor_c;
	      else val = Value_C;
	      set_tacho_speed_sp( sn_motor_c, 100 );
	      set_tacho_ramp_up_sp( sn_motor_c, 0 );
	      set_tacho_ramp_down_sp( sn_motor_c, 0 );
	      set_tacho_position_sp( sn_motor_c, val );
	      set_tacho_command_inx( sn_motor_c, TACHO_RUN_TO_ABS_POS );
	      do {
		get_tacho_state_flags( sn_motor_c, &state );
		} while ( state );
	    }
	  }
	    
	  // Motor D
	  if (motor_d_is_present) {
	    if (type_motor_d == LEGO_EV3_L_MOTOR && Cmd_Speed_D == 1) {
	      if (Value_D > max_speed_motor_d ) val = max_speed_motor_d; else val = Value_D;
	      if ( Clockwise_D == 1 ) {
		tacho_set_speed_sp( MOTOR_D, val );
		tacho_run_forever( MOTOR_D );
	      }
	      if ( Counterclockwise_D == 1 ) {
		tacho_set_speed_sp( MOTOR_D, -val );
		tacho_run_forever( MOTOR_D );
	      }
	      if ( Clockwise_D == 0 && Counterclockwise_D == 0 ) {
		tacho_stop( MOTOR_D );
	      }
	    }
	    if (type_motor_d == LEGO_EV3_M_MOTOR && Cmd_Position_D == 1) {
	      if (Value_D > max_position_motor_d ) val = max_position_motor_d; 
	      else if (Value_D < -max_position_motor_d ) val = -max_position_motor_d;
	      else val = Value_D;
	      set_tacho_speed_sp( sn_motor_d, 100 );
	      set_tacho_ramp_up_sp( sn_motor_d, 0 );
	      set_tacho_ramp_down_sp( sn_motor_d, 0 );
	      if ( Clockwise_D == 1 ) {
		set_tacho_position_sp( sn_motor_d, val );
	      }
	      if ( Counterclockwise_D == 1 ) {
		set_tacho_position_sp( sn_motor_d, -val );
	      }
	      set_tacho_command_inx( sn_motor_d, TACHO_RUN_TO_ABS_POS );
	      do {
		get_tacho_state_flags( sn_motor_d, &state );
	      } while ( state );
	    }
	  }

	  CORO_CALL( handle_brick_control );

	  sleep_ms( 10 );
	}

	tacho_stop( MOTOR_A );
	tacho_stop( MOTOR_B );
	tacho_stop( MOTOR_C );
	tacho_stop( MOTOR_D );

	brick_uninit();

	printf( "*** ( EV3 ) Bye! ***\n" );
	return ( 0 );
}
