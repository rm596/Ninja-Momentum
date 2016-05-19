//
//  Level6.m
//  NinjaMomentum
//
//  Created by Gonçalo Delgado on 19/05/16.
//  Copyright © 2016 Apportable. All rights reserved.
//

#import "Level6.h"
#import "Ninja.h"
#import "CCDirector_Private.h"
#import "CCPhysics+ObjectiveChipmunk.h"
#import "LogUtils.h"

//auxiliares slowmotion
bool enableSlowMotion6 = false;
float slowVelocity6 = 0.3f;
float ninjaCircleOpacity6 = 0.15f;
float overlayLayerOpacity6 = 0.3f;

bool asRetryLocation6 = false;
int numberOfEnemies6 = 11;

//auxiliares mira
float angleXX6 = 0.f, angleYY6 = 0.f;
float scaleAim6 = 5.0f;

CGPoint retryLocation6;
bool isPaused6 = false;

//TRIES
int numberTries6 = 0;


//auxiliares grappling hook
bool drawGrapplingHook6 = false;
int minDistanceToUseGrappling6 = 250;
int touchedPlatform6;

//LOG VARIABLES
int numberOfDeaths6 = 0;
int numberOfJumps6 = 0;
int numberOfWeaponsFired6 = 0;
int numberOfGrapplingHook6 = 0;
int numberOfTouches6 = 0;
int numberOfRetriesPerLevel6 = 0;
int numberOfSucessKnifes6 = 0;
bool jumpingFromGrappling6 = false;
int numberOfSucessGrappling6 = 0;

NSDate *start6;
NSTimeInterval timeInterval6;
LogUtils *logUtils6;

@implementation Level6{
    //physic world
    CCPhysicsNode *_physicsNode;
    
    //fix camera
    CCNode *_contentNode;
    
    //ninja
    Ninja *ninja;
    CCNode * ninjaCircle;
    CCNodeColor * overlayLayer;
    
    //botoes
    CCButton *knifeButton;
    CCButton *jumpButton;
    CCButton *resetButton;
    CCButton *grapplingHookButton;
    CCButton *retryButton;
    CCButton *startAgainButton;
    CCButton *nextButton;
    
    //scrore
    CCNodeColor *layerEnd;
    CCLabelTTF * textEnd;
    CCNode *star1;
    CCNode *star2;
    CCNode *star3;
    
    //dark souls
    CCNodeColor * overlayLayer2;
    CCLabelTTF * textMomentum;
}
// default config
- (void)didLoadFromCCB
{
    // enable touch
    self.userInteractionEnabled = TRUE;
    //enable delegate colision
    _physicsNode.collisionDelegate = self;
    
    //enable ninja aim
    [self initNinja];
    
    [self enableAllButtons:false];
    
    retryButton.visible = false;
    startAgainButton.visible = false;
    startAgainButton.enabled = false;
    retryButton.enabled = false;
    
    //desactivar proximo nivel
    layerEnd.opacity = 0.0f;
    textEnd.opacity = 0.0f;
    
    resetButton.visible = false;
    nextButton.visible = false;
    
    star1.opacity = 0.0f;
    star2.opacity = 0.0f;
    star3.opacity = 0.0f;
    
    overlayLayer2.opacity = 0.0f;
    textMomentum.opacity = 0.0f;
    
    //log
    start6 = [NSDate date];
    logUtils6 = [LogUtils sharedManager];
    
    //corda
    //   myDrawNode = [CCDrawNode node];
    //   [self addChild: myDrawNode];
}
- (void) update:(CCTime)delta
{
    //camera
    [self camera:ninja];
    
    //slow motion
    [self setupSlowMotion];
    
    //reposicionar mira ninja
    [ninja positionAimAt:ccp(0, 0)];
    
    [self outsideRoom];
    
    /*
     if(ccpDistance(ninja.positionInPoints, _platformGH1.positionInPoints) < minDistanceToUseGrappling4 || ccpDistance(ninja.positionInPoints, _platformGH2.positionInPoints) <minDistanceToUseGrappling4 ){
     [self enableGrapplingHookButton];
     }
     else{
     [self disableGrapplingButton];
     
     }
     
     [myDrawNode clear];
     
     
     if (drawGrapplingHook2){
     if(touchedPlatform == 1){
     [myDrawNode drawSegmentFrom:[_contentNode convertToWorldSpace:ninja.positionInPoints] to:[_contentNode convertToWorldSpace:_platformGH1.positionInPoints] radius:2.0f color:[CCColor colorWithRed:0 green:0 blue:0]];
     }
     else if(touchedPlatform == 2){
     [myDrawNode drawSegmentFrom:[_contentNode convertToWorldSpace:ninja.positionInPoints] to:[_contentNode convertToWorldSpace:_platformGH2.positionInPoints] radius:2.0f color:[CCColor colorWithRed:0 green:0 blue:0]];
     }
     }
     */
}

