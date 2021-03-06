//
//  Level2.m
//  NinjaMomentum
//
//  Created by andre on 18/05/16.
//  Copyright © 2016 Apportable. All rights reserved.
//

#import "Level2.h"
#import "Ninja.h"
#import "CCDirector_Private.h"
#import "CCPhysics+ObjectiveChipmunk.h"
#import "LogUtils.h"
#import "AudioUtils.h"

//auxiliares slowmotion
bool enableSlowMotion2 = false;
float slowVelocity2 = 0.3f;
float ninjaCircleOpacity2 = 0.15f;
float overlayLayerOpacity2 = 0.3f;
int radiusCircle2 = 0;

bool asRetryLocation2 = false;
int numberOfEnemies2 = 5;

//auxiliares mira
float angleXX2 = 0.f, angleYY2 = 0.f;
float scaleAim2 = 5.0f;

CGPoint retryLocation2;
bool isPaused2 = false;

//TRIES
int numberTries2 = 0;

//TRIES
int numberTries = 0;


//LOG VARIABLES
int numberOfDeaths2 = 0;
int numberOfJumps2 = 0;
int numberOfWeaponsFired2 = 0;
int numberOfGrapplingHook2 = 0;
int numberOfTouches2 = 0;
int numberOfRetriesPerLevel2 = 0;
int numberOfSucessKnifes2 = 0;

NSDate *start2;
NSTimeInterval timeInterval2;
LogUtils *logUtils2;

AudioUtils *audioUtils;

@implementation Level2
{
    //background
    CCSprite *_1plane;
    CCSprite *_2plane;
    CCSprite *_3plane;
    CCSprite *_1plane2;
    CCSprite *_2plane2;
    CCSprite *_3plane2;
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
    
    //pause
    CCSprite * pauseLayer;
    CCButton * pause;
    CCButton * pause_resume;
    CCButton * pause_menu;
    CCButton * pause_reset;
}

// default config
- (void)didLoadFromCCB
{
    audioUtils = [AudioUtils sharedManager];
    
    [AudioUtils playLevel2Bg];
    
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
    
    start2 = [NSDate date];
    logUtils2 = [LogUtils sharedManager];
    
    pause_resume. visible = false;
    pause_menu. visible = false;
    pause_reset. visible = false;
    pauseLayer.visible = false;
}

- (void) update:(CCTime)delta
{
    //camera
    [self camera:ninja];
    
    //slow motion
    [self setupSlowMotion];
    
    //reposicionar mira ninja
    [ninja positionAimAt:ccp(0, 0)];
    
    //[self outsideRoom];
    //[_1plane runAction:[CCActionMoveBy actionWithDuration:delta position: ccp(-0.04f*ninja.physicsBody.velocity.x,0)]];
    [_2plane runAction:[CCActionMoveBy actionWithDuration:delta position: ccp(-0.02f*ninja.physicsBody.velocity.x,0)]];
    [_3plane runAction:[CCActionMoveBy actionWithDuration:delta position: ccp(-0.008f*ninja.physicsBody.velocity.x,0)]];
    //[_1plane2 runAction:[CCActionMoveBy actionWithDuration:delta position: ccp(-0.05f*ninja.physicsBody.velocity.x,0)]];
    [_2plane2 runAction:[CCActionMoveBy actionWithDuration:delta position: ccp(-0.02f*ninja.physicsBody.velocity.x,0)]];
    [_3plane2 runAction:[CCActionMoveBy actionWithDuration:delta position: ccp(-0.008f*ninja.physicsBody.velocity.x,0)]];
}

//----------------------------------------------------------------------------------------------------
//-------------------------------------------------TOUCH----------------------------------------------
//----------------------------------------------------------------------------------------------------

// called on every touch in this scene

