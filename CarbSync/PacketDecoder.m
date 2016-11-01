//
//  PacketDecoder.m
//  CarbSync
//
//  Created by Dragnea Mihai on 10/31/16.
//  Copyright © 2016 Dragnea Mihai. All rights reserved.
//

#import "PacketDecoder.h"

const int BUFFER_SIZE = 20;

const Byte FOBEGIN = 0x21;       // '!' indicates beginning of the ingoing packet
const Byte FIBEGIN = 0x40;       // '@' indicates beginning of the outgoing packet
const Byte FIOEND = 0x0D;       // '\r' indicates ending of the ingoing/outgoing packet
const Byte FESC = 0x0A;       // '\n' Packet escape (FESC)
// Following bytes are used only in escape sequeces and may appear in the data without any problems
const Byte TFIBEGIN = 0x81;       // Transposed FIBEGIN
const Byte TFOBEGIN = 0x82;       // Transposed FOBEGIN
const Byte TFIOEND = 0x83;       // Transposed FIOEND
const Byte TFESC = 0x84;


@interface PacketDecoder ()

@end

@implementation PacketDecoder {
    Byte rx_buffer[BUFFER_SIZE];
    int rx_state;
    int rx_index;
    int rx_size;
}

- (id)init {
    if (self = [super init]) {
        rx_state = 0;
        _values = @[@0, @0, @0, @0];
    }
    return self;
}

- (Byte)popBufferByte {
    Byte value = rx_buffer[rx_index++];
    if (value == FESC) {
        Byte nextValue = rx_buffer[rx_index++];
        switch (nextValue) {
            case TFIBEGIN:
                return FIBEGIN;
            case TFIOEND:
                return FIOEND;
            case TFESC:
                return FESC;
            default:
                return 0;
        }
    } else {
        return value;
    }
}

- (int)popBufferInt {
    return ([self popBufferByte] << 8) + [self popBufferByte];
}

- (void)updateValues {
    rx_index = 0;
    [self popBufferByte]; // pop command byte
    _values = @[@([self popBufferInt]), @([self popBufferInt]), @([self popBufferInt]), @([self popBufferInt])];
    rx_size = 0;
}

- (void)addByte:(Byte)byte {
    if (rx_state == 0) {
        if (rx_size != 0) {
            return;
        }
        if (byte == FIBEGIN) {
            rx_state = 1;
            rx_index = 0;
        }
    } else {
        if (byte == FIOEND) {
            rx_state = 0;
            rx_size = rx_index;
            [self updateValues];
        } else if (rx_index >= BUFFER_SIZE) {
            rx_state = 0;
        } else {
            rx_buffer[rx_index++] = byte;
        }
    }
}

@end