//----------------------------------------------------------------------------------------------------
//-------------------------------------------------TOUCH----------------------------------------------
//----------------------------------------------------------------------------------------------------

// called on every touch in this scene

- (void)touchBegan:(CCTouch *)touch withEvent:(CCTouchEvent *)event
{
    CGPoint touchLocation = [touch locationInNode:_contentNode];
    //log
    numberOfTouches6++;
    // NINJA
    if (CGRectContainsPoint([ninja boundingBox], touchLocation))
    {
        //acao default = salto
        if (([ninja action] == IDDLE && [ninja canJump]) || ([ninja action] == -1 && [ninja canJump])) {
            
            [ninja setAction:JUMP];
            
            
            
        }
        
        //activar mira
        if(([ninja action] != IDDLE && [ninja canJump]) || ([ninja canShoot])){
            [ninja enableAim:true];
            
            if(![ninja initialJump])
                [self schedule:@selector(reduceCircle) interval:0.05 repeat:20 delay:0];
        }
    }
    /*
     //vou ver se cliquei dentro GH
     else if(CGRectContainsPoint([_platformGH1 boundingBox],touchLocation))
     {
     if([ninja action] == GRAPPLING)
     {
     
     joint = [CCPhysicsJoint connectedDistanceJointWithBodyA:ninja.physicsBody
     bodyB:_platformGH1.physicsBody
     anchorA:ninja.anchorPointInPoints
     anchorB:_platformGH1.anchorPointInPoints];
     //log
     numberOfGrapplingHook5++;
     
     drawGrapplingHook5 = true;
     [self unschedule:@selector(reduceCircle)];
     [self resetCircle];
     touchedPlatform5 = 1;
     }
     }
     
     else if(CGRectContainsPoint([_platformGH2 boundingBox],touchLocation))
     {
     if([ninja action] == GRAPPLING)
     {
     
     joint = [CCPhysicsJoint connectedDistanceJointWithBodyA:ninja.physicsBody
     bodyB:_platformGH2.physicsBody
     anchorA:ninja.anchorPointInPoints
     anchorB:_platformGH2.anchorPointInPoints];
     //log
     numberOfGrapplingHook5++;
     
     drawGrapplingHook4 = true;
     [self unschedule:@selector(reduceCircle)];
     [self resetCircle];
     touchedPlatform4 = 2;
     }
     }
     else if([ninja action] == GRAPPLING)
     {
     //log
     jumpingFromGrappling4 = true;
     drawGrapplingHook4 = false;
     [joint invalidate];
     joint = nil;
     [self enableGrapplingHookButton];
     [ninja setAction:IDDLE];
     //[self unschedule:@selector(reduceCircle)];
     //[self resetCircle];
     }
     */
    else
    {
        [ninja setAction:IDDLE];
    }
}

//update touch and rotation
- (void) touchMoved:(CCTouch *)touch withEvent:(CCTouchEvent *)event
{
    if ([ninja action] == JUMP || [ninja action] == KNIFE)
    {
        //[ninja enableAim:true];
        
        //localizacao toque
        CGPoint touchLocation = [touch locationInNode:_contentNode];
        
        angleYY6 = clampf(touchLocation.y - (ninja.boundingBox.origin.y + ninja.boundingBox.size.height/2), -80, 80);
        angleXX6 = clampf(touchLocation.x - (ninja.boundingBox.origin.x + ninja.boundingBox.size.width/2), -10, 10);
        
        //actualizar angulo e escala mira
        [ninja updateAim:angleYY6 withScale:-angleXX6/scaleAim6];
    }
}

