#ifndef ERR_REPORT_H
#define ERR_REPORT_H

#define MAX_ERR_RETRY 10
#define ADDR_BASESTATION 10


#define ERR_QUEUE_FULL  0x01
#define ERR_QUEUE_EMPTY 0x02
#define ERR_RADIO       0x03
#define ERR_MSG_ERR     0x04
#define RADIO_SEND_FAIL 0x05

#define ER_UNKOWN_COMMAND 1
#define ER_RADIO_START    2
#define ER_READ_ONCE      3
#define ER_READ_ONCE_DONE 4
#define ER_POOL_EMPTY     5
#define ER_ALREADY_RUNNING 6
#define ER_QUEUE_FULL     7
#define ER_QUEUE_EMPTY    8
#define ER_RADIO_SEND     9
#define ER_RADIO_FAIL     10
#endif


