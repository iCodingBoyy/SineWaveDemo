//
//  SineWaveViewController.m
//  SineWaveDemo
//
//  Created by 马远征 on 14-3-20.
//  Copyright (c) 2014年 马远征. All rights reserved.
//

#import "SineWaveViewController.h"
#import <AudioToolbox/AudioToolbox.h>

static const float kSampleRate = 44100;
static const float kSineFrequency = 22000.0;

@interface SineWaveViewController ()
{
    AudioComponentInstance toneUnit;
    float amplitude;
    float theta;
    float sineFrequency;
}
@end

@implementation SineWaveViewController

- (void)dealloc
{
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        
    }
    return self;
}

OSStatus RenderTone(
                    void *inRefCon,
                    AudioUnitRenderActionFlags 	*ioActionFlags,
                    const AudioTimeStamp 		*inTimeStamp,
                    UInt32 						inBusNumber,
                    UInt32 						inNumberFrames,
                    AudioBufferList 			*ioData)

{
    SineWaveViewController *viewController = (__bridge SineWaveViewController *)inRefCon;
	float theta = viewController->theta;
	float theta_increment =  2*M_PI * kSineFrequency /kSampleRate;
    
	const int channel = 0;
    const int channel1 = 1;
	Float32 *buffer = (Float32 *)ioData->mBuffers[channel].mData;
    Float32 *buffer1 = (Float32 *)ioData->mBuffers[channel1].mData;
	for (UInt32 frame = 0; frame < inNumberFrames; frame++)
	{
		buffer[frame] = sin(theta)*0.25;
        buffer1[frame] = sin(theta)*0.25;
		theta += theta_increment;
        if (theta >= (M_PI * 2))
        {
            theta -= (M_PI * 2);
        }
	}
	viewController->theta = theta;
    return noErr;
}

void ToneInterruptionListener(void *inClientData, UInt32 inInterruptionState)
{

    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    OSStatus result = AudioSessionInitialize(NULL, NULL, ToneInterruptionListener, (__bridge void *)(self));
	if (result == kAudioSessionNoError)
	{
		UInt32 sessionCategory = kAudioSessionCategory_PlayAndRecord;
		AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(sessionCategory), &sessionCategory);
        AudioSessionSetActive(true);
	}
    else
    {
        return;
    }
	
    
    AudioComponentDescription defaultOutputDescription;
	defaultOutputDescription.componentType = kAudioUnitType_Output;
	defaultOutputDescription.componentSubType = kAudioUnitSubType_RemoteIO;
	defaultOutputDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
	defaultOutputDescription.componentFlags = 0;
	defaultOutputDescription.componentFlagsMask = 0;
	AudioComponent defaultOutput = AudioComponentFindNext(NULL, &defaultOutputDescription);
	OSErr err = AudioComponentInstanceNew(defaultOutput, &toneUnit);
	
    AURenderCallbackStruct input;
    memset(&input, 0, sizeof(AURenderCallbackStruct));
    input.inputProc = RenderTone;
    input.inputProcRefCon = (__bridge void *)(self);
    err = AudioUnitSetProperty(toneUnit,
                               kAudioUnitProperty_SetRenderCallback,
                               kAudioUnitScope_Input,
                               0,
                               &input,
                               sizeof(input));
    
    AudioStreamBasicDescription audioDescription;
    memset(&audioDescription, 0, sizeof(audioDescription));
    audioDescription.mFormatID          = kAudioFormatLinearPCM;
    audioDescription.mFormatFlags       = kAudioFormatFlagIsFloat | kAudioFormatFlagIsPacked | kAudioFormatFlagIsNonInterleaved;
    audioDescription.mChannelsPerFrame  = 2;
    audioDescription.mBytesPerPacket    = sizeof(float);
    audioDescription.mFramesPerPacket   = 1;
    audioDescription.mBytesPerFrame     = sizeof(float);
    audioDescription.mBitsPerChannel    = 8 * sizeof(float);
    audioDescription.mSampleRate        = 44100.0;
    
	err = AudioUnitSetProperty (toneUnit,
                                kAudioUnitProperty_StreamFormat,
                                kAudioUnitScope_Input,
                                0,
                                &audioDescription,
                                sizeof(AudioStreamBasicDescription));
    err = AudioUnitInitialize(toneUnit);
    if (err)
    {
        NSLog(@"----AudioUnitInitialize---Error-");
    }
    
    UIButton *startbutton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [startbutton setFrame:CGRectMake(120, 120, 80, 44)];
    [startbutton setTitle:@"start" forState:UIControlStateNormal];
    [startbutton setTitle:@"start" forState:UIControlStateHighlighted];
    [startbutton addTarget: self action:@selector(clickToStart) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:startbutton];
    
    UIButton *endbutton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [endbutton setFrame:CGRectMake(120, 170, 80, 44)];
    [endbutton setTitle:@"end" forState:UIControlStateNormal];
    [endbutton setTitle:@"end" forState:UIControlStateHighlighted];
    [endbutton addTarget: self action:@selector(clickToEnd) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:endbutton];
}

- (void)clickToStart
{
    OSStatus status = AudioOutputUnitStart(toneUnit);
    if (status)
    {
        printf("---start_Error----");
    }

}

- (void)clickToEnd
{
    OSStatus status = AudioOutputUnitStop(toneUnit);
    if (status)
    {
        printf("---stop_Error----");
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end
