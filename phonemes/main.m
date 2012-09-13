//
//  main.m
//  phonemes
//
//  Created by Scott Shepherd on 5/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

NSString *usage = @"usage: phonemes -h\n       phonemes [-v voice] text";

int main (int argc, const char * argv[])
{
  NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
  
  NSString *voice = nil;
  NSString *input = nil;
  
  NSMutableArray *args = [NSMutableArray arrayWithArray:[[NSProcessInfo processInfo] arguments]];
  [args removeObjectAtIndex:0]; // first arg is path to executable

  // support -h opt for help
  if ([args count] > 0 && [@"-h" isEqualToString:[args objectAtIndex:0]]) {
    printf("%s\n", [usage UTF8String]);
    return 0;
  }
  
  // support -v opt to name the voice
  if ([args count] > 1 && [@"-v" isEqualToString:[args objectAtIndex:0]]) {
    [args removeObjectAtIndex:0];
    voice = [args objectAtIndex:0]; [args removeObjectAtIndex:0];
    voice = [@"com.apple.speech.synthesis.voice." stringByAppendingString:voice];
    if (NSNotFound == [[NSSpeechSynthesizer availableVoices] indexOfObject:voice]) {
      printf("Voice not found: %s\n", [voice UTF8String]);
      return 1;
    }
  }
  
  // rest of arguments are the input
  input = [args componentsJoinedByString:@" "];
  
  NSSpeechSynthesizer *synthesizer = [[NSSpeechSynthesizer alloc] initWithVoice:voice];
  NSString *output = [synthesizer phonemesFromText:input];
  printf("%s\n", [output UTF8String]);
  [synthesizer release];

  [pool drain];
  return 0;
}