- (void) touchEnded:(CCTouch *)touch withEvent:(CCTouchEvent *)event
{
    //DESACTIVAR BUTOES / TEMPO
    if([ninja action] == KNIFE){
        //log
        numberOfWeaponsFired6++;
        [self disableKnifeButton:YES];
    }
    
    else if([ninja action] == GRAPPLING)
    {
        //CCLOG(@"disable GH");
        
        [self disableGrapplingButton];
        
        //CCLOG(@"desactivar circulo");
        
        [self unschedule:@selector(reduceCircle)];
        [self resetCircle];
    }
    
    [self unschedule:@selector(reduceCircle)];
    [self resetCircle];
    
    //fazer acao ninja
    [ninja action:_physicsNode withAngleX:angleXX6 withAngleY:angleYY6];
    
    //apagar mira
    [ninja enableAim:false];
    
    //desactivar salto
    if(([ninja action] == JUMP) && [ninja canJump])
    {
        [ninja setCanJump:false];
        
        //activat butoes so uma vez
        if([ninja initialJump])
        {
            [self enableAllButtons:true];
            [ninja setInitialJump:false];
        }
    }
}

//----------------------------------------------------------------------------------------------------
//-------------------------------------------------NINJA INIT-----------------------------------------
//----------------------------------------------------------------------------------------------------
- (void) initNinja
{
    //init aim
    [ninja initAim:_physicsNode];
}

//----------------------------------------------------------------------------------------------------
//-------------------------------------------------CAMERA---------------------------------------------
//----------------------------------------------------------------------------------------------------
- (void) camera:(CCNode*) ninja
{
    self.position = ccp(0, 0);
    CCActionFollow *follow = [CCActionFollow actionWithTarget:ninja worldBoundary:self.boundingBox];
    [_contentNode runAction:follow];
}


//----------------------------------------------------------------------------------------------------
//-------------------------------------------------BUTTONS--------------------------------------------
//----------------------------------------------------------------------------------------------------

-(void) selectGrapplingHook
{
    //if([ninja action] == JUMP)
    [ninja setAction:GRAPPLING];
    
    if([ninja action] == KNIFE)
    {
        //[self unschedule:@selector(reduceCircle)];
        //[self resetCircle];
    }
    
    if(!enableSlowMotion6)
        [self schedule:@selector(reduceCircle) interval:0.05 repeat:20 delay:0];
}

- (void) enableGrapplingHookButton
{
    grapplingHookButton.background.opacity = 0.8;
    grapplingHookButton.label.opacity = 0.8;
    grapplingHookButton.userInteractionEnabled = YES;
    
}

- (void) disableGrapplingButton
{
    grapplingHookButton.background.opacity = 0.2;
    grapplingHookButton.label.opacity = 0.2;
    grapplingHookButton.userInteractionEnabled = NO;
}

-(void) selectRetry
{
    [[CCDirector sharedDirector] resume];
    retryButton.visible = false;
    startAgainButton.visible = false;
    startAgainButton.enabled = false;
    retryButton.enabled = false;
    //log
    numberOfRetriesPerLevel6 ++;
    logUtils6.totalRetries ++;
    if(asRetryLocation6)
    {
        ninja.positionInPoints = retryLocation6;
        [ninja setCanJump:true];
        [ninja verticalJump];
    }
    else{
        [self selectReset];
    }
    
    
    numberTries6++;
    //[[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d", numberTries] forKey:@"triesLevel1"];
    //[[NSUserDefaults standardUserDefaults] synchronize];
    
    CCLOG(@"tries %d", numberTries6);
    
    overlayLayer2.opacity = 0.0f;
    textMomentum.opacity = 0.0f;
}

-(void) startAgainSelected
{
    [[CCDirector sharedDirector] resume];
    retryButton.visible = false;
    startAgainButton.visible = false;
    startAgainButton.enabled = false;
    retryButton.enabled = false;
    
    overlayLayer2.opacity = 0.0f;
    textMomentum.opacity = 0.0f;
    
    [self selectReset];
}

