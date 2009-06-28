#import "ALCommon.h"

ALCdevice *commonALDevice = NULL;
ALCcontext *commonALContext = NULL;

const char *alErrStr(int err) {
    switch (err) {
    case ALC_NO_ERROR: return "There is no current error.";
    case ALC_INVALID_DEVICE: return "The device handle or specifier names an accessible driver/server.";
    case ALC_INVALID_CONTEXT: return "The Context argument does not name a valid context.";
    case ALC_INVALID_ENUM: return "A token used is not valid, or not applicable.";
    case ALC_INVALID_VALUE: return "A value (e.g. Attribute) is not valid, or not applicable.";
    case ALC_OUT_OF_MEMORY: return "Unable to allocate memory.";
    }
    return "Unknown error.";
}


int alCommonContextMakeCurrent(void) {
        if (!commonALContext || !commonALDevice) {
            if (!commonALDevice)
                commonALDevice = alcOpenDevice(NULL);
            if (!commonALContext) 
                commonALContext = alcCreateContext(commonALDevice, NULL);
            ALCHKERR("create context");
        }
        alcMakeContextCurrent(commonALContext);
        ALCHKERR("make context current");
        return commonALDevice && commonALContext;
}

void alCommonContextTeardown(void) {
    if (commonALContext) alcDestroyContext(commonALContext), commonALContext = NULL;
    if (commonALDevice) alcCloseDevice(commonALDevice), commonALDevice = NULL;
}