- (void)touchBegan:(CCTouch *)touch withEvent:(CCTouchEvent *)event
{
    CGPoint touchLocation = [touch locationInNode:_contentNode];
    
    //log
    numberOfTouches2++;
    
    // NINJA
    if (CGRectContainsPoint([ninja boundingBox], touchLocation))
    {
        //acao default = salto
        if ([ninja action] == IDDLE && [ninja canJump]) {
            [ninja setAction:JUMP];
        }
        
        //activar mira
        if(([ninja action] != IDDLE && [ninja canJump]) || ([ninja canShoot])){
            [ninja enableAim:true];
            
            if(![ninja initialJump]){
                [AudioUtils stopEffects];
                [AudioUtils playSlowMotion];
                [self schedule:@selector(reduceCircle) interval:0.05 repeat:20 delay:0];
            }
        }
    }
    
    /*
     //vou ver se cliquei dentro GH
     else if(CGRectContainsPoint([_platformGH boundingBox],touchLocation))
     {
     if([ninja action] == GRAPPLING)
     {
     
     joint = [CCPhysicsJoint connectedDistanceJointWithBodyA:ninja.physicsBody
     bodyB:_platformGH.physicsBody
     anchorA:ninja.anchorPointInPoints
     anchorB:_platformGH.anchorPointInPoints];
     
     drawGrapplingHook = true;
     [self unschedule:@selector(reduceCircle)];
     [self resetCircle];
     }
     }
     
     //cliquei FORA
     else if([ninja action] == GRAPPLING)
     {
     drawGrapplingHook = false;
     [joint invalidate];
     joint = nil;
     [self enableGrapplingHookButton];
     [ninja setAction:IDDLE];
     }
     */
    
    else
    {
        [ninja setAction:IDDLE];
        [AudioUtils stopEffects];

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
        
        angleYY2 = clampf(touchLocation.y - (ninja.boundingBox.origin.y + ninja.boundingBox.size.height/2), -80, 80);
        angleXX2 = clampf(touchLocation.x - (ninja.boundingBox.origin.x + ninja.boundingBox.size.width/2), -10, 10);
        
        //actualizar angulo e escala mira
        [ninja updateAim:angleYY2 withScale:-angleXX2/scaleAim2];
    }
}

