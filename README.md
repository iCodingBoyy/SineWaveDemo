SineWaveDemo
============

一个简单的正弦波发生器

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

kSineFrequency：产生正弦波的频率，你可以测试需改，一般在22KHZ以下
buffer[frame] = sin(theta)*0.25; 0.25为正弦波的振幅，可以根据需要修改


在使用此demo产生正弦波之前，你需要设置音频描述格式如下：
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
    
这是一个44100HZ和双声道发声器
