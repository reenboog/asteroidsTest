//
//  SoundManager.h
//  match3Test
//
//  Created by Alex Gievsky on 26.06.13.
//  Copyright (c) 2013 reenboog. All rights reserved.
//

#ifndef __match3Test__SoundManager__
#define __match3Test__SoundManager__

#import "Types.h"

#import <OpenAL/al.h>
#import <OpenAL/alc.h>

#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

@interface AVPlayerListener: NSObject <AVAudioPlayerDelegate> {
    
}

@end

typedef map<string, ALuint> EffectMap;
typedef vector<ALuint> AudioOutputSources;

class SoundManager {
private:
    // use AV for the background music
    AVPlayerListener *_playerListener;
    AVAudioPlayer *_bgMusic;
    Bool _bgMusicPlaying;
	Bool _bgMusicInterrupted;
    
    // use openAL for small sounds
    ALCdevice *_openALDevice;
    ALCcontext *_openALContext;
    
    AudioOutputSources _outputSources;
    Int _currentOutputSourceIndex;

    static SoundManager *__instance;
    
    EffectMap _effects;
private:
    SoundManager();
    ALuint loadEffect(string file);
    
    void init();
public:
    virtual ~SoundManager();
    
    Bool playEffect(string file);
    Bool playBackground(string file);
    
    void playBackgroundIfAny();
    
    void setBackgroundMusicInterrupted(Bool interrupted);
    Bool getBackgroundMusicInterrupted();
    
    void setBackgroundMusicPlaying(Bool playing);
    Bool getBackgroundMusicPlaying();

    void pauseBackground();
    void stopBackground();
    void resumeBackground();
    
    static SoundManager *mngr();
    void purge();

    Bool preloadEffect(string file);
};

#endif /* defined(__match3Test__SoundManager__) */
