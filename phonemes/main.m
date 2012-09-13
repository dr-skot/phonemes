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

char *getPhonemes(NSString *input, int voiceNum, BOOL outputTune)
{
  SpeechChannel chan = nil;
  
  if (voiceNum == 0) {
    NewSpeechChannel(0, &chan);
  } else {
    VoiceSpec voice;
    GetIndVoice(voiceNum, &voice);
    NewSpeechChannel(&voice, &chan);
  }
  
  Handle phonemeHandle = NewHandle(0);
  long phonemeByteCount = 0;
  
  if (outputTune) SetSpeechInfo(chan, soPhonemeOptions, "1248");
  TextToPhonemes(chan, [input UTF8String], input.length, phonemeHandle, &phonemeByteCount);
  
  char *result = malloc(phonemeByteCount+1);
  strncpy(result, *phonemeHandle, phonemeByteCount);
  result[phonemeByteCount] = 0;
  
  ReleaseResource(phonemeHandle);
  DisposeSpeechChannel(chan);
  
  return result;
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
  
  // support -t opt to output tune data
  if ([args count] > 1 && [@"-t" isEqualToString:[args objectAtIndex:0]]) {
    [args removeObjectAtIndex:0];
    outputTune = YES;
  }
  
  // support -v opt to name the voice
  if ([args count] > 1 && [@"-v" isEqualToString:[args objectAtIndex:0]]) {
    [args removeObjectAtIndex:0];
    NSString *voiceName = [args objectAtIndex:0]; [args removeObjectAtIndex:0];
    voice = voiceForName(voiceName);
    if (voice == 0) {
      printf("Voice not found: %s\n", [voiceName UTF8String]);
      return 1;      
    }
    /*
     voice = [@"com.apple.speech.synthesis.voice." stringByAppendingString:voice];
     if (NSNotFound == [[NSSpeechSynthesizer availableVoices] indexOfObject:voice]) {
     printf("Voice not found: %s\n", [voice UTF8String]);
     return 1;
     }
     */
  }
  
  // rest of arguments are the input
  input = [args componentsJoinedByString:@" "];
  
  /*
   NSDictionary *dict = [NSDictionary dictionaryWithObject:@"1248" forKey:@"soPhonemeOptions"];
   NSSpeechSynthesizer *synthesizer = [[NSSpeechSynthesizer alloc] initWithVoice:voice];
   [synthesizer setObject:dict forProperty:NSSpeechSynthesizerInfoProperty error:nil];
   NSString *output = [synthesizer phonemesFromText:input];
   printf("%s\n", [output UTF8String]);
   [synthesizer release];
   */
  
  char *output = getPhonemes(input, voice, outputTune);
  printf("%s\n", output);
  
  [pool drain];
  return 0;
}
