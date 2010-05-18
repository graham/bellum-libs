#import <OpenAL/al.h>
#import <OpenAL/alc.h>

extern ALCdevice *commonALDevice;
extern ALCcontext *commonALContext;

extern const char *alErrStr(int err);

#define ALCHKERR(x) do { \
  int err = alcGetError(commonALDevice); \
  if (err != ALC_NO_ERROR) { \
      NSLog(@"AL error after %s: %d (%s)\n", x, err, alErrStr(err)); \
  } \
} while (0)

extern int alCommonContextMakeCurrent(void);
extern void alCommonContextTeardown(void);