- (void) touchEnded:(CCTouch *)touch withEvent:(CCTouchEvent *)event
{
    //DESACTIVAR BUTOES / TEMPO
    if([ninja action] == KNIFE){
        [self disableKnifeButton:YES];
        //log
        numberOfWeaponsFired2++;
        [AudioUtils playThrowKnife];
    }
    
    //else if([ninja action] == GRAPPLING)
    //  [self disableGrapplingButton];
    
    //fazer acao ninja
    [ninja action:_physicsNode withAngleX:angleXX2 withAngleY:angleYY2];
    
    //apagar mira
    [ninja enableAim:false];
    [AudioUtils stopEffects];

    [self unschedule:@selector(reduceCircle)];
    [self resetCircle];
    
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
        [self unschedule:@selector(reduceCircle)];
        [self resetCircle];
    }
    
    [AudioUtils stopEffects];
    [AudioUtils playSlowMotion];
    
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
    //log
    numberOfRetriesPerLevel2 ++;
    logUtils2.totalRetries ++;

    retryButton.visible = false;
    startAgainButton.visible = false;
    startAgainButton.enabled = false;
    retryButton.enabled = false;
    
    pause.visible = true;
    //grapplingHookButton.visible = true;
    //knifeButton.visible = true;
    
    if(asRetryLocation2)
    {
        [AudioUtils playLevel2Bg];
        ninja.positionInPoints = retryLocation2;
        [ninja setCanJump:true];
        [ninja verticalJump];
    }
    else{
        [self selectReset];
    }
    
    
    numberTries2++;
    //[[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d", numberTries] forKey:@"triesLevel1"];
    //[[NSUserDefaults standardUserDefaults] synchronize];
    
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
    [AudioUtils stopEffects];
    [AudioUtils playSlowMotion];

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
    
    CCScene *gameplayScene = [CCBReader loadAsScene:@"Levels/Level2"];
    [[CCDirector sharedDirector] replaceScene:gameplayScene];
    
    //reset variaveis
    enableSlowMotion2=false;
    angleXX2 = 0.f, angleYY2 = 0.f;
    scaleAim2 = 5.0f;
    slowVelocity2 = 0.3f;
    ninjaCircleOpacity2 = 0.15f;
    overlayLayerOpacity2 = 0.3f;
    numberOfEnemies2 = 5;
    asRetryLocation2 = false;
    //drawGrapplingHook = false;
    //enteredWater = false;
    //collidedWithWaterEnd = false;
    
    numberTries2=0;
    
    //[[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d", numberTries] forKey:@"triesLevel1"];
    //[[NSUserDefaults standardUserDefaults] synchronize];
    
    overlayLayer2.opacity = 0.0f;
    textMomentum.opacity = 0.0f;
    
}
-(void) nextLevel
{
    CCScene *gameplayScene = [CCBReader loadAsScene:@"Levels/Level3"];
    [[CCDirector sharedDirector] replaceScene:gameplayScene];
    
    //reset variaveis
    enableSlowMotion2=false;
    angleXX2 = 0.f, angleYY2 = 0.f;
    scaleAim2 = 5.0f;
    slowVelocity2 = 0.3f;
    ninjaCircleOpacity2 = 0.15f;
    overlayLayerOpacity2 = 0.3f;
    numberOfEnemies2 = 5;
    asRetryLocation2 = false;
    
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
    [AudioUtils playKnifeStab];

    //matar inimigo
    [[_physicsNode space] addPostStepBlock:^{
        [self killNode:nodeB];
    } key:nodeB];
    
    //log
    numberOfSucessKnifes2++;
    
    numberOfEnemies2--;
    if (numberOfEnemies2 == 0){
        //[self nextLevel];
        //log
        [AudioUtils stopEverything];
        [AudioUtils playLevelCompleteSoundEffect];

        timeInterval2 = fabs([start2 timeIntervalSinceNow]);
        [self writeToLog2];

        layerEnd.opacity = 1.0f;
        textEnd.opacity = 1.0f;
        resetButton.visible = true;
        nextButton.visible = true;
        
        pause.visible = false;
        grapplingHookButton.visible = false;
        knifeButton.visible = false;
        
        [[CCDirector sharedDirector] pause];
    }
}

