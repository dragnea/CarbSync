//
//  CSPacketDecoder.m
//  CarbSync
//
//  Created by Dragnea Mihai on 11/5/16.
//  Copyright © 2016 Dragnea Mihai. All rights reserved.
//

#import "CSPacketDecoder.h"

NSErrorDomain const CSPacketDecodedErrorDomain = @"CSPacketDecoderErrorDomain";
NSInteger const CSPacketDecoderErrorCode_bufferOverflow = -1;

const int BUFFER_SIZE = 20;

const Byte FOBEGIN = 0x21;       // '!' indicates beginning of the ingoing packet
const Byte FIBEGIN = 0x40;       // '@' indicates beginning of the outgoing packet
const Byte FIOEND = 0x0D;        // '\r' indicates ending of the ingoing/outgoing packet
const Byte FESC = 0x0A;          // '\n' Packet escape (FESC)
                                 // Following bytes are used only in escape sequeces and may appear in the data without any problems
const Byte TFIBEGIN = 0x81;      // Transposed FIBEGIN
const Byte TFOBEGIN = 0x82;      // Transposed FOBEGIN
const Byte TFIOEND = 0x83;       // Transposed FIOEND
const Byte TFESC = 0x84;

@implementation CSPacketDecoder {
    Byte rx_buffer[BUFFER_SIZE];
    int rx_state;
    int rx_index;
    int rx_size;
    NSMutableDictionary *registeredPackets;
}

- (void)registerPacketClass:(Class<CSPacketProtocol>)packet {
    [registeredPackets setObject:packet forKey:[NSNumber numberWithInteger:[packet command]]];
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
            [self processAvailableData];
        } else if (rx_index >= BUFFER_SIZE) {
            rx_state = 0;
            [self sendErrorCode:CSPacketDecoderErrorCode_bufferOverflow];
        } else {
            rx_buffer[rx_index++] = byte;
        }
    }
}

#pragma mark - private methods

- (id)init {
    if (self = [super init]) {
        registeredPackets = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)sendErrorCode:(NSInteger)errorCode {
    if ([self.delegate respondsToSelector:@selector(packetDecoder:error:)]) {
        NSError *error = [NSError errorWithDomain:CSPacketDecodedErrorDomain code:errorCode userInfo:nil];
        [self.delegate packetDecoder:self error:error];
    }
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

- (void)processAvailableData {
    rx_index = 0;
    NSMutableArray *data = [NSMutableArray array];
    CSPacketCommand command = [self popBufferByte];
    while (rx_index < rx_size) {
        [data addObject:[NSNumber numberWithInt:[self popBufferByte]]];
    }
    rx_size = 0;
    
    Class<CSPacketProtocol>packet = [registeredPackets objectForKey:[NSNumber numberWithInteger:command]];
    if ([self.delegate respondsToSelector:@selector(packetDecoder:packetUpdated:data:command:)]) {
        [self.delegate packetDecoder:self packetUpdated:packet data:data command:command];
    }
}

@end
