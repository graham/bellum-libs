#import "ALBuffer.h"
#import "ALCommon.h"
#import <AudioToolbox/AudioToolbox.h>


@interface ALBuffer (PrivateMethods)
// returns duration in seconds, or -1 on error
+ (NSTimeInterval) loadCAF:(NSString *)file toBuffer:(ALuint)bufferID sizeOut:(unsigned long *)sizeOut;
@end

@implementation ALBuffer
@synthesize name,dataSize,duration;

- (id) initWithContentsOfFile:(NSString *)file {

    if ((self = [super init])) {
        if (!alCommonContextMakeCurrent()) {
            NSLog(@"ALBuffer init failed, no context! (file: %@)\n",file);
            [self release]; 
            return nil;
        }

        alGenBuffers(1, &name);
        ALCHKERR("gen buffers");
                 
        NSTimeInterval dur = [ALBuffer loadCAF:file toBuffer:name sizeOut:&dataSize];

        duration = dur;

        if (dur < 0.) {
            NSLog(@"Error reading file: %@, returning nil from ALBuffer constructor!\n", file);
            [self release];
            return nil;
        }
    }
    return self;    
}

- (void) dealloc {
    alDeleteBuffers(1, &name); // delete buffer    
    [super dealloc];
}

+ (NSTimeInterval) loadCAF:(NSString *)file toBuffer:(ALuint)bufferID sizeOut:(unsigned long *)sizeOut {
        NSTimeInterval ret = -1.;
        *sizeOut = 0UL;

	NSURL *fileURL = [NSURL fileURLWithPath:file];
        
	AudioFileID	audioFileID;
	OSStatus s =
            AudioFileOpenURL ((CFURLRef)fileURL,
                              0x01, //fsRdPerm read only
                              kAudioFileCAFType,
                              &audioFileID
                              );
        
        if (s) {
            NSLog(@"Error opening %@: '%4c'  code: %x\n", file, (char *)&s, s);
            return -1;
        }

	UInt32 nPropertySize = 0;
	UInt32 nPropertyWritable = 0;
        s = 
	AudioFileGetPropertyInfo (audioFileID,
                                  kAudioFilePropertyAudioDataPacketCount,
                                  &nPropertySize,
                                  &nPropertyWritable);

        if (s) {
            NSLog(@"Error from AudioFileGetPropertyInfo: '%4c'  code: %x\n", (char *)&s, s);
            AudioFileClose(audioFileID);
            return -1;
        }

	UInt64 sampleLength;
	if (sizeof(sampleLength) == nPropertySize)	{
		AudioFileGetProperty(audioFileID, kAudioFilePropertyAudioDataPacketCount, &nPropertySize, &sampleLength);
	} else {
            NSLog(@"loadCAF: Uunexpected error retrieving kAudioFilePropertyAudioDataPacketCount, should be 64-bit number, but it wasn't.\n");
            AudioFileClose(audioFileID);
            return -1;
        }

        s = 
	AudioFileGetPropertyInfo(audioFileID,
                                 kAudioFilePropertyEstimatedDuration,
                                 &nPropertySize,
                                 &nPropertyWritable);

        if (s) {
            NSLog(@"Non-fatal error from AudioFileGetPropertyInfo (duration): '%4c'  code: %x\n", (char *)&s, s);
            ret = 0.;
        } else if (nPropertySize == sizeof(float)) {
            float dur;
            AudioFileGetProperty(audioFileID, kAudioFilePropertyEstimatedDuration, &nPropertySize, &dur);
            ret = dur;
        } else if (nPropertySize == sizeof(double)) {
            double dur;
            AudioFileGetProperty(audioFileID, kAudioFilePropertyEstimatedDuration, &nPropertySize, &dur);
            ret = dur;
        } else {
            NSLog(@"AudioFileProperty EstimatedDuration should be a float or a double!  Aieeee... defaulting to 0!\n");
            ret = 0.;
        }
        

	AudioStreamBasicDescription desc;
	UInt32 nPropSize = sizeof(desc);
	s = AudioFileGetProperty(audioFileID, kAudioFilePropertyDataFormat, &nPropSize, &desc);

        if (s) {
            NSLog(@"Fatal error from AudioFileGetProperty (data format): '%4c'  code: %x\n", (char *)&s, s);
            AudioFileClose(audioFileID);
            return -1;
        } else if (desc.mFormatID != kAudioFormatLinearPCM
                   || desc.mBitsPerChannel != 16) {
            NSLog(@"Format error for soundfile '%@': only 16-bit linear PCM format is supported at this time!\n", file);
            AudioFileClose(audioFileID);
            return -1;
        }

        *sizeOut = sampleLength * desc.mBytesPerPacket;

	UInt32 nOutNumBytes, nOutNumPackets;
	nOutNumPackets = sampleLength;
	void *sampleData = malloc(*sizeOut);

        s = 
	AudioFileReadPackets (audioFileID,
                              false,
                              &nOutNumBytes,
                              NULL,
                              0,
                              &nOutNumPackets,
                              sampleData
                              );

        AudioFileClose(audioFileID);

        if (s) {
            NSLog(@"AudioFileRead error on %@: '%4c' (%x)\n", file, (char *)&s, (int)s);
            return -1;
        }

	ALsizei nSoundSizeInBytes = *sizeOut;
	ALsizei nSampleRate = desc.mSampleRate;
        ALenum eFormat =  desc.mChannelsPerFrame == 1 ? AL_FORMAT_MONO16 : AL_FORMAT_STEREO16;
	alBufferData(bufferID, eFormat, sampleData, nSoundSizeInBytes, nSampleRate);

        ALCHKERR("alBufferData");

        free(sampleData);

        return ret;
}

@end
