//
//  main.m
//  phonemes
//
//  Created by Scott Shepherd on 5/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

NSString *usage = @"usage: phonemes -h\n       phonemes [-t] [-v voice] text";

NSString *getPhonemes(NSString *input, int voiceNum, BOOL outputTune)
{
  SpeechChannel chan = nil;
  
  if (voiceNum == 0) {
    NewSpeechChannel(NULL, &chan);
  } else {
    VoiceSpec voice;
    GetIndVoice(voiceNum, &voice);
    NewSpeechChannel(&voice, &chan);
  }
    
  CFStringRef phonemes;
  
  if (outputTune) SetSpeechProperty(chan, kSpeechPhonemeOptionsProperty, "1248");
  CopyPhonemesFromText(chan, (CFStringRef) input, &phonemes);
  
  DisposeSpeechChannel(chan);
  
  return (NSString *)phonemes;
}

int voiceForName(NSString *name)
{
  SInt16 voiceCount = 0;
  CountVoices(&voiceCount);
  VoiceDescription vd;
  VoiceSpec voiceSpec;
  
  for (short i = 1; i <= voiceCount; i++) {
    GetIndVoice(i, &voiceSpec);
    GetVoiceDescription(&voiceSpec, &vd, sizeof(VoiceDescription));
    NSString *vdName = (NSString *)CFStringCreateWithPascalString(NULL, vd.name, kCFStringEncodingUTF8);
    if ([vdName isEqualToString:name]) return i;
  }
  return 0;
}

int main (int argc, const char * argv[])
{
  
  NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
  
  NSString *input = nil;
  int voice = 0;
  BOOL outputTune = NO;
  
  NSMutableArray *args = [NSMutableArray arrayWithArray:[[NSProcessInfo processInfo] arguments]];
  [args removeObjectAtIndex:0]; // first arg is path to executable
  
  // support -h opt for help
  if ([args count] > 0 && [@"-h" isEqualToString:[args objectAtIndex:0]]) {
    printf("%s\n", [usage UTF8String]);
    return 0;
  }
  
  BOOL checkingForOpts = YES;
  while (checkingForOpts) {
    
    // support -t opt to output tune data
    if ([args count] > 0 && [@"-t" isEqualToString:[args objectAtIndex:0]]) {
      [args removeObjectAtIndex:0];
      outputTune = YES;
    } 

    // support -v opt to name the voice
    else if ([args count] > 1 && [@"-v" isEqualToString:[args objectAtIndex:0]]) {
      [args removeObjectAtIndex:0];
      NSString *voiceName = [args objectAtIndex:0]; [args removeObjectAtIndex:0];
      voice = voiceForName(voiceName);
      if (voice == 0) {
        printf("Voice not found: %s\n", [voiceName UTF8String]);
        return 1;      
      }
    }
    
    else {
      checkingForOpts = NO;
    }
    
  }
  
  // rest of arguments are the input
  input = [args componentsJoinedByString:@" "];
  
  NSString *output = getPhonemes(input, voice, outputTune);
  printf("%s\n", [output UTF8String]);
  
  [pool drain];
  return 0;
}