/*
 KNIFE
 */
-(void) selectKnife
{
    //fazer reset ao slow motion, caso tenho selecionado outra arma
    [ninja setAction:KNIFE];
    [self schedule:@selector(reduceCircle) interval:0.05 repeat:20 delay:0];
}

- (void) enableKnifeButton
{
    //parar tempo
    [self unschedule:_cmd];
    
    //activar
    knifeButton.background.opacity = 0.8;
    knifeButton.label.opacity = 0.8;
    knifeButton.userInteractionEnabled = YES;
}

- (void) disableKnifeButton:(BOOL)isTimer
{
    //disale button
    knifeButton.background.opacity = 0.2;
    knifeButton.label.opacity = 0.2;
    knifeButton.userInteractionEnabled = NO;
    
    if (isTimer) {
        //setup timer
        [self schedule:@selector(enableKnifeButton) interval:1.0];
    }
}

-(void) selectReset
{
    [[CCDirector sharedDirector] resume];
    
    /*
     if(joint != nil){
     [joint invalidate];
     joint = nil;
     
     }
     */
    
    CCScene *gameplayScene = [CCBReader loadAsScene:@"Levels/Level5"];
    [[CCDirector sharedDirector] replaceScene:gameplayScene];
    
    //reset variaveis
    enableSlowMotion6=false;
    angleXX6 = 0.f, angleYY6 = 0.f;
    scaleAim6= 5.0f;
    slowVelocity6 = 0.3f;
    ninjaCircleOpacity6 = 0.15f;
    overlayLayerOpacity6 = 0.3f;
    numberOfEnemies6 = 11;
    asRetryLocation6 = false;
    //drawGrapplingHook = false;
    //enteredWater = false;
    //collidedWithWaterEnd = false;
    
    numberTries6=0;
    
    //[[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d", numberTries] forKey:@"triesLevel1"];
    //[[NSUserDefaults standardUserDefaults] synchronize];
    
    overlayLayer2.opacity = 0.0f;
    textMomentum.opacity = 0.0f;
    
    CCLOG(@"tries %d", numberTries6);
}
-(void) nextLevel
{
    CCScene *gameplayScene = [CCBReader loadAsScene:@"Levels/Level6"];
    [[CCDirector sharedDirector] replaceScene:gameplayScene];
    
    //reset variaveis
    enableSlowMotion6=false;
    angleXX6= 0.f, angleYY6 = 0.f;
    scaleAim6 = 5.0f;
    slowVelocity6 = 0.3f;
    ninjaCircleOpacity6 = 0.15f;
    overlayLayerOpacity6 = 0.3f;
    numberOfEnemies6 = 11;
    asRetryLocation6 = false;
    
    [[CCDirector sharedDirector] resume];
}

