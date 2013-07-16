//
//  SoundManager.cpp
//  asteroidsTest
//
//  Created by Alex Gievsky on 26.06.13.
//  Copyright (c) 2013 reenboog. All rights reserved.
//

#include "SoundManager.h"

#define kMaxAudioOutputSources 2

@implementation AVPlayerListener

- (void) dealloc {
    //
    [super dealloc];
}

- (void) audioPlayerBeginInterruption: (AVAudioPlayer *) player {
    SoundManager *mngr = SoundManager::mngr();

	mngr->setBackgroundMusicInterrupted(true);
	mngr->setBackgroundMusicPlaying(false);
}

- (void) audioPlayerEndInterruption: (AVAudioPlayer *) player {
    SoundManager *mngr = SoundManager::mngr();
	if (mngr->getBackgroundMusicInterrupted()) {
		
        SoundManager::mngr()->playBackgroundIfAny();
        
		mngr->setBackgroundMusicInterrupted(false);
	}
}

@end

SoundManager* SoundManager::__instance = nullptr;

SoundManager::~SoundManager() {
    purge();

    [_playerListener release];
    _playerListener = nil;
    //alDeleteSources(1, &_outputSource);
        
    alcDestroyContext(_openALContext);
    alcCloseDevice(_openALDevice);
}

SoundManager::SoundManager() {
    //fake for a while
    _currentOutputSourceIndex = 0;

    _bgMusic = nil;
    _bgMusicPlaying = false;
	_bgMusicInterrupted = false;
    
    _playerListener = [[AVPlayerListener alloc] init];
}

void SoundManager::init() {
    _openALDevice = alcOpenDevice(NULL);
    _openALContext = alcCreateContext(_openALDevice, NULL);
    
    alcMakeContextCurrent(_openALContext);

    for(Int i = 1; i <= kMaxAudioOutputSources; ++i) {
        
        ALuint outputSource;
        alGenSources(i, &outputSource);
        
        // set source parameters
        alSourcef(outputSource, AL_PITCH, 1.0f);
        
        alSourcef(outputSource, AL_GAIN, 1.0f);
        
        _outputSources.push_back(outputSource);
    }
}

SoundManager* SoundManager::mngr() {
    if(__instance == nullptr) {
        __instance = new SoundManager();
        __instance->init();
    }
    
    return __instance;
}

void SoundManager::purge() {
    for(auto effect: _effects) {
        ALuint outputBuffer = (ALuint)effect.second;
        alDeleteBuffers(1, &outputBuffer);
    }
    
    for(Int i = 1; i <= kMaxAudioOutputSources; ++i) {
        ALuint outputSource = _outputSources[i - 1];
        alDeleteSources(i, &outputSource);
    }
    
    _effects.clear();
    
    [_bgMusic release];
    _bgMusic = nil;
}

Bool SoundManager::playEffect(string file) {
    auto effectIt = _effects.find(file);
    
    if(effectIt != _effects.end()) {
        ALuint outputBuffer = (ALuint)effectIt->second;

        ALuint source = _outputSources[_currentOutputSourceIndex];
        
        alSourcei(source, AL_BUFFER, outputBuffer);
        alSourcePlay(source);
        
        _currentOutputSourceIndex++;
        
        if(_currentOutputSourceIndex == kMaxAudioOutputSources) {
            _currentOutputSourceIndex = 0;
        }
        
    } else {
        ALuint outputBuffer = loadEffect(file);
        
        ALuint source = _outputSources[_currentOutputSourceIndex];
        
        if(outputBuffer != -1) {
            alSourcei(source, AL_BUFFER, outputBuffer);
            alSourcePlay(source);
            
            _currentOutputSourceIndex++;
            
            if(_currentOutputSourceIndex == kMaxAudioOutputSources) {
                _currentOutputSourceIndex = 0;
            }

        } else {
            return false;
        }
    }
    
    return true;
}

