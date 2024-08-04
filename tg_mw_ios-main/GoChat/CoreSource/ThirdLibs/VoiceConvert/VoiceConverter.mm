//
//  VoiceConverter.m

#import "VoiceConverter.h"
#import "wav.h"
#import "interf_dec.h"
#import "dec_if.h"
#import "interf_enc.h"
#import "amrFileCodec.h"

@implementation VoiceConverter

+ (bool)amrToWav:(NSString*)_amrPath wavSavePath:(NSString*)_savePath{
    
    if (!DecodeAMRFileToWAVEFile([_amrPath cStringUsingEncoding:NSASCIIStringEncoding], [_savePath cStringUsingEncoding:NSASCIIStringEncoding]))
    {
        return NO;
    }
    return YES;
}

+ (bool)wavToAmr:(NSString*)_wavPath amrSavePath:(NSString*)_savePath{
    
    if (!EncodeWAVEFileToAMRFile([_wavPath cStringUsingEncoding:NSASCIIStringEncoding], [_savePath cStringUsingEncoding:NSASCIIStringEncoding], 1, 16))
    {
        return NO;
    }
    return YES;
}

@end
