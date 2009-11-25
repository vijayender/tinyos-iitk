// @author K Vijayender Reddy

#ifndef Mts310Oscilloscope_H
#define Mts310Oscilloscope_H

#define NREADINGS_DEFAULT 10
#define INTERVAL_DEFAULT 256

#define AM_OSCILLOSCOPE_DATA 0x01

#define AM_OSCILLOSCOPE_CONTROL 0x02
#define ADDR_BASESTATION 10

typedef nx_struct control_msg {
  nx_uint16_t node_id;
  nx_uint16_t control_packet_no; /* Unique numbers sent by the GUI */
  nx_uint16_t control_device;
  /* As of 
   * settings for all devices
   *   interval
   *   quantity of data required
   *   one shot
   * Specifically for microphone
   *   gainAdjust
   *   muxSel
   *   readToneDetector
   * Specifically for magsensors
   *   gainAdjustX
   *   gainAdjustY
   */
  nx_uint16_t control_setting;
  nx_uint16_t setting_data;
  nx_uint32_t usPeriod;
  nx_uint16_t version;
} control_msg_t;

#define AM_OSCILLOSCOPE_CONTROL_CONFIRM 0x82

typedef nx_struct control_msg_confirm {
  nx_uint16_t node_id;
  nx_uint16_t control_packet_no;
}control_confirm_msg_t;

#define AM_ERROR_REPORT 0x03

typedef nx_struct error_msg {
  nx_uint16_t node_id;		/* TODO: use some kind of addressing mechanism rather than node_id */
  nx_uint16_t error_no;
  //  nx_uint16_t error_packet_no; Using Acks instead
} error_msg_t;

#define AM_ERROR_REPORT_CONFIRM 0x83


typedef nx_struct error_msg_confirm {
  nx_uint16_t node_id;
  nx_uint16_t error_packet_no;
} error_msg_confirm_t;


/* 1 => data packet
 * planning no confirmation signals as of now. ???
 * 2 => control packet
 * (0x8000 & 2) => confirmation for control packet
 * 3 => error packet
 * (0x8000 & 3) => confirmation for error packet
 */



/* Data format TODO:ReStructure
 * For a data packet
 * |data_bead|count_data1|interval_data1|length_data1|data1|...|
 *
 * For a control packet
 * |data_bead|control_message|
 *
 * For confirming the receipt of a control_message
 * message_id = 0x8000 & message_id is returned
 * DO YOU NEED CONFIRMATION ??
 * OFCOURSE YOU DO..
 *
 * For an error message
 * |data_bead|error_message_id|
 */

#endif
