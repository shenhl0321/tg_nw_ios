//
//  VoiceConverter.h

#import <Foundation/Foundation.h>

@interface VoiceConverter : NSObject

+ (bool)amrToWav:(NSString*)_amrPath wavSavePath:(NSString*)_savePath;

+ (bool)wavToAmr:(NSString*)_wavPath amrSavePath:(NSString*)_savePath;

@end