- (void) enableAllButtons:(BOOL)isEnable
{
    if(isEnable)
    {
        //disale button
        //[self enableGrapplingHookButton];
        [self enableKnifeButton];
    }
    else
    {
        [self disableKnifeButton:false];
        [self disableGrapplingButton];
    }
}
//----------------------------------------------------------------------------------------------------
//-------------------------------------------------COLISIONS------------------------------------------
//----------------------------------------------------------------------------------------------------
-(void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair knife:(CCNode *)nodeA enemy:(CCNode *)nodeB
{
    //matar inimigo
    [[_physicsNode space] addPostStepBlock:^{
        [self killNode:nodeB];
    } key:nodeB];
    
    //log
    numberOfSucessKnifes6++;
    
    numberOfEnemies6--;
    if (numberOfEnemies6 == 0){
        //[self nextLevel];
        //log
        timeInterval6 = fabs([start6 timeIntervalSinceNow]);
        [self writeToLog6];
        layerEnd.opacity = 1.0f;
        textEnd.opacity = 1.0f;
        resetButton.visible = true;
        nextButton.visible = true;
        
        [[CCDirector sharedDirector] pause];
    }
}

//MORRER
-(void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair ninja:(CCNode *)nodeA ground:(CCNode *)nodeB
{
    //log
    numberOfDeaths6++;
    logUtils6.totalDeaths++;
    
    retryButton.visible = true;
    startAgainButton.visible = true;
    retryButton.enabled = true;
    startAgainButton.enabled = true;
    
    textMomentum.opacity = 1.0f;
    overlayLayer2.opacity = 0.9f;
    
    [[CCDirector sharedDirector] pause];
}

-(void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair ninja:(CCNode *)nodeA enemy:(CCNode *)nodeB
{
    
    //log
    numberOfJumps6 ++;
    
    retryLocation6 = nodeB.positionInPoints;
    CGPoint mult = ccp(1,1.5);
    retryLocation6 = ccpCompMult(retryLocation6, mult);
    asRetryLocation6 = true;
    
    [self killNode:nodeB];// matar inimigo
    
    //ninja pode saltar
    [ninja setCanJump:true];
    [ninja verticalJump];
    
    numberOfEnemies6--;
    if (numberOfEnemies6 == 0)
    {
        //log
        timeInterval6 = fabs([start6 timeIntervalSinceNow]);
        [self writeToLog6];
        
        //salvar tries
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d", numberTries6] forKey:@"triesLevel6"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        //acabei nivel
        [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"endedLevel6"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        //desbloquei proximo
        [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"unblockedLevel7"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        CCLOG(@"tries %d", numberTries6);
        
        //[self nextLevel];
        
        layerEnd.opacity = 1.0f;
        textEnd.opacity = 1.0f;
        resetButton.visible = true;
        nextButton.visible = true;
        
        [[CCDirector sharedDirector] pause];
        
        if(numberTries6 == 0)
        {
            star1.opacity = 1.0f;
            star2.opacity = 1.0f;
            star3.opacity = 1.0f;
        }
        else if(numberTries6 >= 1 && numberTries6 <=4)
        {
            star1.opacity = 1.0f;
            star2.opacity = 1.0f;
            star3.opacity = 0.0f;
        }
        else if(numberTries6 >= 5)
        {
            star1.opacity = 1.0f;
            star2.opacity = 0.0f;
            star3.opacity = 0.0f;
        }
    }
    
    // CCLOG(@"açao ninja %d", [ninja action]);
    [ninja setAction:-1];
    
    [self schedule:@selector(reduceCircle) interval:0.05 repeat:20 delay:0];
}

- (void) writeToLog6{
    NSArray *paths = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0]stringByAppendingPathComponent:@"currentLog.txt"];
    NSString *finalFilePath = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    
    NSString* deathNumberString = @"\n\nNumber of deaths in Level 6 = ";
    
    deathNumberString = [deathNumberString stringByAppendingString:[NSString stringWithFormat:@"%d", numberOfDeaths6]];
    [LogUtils writeAtEndOfFile:deathNumberString withFilePath:finalFilePath];
    
    NSString* numberOfJumpsString = @"\nNumber of jumps in Level 6 = ";
    
    numberOfJumpsString = [numberOfJumpsString stringByAppendingString:[NSString stringWithFormat:@"%d", numberOfJumps6]];
    [LogUtils writeAtEndOfFile:numberOfJumpsString withFilePath:finalFilePath];
    
    NSString* numberOfTouchesString = @"\nNumber of touches in Level 6 = ";
    
    numberOfTouchesString = [numberOfTouchesString stringByAppendingString:[NSString stringWithFormat:@"%d", numberOfTouches6]];
    [LogUtils writeAtEndOfFile:numberOfTouchesString withFilePath:finalFilePath];
    
    NSString* numberOfRetriesString = @"\nNumber of retries in Level 6 = ";
    
    numberOfRetriesString = [numberOfRetriesString stringByAppendingString:[NSString stringWithFormat:@"%d", numberOfRetriesPerLevel6]];
    [LogUtils writeAtEndOfFile:numberOfRetriesString withFilePath:finalFilePath];
    
    NSString* numberOfGrapplingString = @"\nNumber of Grappling Hook used in Level 6 = ";
    
    numberOfGrapplingString = [numberOfGrapplingString stringByAppendingString:[NSString stringWithFormat:@"%d", numberOfGrapplingHook6]];
    [LogUtils writeAtEndOfFile:numberOfGrapplingString withFilePath:finalFilePath];
    
    NSString* numberOfWeaponsString = @"\nNumber of Knifes used in Level 6 = ";
    
    numberOfWeaponsString = [numberOfWeaponsString stringByAppendingString:[NSString stringWithFormat:@"%d", numberOfWeaponsFired6]];
    [LogUtils writeAtEndOfFile:numberOfWeaponsString withFilePath:finalFilePath];
    
    NSString* timeString = @"\nTime to complete Level 6 in seconds = ";
    
    timeString = [timeString stringByAppendingString:[NSString stringWithFormat:@"%f", timeInterval6]];
    [LogUtils writeAtEndOfFile:timeString withFilePath:finalFilePath];
    
    NSString* sucessKnifesString = @"\nSucess in using knife to kill enemy ";
    
    sucessKnifesString = [sucessKnifesString stringByAppendingString:[NSString stringWithFormat:@"%d", numberOfSucessKnifes6]];
    sucessKnifesString = [sucessKnifesString stringByAppendingString:@" out of "];
    
    sucessKnifesString = [sucessKnifesString stringByAppendingString:[NSString stringWithFormat:@"%d", numberOfWeaponsFired6]];
    
    NSString* sucessGrapplingsString = @"\nSucess in using grappling to kill enemy ";
    
    sucessGrapplingsString = [sucessGrapplingsString stringByAppendingString:[NSString stringWithFormat:@"%d", numberOfSucessGrappling6]];
    sucessGrapplingsString = [sucessGrapplingsString stringByAppendingString:@" out of "];
    
    sucessGrapplingsString = [sucessGrapplingsString stringByAppendingString:[NSString stringWithFormat:@"%d", numberOfGrapplingHook6]];
    
    [LogUtils writeAtEndOfFile:sucessGrapplingsString withFilePath:finalFilePath];
}

//matar inimigo
//matar water end
- (void)killNode:(CCNode *)enemy {
    [enemy removeFromParent];
}
//----------------------------------------------------------------------------------------------------
//---------------------------------------------SLOW MOTION--------------------------------------------
//----------------------------------------------------------------------------------------------------
-(void)setupSlowMotion
{
    if(enableSlowMotion6)
    {
        [[[CCDirector sharedDirector] scheduler] setTimeScale:slowVelocity6];
        ninjaCircle.opacity = ninjaCircleOpacity6;
        overlayLayer.opacity = overlayLayerOpacity6;
    } else {
        [[[CCDirector sharedDirector] scheduler] setTimeScale:1.0f];
        ninjaCircle.opacity = 0.0f;
        overlayLayer.opacity = 0.0f;
        
    }
    ninjaCircle.position = [_contentNode convertToWorldSpace:ninja.position];
}

-(void) reduceCircle
{
    static int i=0;
    
    // CCLOG(@"dentro %d", i);
    
    
    
    if((i%20 == 0 && i!=0)
       || [ninja action] == IDDLE
       )
    {
        // CCLOG(@"reset circle");
        
        //parar tempo
        i = 0;
        [self resetCircle];
        
    }
    else
    {
        ninjaCircle.scaleX -= 0.05f;
        ninjaCircle.scaleY -= 0.05f;
        
        i++;
        
        enableSlowMotion6 = true;
    }
}

-(void) resetCircle
{
    //reset tamanho circulo volta ninja
    ninjaCircle.scaleX = 1.0f;
    ninjaCircle.scaleY = 1.0f;
    
    //parar slow motion
    enableSlowMotion6 = false;
    
    [self unschedule:_cmd];
}


//SAIR ECRA
-(void) outsideRoom
{
    if(ninja.position.x > [self contentSize].width || ninja.position.y > [self contentSize].height)
    {
        //CCLOG(@"ninja fora bounds");
        
        retryButton.visible = true;
        startAgainButton.visible = true;
        retryButton.enabled = true;
        startAgainButton.enabled = true;
        
        [[CCDirector sharedDirector] pause];
    }
}



@end