//MORRER
-(void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair ninja:(CCNode *)nodeA ground:(CCNode *)nodeB
{
    
    [AudioUtils stopEverything];
    [AudioUtils playDeathSoundEffect];
    
    //log
    numberOfDeaths2++;
    logUtils2.totalDeaths++;
    
    retryButton.visible = true;
    startAgainButton.visible = true;
    retryButton.enabled = true;
    startAgainButton.enabled = true;
    
    textMomentum.opacity = 1.0f;
    overlayLayer2.opacity = 0.9f;
    
    pause.visible = false;
    grapplingHookButton.visible = false;
    knifeButton.visible = false;
    
    [[CCDirector sharedDirector] pause];
}

-(void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair ninja:(CCNode *)nodeA enemy:(CCNode *)nodeB
{

    [AudioUtils stopEffects];
    //[AudioUtils playKnifeStab];
    
    numberOfJumps2 ++;

        retryLocation2 = nodeB.positionInPoints;
        CGPoint mult = ccp(1,1.2);
        retryLocation2 = ccpCompMult(retryLocation2, mult);
        asRetryLocation2 = true;
        
        [self killNode:nodeB];// matar inimigo
        
        //ninja pode saltar
        [ninja setCanJump:true];
        [ninja verticalJump];
        numberOfEnemies2--;
        if (numberOfEnemies2 == 0)
        {
            pause.visible = false;
            grapplingHookButton.visible = false;
            knifeButton.visible = false;
            
            [AudioUtils stopEverything];
            [AudioUtils playLevelCompleteSoundEffect];
            //log
            timeInterval2 = fabs([start2 timeIntervalSinceNow]);
            [self writeToLog2];

            //salvar tries
            [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d", numberTries2] forKey:@"triesLevel2"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            //acabei nivel
            [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"endedLevel2"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            //desbloquei proximo
            [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"unblockedLevel3"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            
            //[self nextLevel];
            
            layerEnd.opacity = 1.0f;
            textEnd.opacity = 1.0f;
            resetButton.visible = true;
            nextButton.visible = true;
            
            [[CCDirector sharedDirector] pause];
            
            if(numberTries2 == 0)
            {
                star1.opacity = 1.0f;
                star2.opacity = 1.0f;
                star3.opacity = 1.0f;
            }
            else if(numberTries2 >= 1 && numberTries2 <=4)
            {
                star1.opacity = 1.0f;
                star2.opacity = 1.0f;
                star3.opacity = 0.0f;
            }
            else if(numberTries2 >= 5)
            {
                star1.opacity = 1.0f;
                star2.opacity = 0.0f;
                star3.opacity = 0.0f;
            }
        }
    
    [NSTimer scheduledTimerWithTimeInterval:0.2
                                     target:self
                                   selector:@selector(playSlowMotion)
                                   userInfo:nil
                                    repeats:NO];

    
        [self schedule:@selector(reduceCircle) interval:0.05 repeat:20 delay:0];
    
}
- (void) playSlowMotion{
    [AudioUtils playSlowMotion];
}
//matar inimigo
//matar water end
- (void)killNode:(CCNode *)enemy {
    [enemy removeFromParent];
}

- (void) writeToLog2{
    NSArray *paths = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0]stringByAppendingPathComponent:@"currentLog.txt"];
    NSString *finalFilePath = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    
    NSString* deathNumberString = @"\n\nNumber of deaths in Level 2 = ";
    
    deathNumberString = [deathNumberString stringByAppendingString:[NSString stringWithFormat:@"%d", numberOfDeaths2]];
    [LogUtils writeAtEndOfFile:deathNumberString withFilePath:finalFilePath];
    
    NSString* numberOfJumpsString = @"\nNumber of jumps in Level 2 = ";
    
    numberOfJumpsString = [numberOfJumpsString stringByAppendingString:[NSString stringWithFormat:@"%d", numberOfJumps2]];
    [LogUtils writeAtEndOfFile:numberOfJumpsString withFilePath:finalFilePath];
    
    NSString* numberOfTouchesString = @"\nNumber of touches in Level 2 = ";
    
    numberOfTouchesString = [numberOfTouchesString stringByAppendingString:[NSString stringWithFormat:@"%d", numberOfTouches2]];
    [LogUtils writeAtEndOfFile:numberOfTouchesString withFilePath:finalFilePath];
    
    NSString* numberOfRetriesString = @"\nNumber of retries in Level 2 = ";
    
    numberOfRetriesString = [numberOfRetriesString stringByAppendingString:[NSString stringWithFormat:@"%d", numberOfRetriesPerLevel2]];
    [LogUtils writeAtEndOfFile:numberOfRetriesString withFilePath:finalFilePath];
    
    NSString* numberOfGrapplingString = @"\nNumber of Grappling Hook used in Level 2 = 0";
    [LogUtils writeAtEndOfFile:numberOfGrapplingString withFilePath:finalFilePath];
    
    NSString* numberOfWeaponsString = @"\nNumber of Knifes used in Level 2 = ";
    
    numberOfWeaponsString = [numberOfWeaponsString stringByAppendingString:[NSString stringWithFormat:@"%d", numberOfWeaponsFired2]];
    [LogUtils writeAtEndOfFile:numberOfWeaponsString withFilePath:finalFilePath];
    
    NSString* timeString = @"\nTime to complete Level 2 in seconds = ";
    
    timeString = [timeString stringByAppendingString:[NSString stringWithFormat:@"%f", timeInterval2]];
    [LogUtils writeAtEndOfFile:timeString withFilePath:finalFilePath];
    
    NSString* sucessKnifesString = @"\nSucess in using knife to kill enemy ";
    
    sucessKnifesString = [sucessKnifesString stringByAppendingString:[NSString stringWithFormat:@"%d", numberOfSucessKnifes2]];
    sucessKnifesString = [sucessKnifesString stringByAppendingString:@" out of "];
    
    sucessKnifesString = [sucessKnifesString stringByAppendingString:[NSString stringWithFormat:@"%d", numberOfWeaponsFired2]];
    
    [LogUtils writeAtEndOfFile:sucessKnifesString withFilePath:finalFilePath];    
}


//----------------------------------------------------------------------------------------------------
//---------------------------------------------SLOW MOTION--------------------------------------------
//----------------------------------------------------------------------------------------------------
-(void)setupSlowMotion
{
    if(enableSlowMotion2)
    {
        [[[CCDirector sharedDirector] scheduler] setTimeScale:slowVelocity2];
        ninjaCircle.opacity = ninjaCircleOpacity2;
        overlayLayer.opacity = overlayLayerOpacity2;
    } else {
        [[[CCDirector sharedDirector] scheduler] setTimeScale:1.0f];
        ninjaCircle.opacity = 0.0f;
        overlayLayer.opacity = 0.0f;
        radiusCircle2 = 0;
        
    }
    ninjaCircle.position = [_contentNode convertToWorldSpace:ninja.position];
}

-(void) reduceCircle
{
    if((radiusCircle2 %20 == 0 && radiusCircle2!=0) || [ninja action] == IDDLE)
    {
        //parar tempo
        radiusCircle2 = 0;
        [self resetCircle];
        
    }
    else
    {
        ninjaCircle.scaleX -= 0.05f;
        ninjaCircle.scaleY -= 0.05f;
        
        radiusCircle2++;
        
        enableSlowMotion2 = true;
    }
}

-(void) resetCircle
{
    //reset tamanho circulo volta ninja
    ninjaCircle.scaleX = 1.0f;
    ninjaCircle.scaleY = 1.0f;
    
    //parar slow motion
    enableSlowMotion2 = false;
    
    radiusCircle2 = 0;
    
    [self unschedule:_cmd];
}


//SAIR ECRA
-(void) outsideRoom
{
    if(ninja.position.x > [self contentSize].width || ninja.position.y > [self contentSize].height)
    {
        retryButton.visible = true;
        startAgainButton.visible = true;
        retryButton.enabled = true;
        startAgainButton.enabled = true;
        
        [[CCDirector sharedDirector] pause];
    }
}

//----------------------------------------------------------------------------------------------------
//---------------------------------------------PAUSE--------------------------------------------------
//----------------------------------------------------------------------------------------------------
-(void)pause_resume
{
    [[CCDirector sharedDirector] resume];
    overlayLayer.opacity = 0;
    pauseLayer.visible = false;
    pause.visible = true;
    
    pause_resume. visible = false;
    pause_menu. visible = false;
    pause_reset. visible = false;
    
    [self enableKnifeButton];
    [self enableGrapplingHookButton];
}

-(void)pause_reset
{
    [self selectReset];
}

-(void)pause_menu
{
    [self pause_resume];
    [self selectReset];
    
    CCScene *gameplayScene = [CCBReader loadAsScene:@"MainScene"];
    [[CCDirector sharedDirector] replaceScene:gameplayScene];
}

- (void) pause
{
    [[CCDirector sharedDirector] pause];
    overlayLayer.opacity = 0.5f;
    pauseLayer.visible = true;
    pause.visible = false;
    
    pause_resume. visible = true;
    pause_menu. visible = true;
    pause_reset. visible = true;
    
    [self disableGrapplingButton];
    [self disableKnifeButton:false];
}


@end