ALuint SoundManager::loadEffect(string file) {
    NSString *filePath = [[NSBundle mainBundle] pathForResource: [NSString stringWithFormat: @"res/%s", file.c_str()]
                                                         ofType: @"wav"];
    NSURL *fileUrl = [NSURL fileURLWithPath: filePath];
    
    // the AudioFileID is an opaque identifier that Audio File Services
    // uses to refer to the audio file
    AudioFileID afid;
    
    // open the file and get an AudioFileID for it. 0 indicates we're not
    // providing a file type hint because the file name extension will suffice.
    OSStatus openResult = AudioFileOpenURL((CFURLRef)fileUrl, kAudioFileReadPermission, 0, &afid);
    
    UInt64 fileSizeInBytes = 0;
    UInt32 propSize = sizeof(fileSizeInBytes);
    OSStatus getSizeResult = AudioFileGetProperty(afid, kAudioFilePropertyAudioDataByteCount, &propSize, &fileSizeInBytes);
    
    if(0 != getSizeResult) {
        NSLog(@"An error occurred when attempting to determine the size of audio file %@: %ld", filePath, getSizeResult);
        return -1;
    }
    
    UInt32 bytesRead = (UInt32)fileSizeInBytes;
    
    void *audioData = malloc(bytesRead);
    
    // false means we don't want the data cached. 0 means read from the beginning.
    // bytesRead will end up containing the actual number of bytes read.
    
    OSStatus readBytesResult = AudioFileReadBytes(afid, false, 0, &bytesRead, audioData);
    
    if(0 != readBytesResult) {
        NSLog(@"An error occurred when attempting to read data from audio file %@: %ld", filePath, readBytesResult);
    }
    
    // close the file
    AudioFileClose(afid);
    
    if(0 != openResult) {
        NSLog(@"An error occurred when attempting to open the audio file %@: %ld", filePath, openResult);
        
        if(audioData) {
            free(audioData);
            audioData = NULL;
        }
        return -1;
    }
    
    ALuint outputBuffer;
    alGenBuffers(1, &outputBuffer);
    
    alBufferData(outputBuffer, AL_FORMAT_STEREO16, audioData, bytesRead, 44100);
    
    if(audioData) {
        free(audioData);
        audioData = NULL;
    }
    
    _effects.insert({file, outputBuffer});
    
    return outputBuffer;
}

Bool SoundManager::preloadEffect(string file) {
    if(loadEffect(file) == -1) {
        return  false;
    } else {
        return true;
    }
}

Bool SoundManager::playBackground(string file) {
    if(_bgMusic) {
        // release previous background music data first
        [_bgMusic release];
        _bgMusic = nil;
    }
    
    NSError *setCategoryError = nil;
	[[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryAmbient
                                           error: &setCategoryError];
	
	// Create audio player with background music
	NSString *backgroundMusicPath = [[NSBundle mainBundle] pathForResource: [NSString stringWithFormat: @"res/%s", file.c_str()]
                                                                    ofType: @"mp3"];

	NSURL *backgroundMusicURL = [NSURL fileURLWithPath:backgroundMusicPath];
	NSError *error;
	_bgMusic = [[AVAudioPlayer alloc] initWithContentsOfURL: backgroundMusicURL
                                                      error: &error];
	[_bgMusic setDelegate: _playerListener];
	[_bgMusic setNumberOfLoops: -1];	// Negative number means loop forever
    [_bgMusic setVolume: 0.1];
    
    playBackgroundIfAny();
    return true;
}

void SoundManager::pauseBackground() {
    [_bgMusic pause];
    _bgMusicPlaying = false;
}

void SoundManager::stopBackground() {
    if(_bgMusic && _bgMusicPlaying) {
        [_bgMusic stop];
        _bgMusicPlaying = false;
    }
}

void SoundManager::resumeBackground() {
    playBackgroundIfAny();
}

void SoundManager::playBackgroundIfAny() {
    if(!_bgMusic) {
        return;
    }
    
    UInt32 otherMusicIsPlaying;
    UInt32 propertySize = sizeof(otherMusicIsPlaying);
	AudioSessionGetProperty(kAudioSessionProperty_OtherAudioIsPlaying, &propertySize, &otherMusicIsPlaying);
	
	// play the music if no other music is playing and we aren't playing already
	if(otherMusicIsPlaying != 1 && !_bgMusicPlaying) {
		[_bgMusic prepareToPlay];
		[_bgMusic play];
		_bgMusicPlaying = true;
	}
}

void SoundManager::setBackgroundMusicInterrupted(Bool interrupted) {
    _bgMusicInterrupted = interrupted;
}

Bool SoundManager::getBackgroundMusicInterrupted() {
    return _bgMusicInterrupted;
}

void SoundManager::setBackgroundMusicPlaying(Bool playing) {
    _bgMusicPlaying = playing;
}

Bool SoundManager::getBackgroundMusicPlaying() {
    return _bgMusicPlaying;
}
