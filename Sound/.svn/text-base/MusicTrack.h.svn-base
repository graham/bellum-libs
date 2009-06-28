//
//  MusicTrack.h
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioQueue.h>
#import <AudioToolbox/AudioFile.h>

#define NUM_QUEUE_BUFFERS	3

@class MusicTrack;

@protocol MusicTrackListener
- (void) musicTrackFinishedPlaying:(MusicTrack *)musicTrack;
@end

@interface MusicTrack : NSObject
{
    AudioFileID  audioFile;
    AudioStreamBasicDescription dataFormat;
    AudioQueueRef queue;
    UInt64 packetIndex;
    UInt32 numPacketsToRead;
    AudioStreamPacketDescription *packetDescs;
    BOOL repeat;
    BOOL trackClosed;
    AudioQueueBufferRef buffers[NUM_QUEUE_BUFFERS];
    id listener;
}
@property (assign,nonatomic) id listener; ///< set this to receive notifications in main thread, listener should implement "musicTrackFinishedPlaying:(MusicTrack *)" method

- (id)initWithPath:(NSString *)path;
- (void)setGain:(Float32)gain;
- (void)setRepeat:(BOOL)yn;
- (void)play;
- (void)pause;

// close is called automatically in MusicTrack's dealloc method, but it is recommended
// to call close first, so that the associated Audio Queue is released immediately, instead
// of having to wait for a possible autorelease, which may cause some conflict
- (void)close;

@end
