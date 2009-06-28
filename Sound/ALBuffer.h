/* @file ALBuffer (C) 20008 Calin A. Culianu
 */
#import <Foundation/Foundation.h>
#import <OpenAL/al.h>

/**ALBuffer class 

   Encapsulates an OpenAL buffer and knows how to initialize it from a file

    NB: For now, only signed 16-bit integer little-endian 
        linear PCM format files are supported. 
        (Because that requires the least work to get working with OpenAL).

        Use the 'afconvert' tool in OSX to create such files:

        # afconvert -f 'caff' -d LE16 myinfile.WHATEVER myoutfile.caf  */
@interface ALBuffer : NSObject {
    ALuint name; ///< openal name
    unsigned long dataSize;
    NSTimeInterval duration;
}
@property (readonly) ALuint name; ///< OpenAL name
@property (readonly) unsigned long dataSize; ///< in bytes
@property (readonly) NSTimeInterval duration; ///< in seconds

- (id) initWithContentsOfFile:(NSString *)fileWithPath;

@end
