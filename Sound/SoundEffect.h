

#import <Foundation/Foundation.h>
#import <OpenAL/al.h>

@class ALBuffer;
@class SoundEffect;


/** SoundEffect class -- encapsulates a single sound effect.
    Looping is supported, but specific attack and decay 
    components aren't (yet).

    TODO: Add positional audio support, and support for all file formats.

    NB: For now, only signed 16-bit integer little-endian 
        linear PCM format files are supported. 
        (Because that requires the least work to get working with OpenAL).

        Use the 'afconvert' tool in OSX to create such files:

        # afconvert -f 'caff' -d LEI16 myinfile.WHATEVER myoutfile.caf  */
@interface SoundEffect : NSObject {
    ALuint sourceId;
    ALBuffer *alBuffer;
    BOOL looping, oneshot;
}
@property (nonatomic,retain) ALBuffer *alBuffer;
@property BOOL looping; /// defautls to NO, if YES, a play command results in looping.. can set this at any time
@property BOOL oneshot; /// if this is set, this soundeffect deletes itself after the first play is done!  Used mainly with playOnceWithBuffer class method
@property (readonly) BOOL isPlaying;
@property (readonly) BOOL isPaused;
@property (readonly) BOOL isStopped;
@property (readonly) unsigned long secondsOffset;// if playing, the offset in seconds of the currently playin sample

/** Entire file is slurped into memory and put into OpenAL buffers, so
    this is really for sound effects and not background music, spech, etc.*/
- (id) initWithContentsOfFile:(NSString *)fileWithPath;
- (id) initWithBuffer:(ALBuffer *)albuf;

/// immediately creates and plays the soundeffect as a oneshot, nonlooping.
/// Note that the sound effect WILL senf itself a release after it is done playing
+ (SoundEffect *) playOnceWithBuffer:(ALBuffer *)buf;

- (void) play;
- (void) stop;
- (void) pause;

+ (void) makeContextCurrent; ///< call this only if you have mutliple AL contexts and want to switch to the static global 'SoundEffect class' OpenAL context.. you need to do this before you can use methods of this class, but only if you are switching OpenAL contexts 

@end
