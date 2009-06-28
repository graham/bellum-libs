#import "SoundEffect.h"
#import "ALCommon.h"
#import "ALBuffer.h"


@interface SoundEffect (PrivateMethods)
- (void) deleteSelf;
@end

@implementation SoundEffect
@synthesize alBuffer,looping,oneshot;

- (id) init {
    if ((self = [super init])) {
        if (!alCommonContextMakeCurrent()) {
            NSLog(@"SoundEffect init failed, no context!\n");
            [self release]; 
            return nil;
        }

        alGenSources(1, &sourceId);
        ALCHKERR("gen sources");
    }
    return self;
}

- (id) initWithContentsOfFile:(NSString *)file {

    if ((self = [self init])) {
        self.alBuffer = [[ALBuffer alloc] initWithContentsOfFile:file];
        if (!alBuffer) {
            NSLog(@"Error from ALBuffer constructor, returning nil from SoundEffect constructor!\n");
            [self release];
            return nil;
        }
    }
    return self;    
}

- (id) initWithBuffer:(ALBuffer *)buf {
    if ((self = [self init])) {
        self.alBuffer = buf;        
    }
    return self;
}

+ (SoundEffect *) playOnceWithBuffer:(ALBuffer *)buf {
    SoundEffect *s;
    if ((s = [[SoundEffect alloc] initWithBuffer:buf])) {
        s.oneshot = YES;
        [s play];
    }
    return s;
}

- (void) dealloc {
    self.alBuffer = nil;
    alDeleteSources(1, &sourceId); // delete source
    NSLog(@"SoundEffect %@ dealloc\n", self);
    [super dealloc];
}

/// overrides synthesize property method
- (void) setAlBuffer:(ALBuffer *)inbuf {
    alSourcei(sourceId, AL_BUFFER, 0); // detach current buffer
    [alBuffer release];
    if ( (alBuffer = [inbuf retain]) ) {
        alSourcei(sourceId, AL_BUFFER, alBuffer.name); // attach new buffer to alsource .. should be ok with nil inbuf..
        ALCHKERR("bind source to buffer");
    }
}

/// property method override
- (void) setLooping:(BOOL)yn {
    alSourcei(sourceId, AL_LOOPING, yn ? AL_TRUE : AL_FALSE);
    looping = yn;
}

- (BOOL)isPlaying {
    ALint state;
    alGetSourcei(sourceId, AL_SOURCE_STATE, &state);
    return state == AL_PLAYING;
}

- (BOOL)isPaused {
    ALint state;
    alGetSourcei(sourceId, AL_SOURCE_STATE, &state);
    return state == AL_PAUSED;
}

- (BOOL)isStopped {
    ALint state;
    alGetSourcei(sourceId, AL_SOURCE_STATE, &state);
    return state == AL_STOPPED;
}

- (unsigned long) secondsOffset {// if playing, the offset in seconds of the currently playin sample
    ALint off;
    alGetSourcei(sourceId, AL_SEC_OFFSET, &off);
    return off;
}

- (void) play {
    alSourcePlay(sourceId);

    ALCHKERR("play");

    if (oneshot)
        // kind of a HACK
        [NSTimer scheduledTimerWithTimeInterval: alBuffer.duration+0.001 /* schedule autodelete 1ms after it ends */
                 target: self
                 selector: @selector(deleteSelf)
                 userInfo: nil
                 repeats: NO ];

}

- (void) stop {
    alSourceStop(sourceId);
    ALCHKERR("stop");
}

- (void) pause {
    alSourcePause(sourceId);
}

+ (void) makeContextCurrent {
    alCommonContextMakeCurrent();
}

- (void) deleteSelf {
    [self autorelease];
}

@end

