#import "MainScene.h"

@implementation MainScene

// default config
- (void)didLoadFromCCB
{
    NSString* dateString;
    dateString = @"";
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];

    // or @"yyyy-MM-dd hh:mm:ss a" if you prefer the time with AM/PM
    dateString = [dateString stringByAppendingString:[dateFormatter stringFromDate:[NSDate date]]];
    dateString = [dateString stringByAppendingString:@".txt"];
    dateString = [dateString stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0]stringByAppendingPathComponent:dateString];
    NSString *rootFile = [[paths objectAtIndex:0]stringByAppendingPathComponent:@"currentLog.txt"];
    
    NSString *temp = @"Log for this session";
    [temp writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    [filePath writeToFile:rootFile atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

- (void) play
{
    CCScene *gameplayScene = [CCBReader loadAsScene:@"MapLevels"];
    [[CCDirector sharedDirector] replaceScene:gameplayScene];
}

- (void) goToCodex
{
    CCScene *gameplayScene = [CCBReader loadAsScene:@"WeaponsCodex"];
    [[CCDirector sharedDirector] replaceScene:gameplayScene];
}

- (void) goToLater
{
    CCScene *gameplayScene = [CCBReader loadAsScene:@"Levels/LevelTest"];
    [[CCDirector sharedDirector] replaceScene:gameplayScene];
}


/*
 NIVEIS
 */


@end
