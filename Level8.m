//
//  Level8.m
//  NinjaMomentum
//
//  Created by andre on 21/05/16.
//  Copyright © 2016 Apportable. All rights reserved.
//

#import "Level8.h"
#import "Ninja.h"
#import "CCDirector_Private.h"
#import "CCPhysics+ObjectiveChipmunk.h"
#import "LogUtils.h"
#import "AudioUtils.h"

//auxiliares slowmotion
bool enableSlowMotion8 = false;
float slowVelocity8 = 0.3f;
float ninjaCircleOpacity8 = 0.15f;
float overlayLayerOpacity8 = 0.3f;
int radiusCirle8 = 0;

bool asRetryLocation8 = false;
int numberOfEnemies8 = 19;

//auxiliares mira
float angleXX8 = 0.f, angleYY8 = 0.f;
float scaleAim8 = 5.0f;

CGPoint retryLocation8;
bool isPaused8 = false;

//TRIES
int numberTries8 = 0;

//auxiliares grappling hook
bool drawGrapplingHook8 = false;
int minDistanceToUseGrappling8 = 250;
int touchedPlatform8;

//LOG VARIABLES
int numberOfDeaths8 = 0;
int numberOfJumps8 = 0;
int numberOfWeaponsFired8 = 0;
int numberOfGrapplingHook8 = 0;
int numberOfTouches8 = 0;
int numberOfRetriesPerLevel8 = 0;
int numberOfSucessKnifes8 = 0;
bool jumpingFromGrappling8 = false;
int numberOfSucessGrappling8 = 0;

NSDate *start8;
NSTimeInterval timeInterval8;
LogUtils *logUtils8;

AudioUtils *audioUtils;

@implementation Level8
{
    CCSprite *_1plane;
    CCSprite *_1plane2;
    CCSprite *_1plane3;
    CCSprite *_1plane4;
    CCSprite *_2plane;
    CCSprite *_2plane2;
    CCSprite *_2plane3;
    CCSprite *_2plane4;
    CCSprite *_3plane;
    CCSprite *_3plane2;
    CCSprite *_3plane3;
    CCSprite *_3plane4;
    CCSprite *_sky;
    CCSprite *_sky2;
    CCSprite *_sky3;
    CCSprite *_sky4;
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
    
    //graping hook
    CCNode *_platformGH1;
    CCSprite * target1;
    CCNode *_platformGH2;
    CCSprite * target2;
    CCNode *_platformGH3;
    CCSprite * target3;
    CCPhysicsJoint *joint;
    CCDrawNode *myDrawNode;
    CCNode *_touchedPlatform1;
    CCNode *_touchedPlatform2;
    CCNode *_touchedPlatform3;

    
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
    
    [AudioUtils playLevel8Bg];
    
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
    start8 = [NSDate date];
    logUtils8 = [LogUtils sharedManager];
    
    //corda
    myDrawNode = [CCDrawNode node];
    [self addChild: myDrawNode];
    
    //pause
    pause_resume. visible = false;
    pause_menu. visible = false;
    pause_reset. visible = false;
    
    pauseLayer.visible = false;
    
    target1.visible = false;
    target2.visible = false;
    target3.visible = false;
}

- (void) update:(CCTime)delta
{
    //camera
    [self camera:ninja];
    
    //slow motion
    [self setupSlowMotion];
    
    //reposicionar mira ninja
    [ninja positionAimAt:ccp(0, 0)];
    
   // [self outsideRoom];
    
    
    if(ccpDistance(ninja.positionInPoints, _platformGH1.positionInPoints) < minDistanceToUseGrappling8
       || ccpDistance(ninja.positionInPoints, _platformGH2.positionInPoints) < minDistanceToUseGrappling8
       || ccpDistance(ninja.positionInPoints, _platformGH3.positionInPoints) < minDistanceToUseGrappling8
       )
    {
        [self enableGrapplingHookButton];
    }
    else
    {
        [self disableGrapplingButton];
    }
    
    [myDrawNode clear];

     if (drawGrapplingHook8)
     {
        if(touchedPlatform8 == 1)
        {
            [myDrawNode drawSegmentFrom:[_contentNode convertToWorldSpace:ninja.positionInPoints] to:[_contentNode convertToWorldSpace:_platformGH1.positionInPoints] radius:1.0f color:[CCColor colorWithRed:0 green:0 blue:0]];
            target1.visible = false;
            target2.visible = false;
            target3.visible = false;
        }
         
        else if(touchedPlatform8 == 2)
        {
            
        [myDrawNode drawSegmentFrom:[_contentNode convertToWorldSpace:ninja.positionInPoints] to:[_contentNode convertToWorldSpace:_platformGH2.positionInPoints] radius:1.0f color:[CCColor colorWithRed:0 green:0 blue:0]];
            target1.visible = false;
            target2.visible = false;
            target3.visible = false;
            
     
        }
         
        else if(touchedPlatform8 == 3)
        {
        [myDrawNode drawSegmentFrom:[_contentNode convertToWorldSpace:ninja.positionInPoints] to:[_contentNode convertToWorldSpace:_platformGH3.positionInPoints] radius:1.0f color:[CCColor colorWithRed:0 green:0 blue:0]];
            target1.visible = false;
            target2.visible = false;
            target3.visible = false;
     
        }
         
     }
    
    
    if([ninja action] == GRAPPLING)
    {
        [self disableGrapplingButton];
        [self disableKnifeButtonWithTimer:true];
    }
    [_1plane runAction:[CCActionMoveBy actionWithDuration:delta position: ccp(-0.04f*ninja.physicsBody.velocity.x,0)]];
    [_1plane2 runAction:[CCActionMoveBy actionWithDuration:delta position: ccp(-0.04f*ninja.physicsBody.velocity.x,0)]];
    [_1plane3 runAction:[CCActionMoveBy actionWithDuration:delta position: ccp(-0.04f*ninja.physicsBody.velocity.x,0)]];
    [_1plane4 runAction:[CCActionMoveBy actionWithDuration:delta position: ccp(-0.04f*ninja.physicsBody.velocity.x,0)]];
    [_2plane runAction:[CCActionMoveBy actionWithDuration:delta position: ccp(-0.02f*ninja.physicsBody.velocity.x,0)]];
    [_2plane2 runAction:[CCActionMoveBy actionWithDuration:delta position: ccp(-0.02f*ninja.physicsBody.velocity.x,0)]];
    [_2plane3 runAction:[CCActionMoveBy actionWithDuration:delta position: ccp(-0.02f*ninja.physicsBody.velocity.x,0)]];
    [_2plane4 runAction:[CCActionMoveBy actionWithDuration:delta position: ccp(-0.02f*ninja.physicsBody.velocity.x,0)]];
    [_3plane runAction:[CCActionMoveBy actionWithDuration:delta position: ccp(-0.008f*ninja.physicsBody.velocity.x,0)]];
    [_3plane2 runAction:[CCActionMoveBy actionWithDuration:delta position: ccp(-0.008f*ninja.physicsBody.velocity.x,0)]];
    [_3plane3 runAction:[CCActionMoveBy actionWithDuration:delta position: ccp(-0.008f*ninja.physicsBody.velocity.x,0)]];
    [_3plane4 runAction:[CCActionMoveBy actionWithDuration:delta position: ccp(-0.008f*ninja.physicsBody.velocity.x,0)]];
    
    
    [_sky runAction:[CCActionMoveBy actionWithDuration:delta position: ccp(-0.005f*ninja.physicsBody.velocity.x,0)]];
    [_sky2 runAction:[CCActionMoveBy actionWithDuration:delta position: ccp(-0.005f*ninja.physicsBody.velocity.x,0)]];
    [_sky3 runAction:[CCActionMoveBy actionWithDuration:delta position: ccp(-0.005f*ninja.physicsBody.velocity.x,0)]];
    [_sky4 runAction:[CCActionMoveBy actionWithDuration:delta position: ccp(-0.005f*ninja.physicsBody.velocity.x,0)]];
}

//----------------------------------------------------------------------------------------------------
//-------------------------------------------------TOUCH----------------------------------------------
//----------------------------------------------------------------------------------------------------

// called on every touch in this scene

- (void)touchBegan:(CCTouch *)touch withEvent:(CCTouchEvent *)event
{
    CGPoint touchLocation = [touch locationInNode:_contentNode];
    //log
    numberOfTouches8++;
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
            
            if(![ninja initialJump]){
                [AudioUtils stopEffects];
                [AudioUtils playSlowMotion];
                [self schedule:@selector(reduceCircle) interval:0.05 repeat:20 delay:0];
            }
        }
    }
    
    //vou ver se cliquei dentro GH
    else if(CGRectContainsPoint([_touchedPlatform1 boundingBox],touchLocation))
    {
        
        if([ninja action] == GRAPPLING)
        {
            joint = [CCPhysicsJoint connectedDistanceJointWithBodyA:ninja.physicsBody
                                                              bodyB:_platformGH1.physicsBody
                                                            anchorA:ninja.anchorPointInPoints
                                                            anchorB:_platformGH1.anchorPointInPoints];
            //log
            numberOfGrapplingHook8++;
            
            drawGrapplingHook8 = true;
            [self unschedule:@selector(reduceCircle)];
            [self resetCircle];
            touchedPlatform8 = 1;
        }
    }
    else if(CGRectContainsPoint([_touchedPlatform2 boundingBox],touchLocation))
    {

        if([ninja action] == GRAPPLING)
        {
            joint = [CCPhysicsJoint connectedDistanceJointWithBodyA:ninja.physicsBody
                                                              bodyB:_platformGH2.physicsBody
                                                            anchorA:ninja.anchorPointInPoints
                                                            anchorB:_platformGH2.anchorPointInPoints];
            //log
            numberOfGrapplingHook8++;
            
            drawGrapplingHook8 = true;
            [self unschedule:@selector(reduceCircle)];
            [self resetCircle];
            touchedPlatform8 = 2;
        }
    }
    else if(CGRectContainsPoint([_touchedPlatform3 boundingBox],touchLocation))
    {

        if([ninja action] == GRAPPLING)
        {
            joint = [CCPhysicsJoint connectedDistanceJointWithBodyA:ninja.physicsBody
                                                              bodyB:_platformGH3.physicsBody
                                                            anchorA:ninja.anchorPointInPoints
                                                            anchorB:_platformGH3.anchorPointInPoints];
            //log
            numberOfGrapplingHook8++;
            
            drawGrapplingHook8 = true;
            [self unschedule:@selector(reduceCircle)];
            [self resetCircle];
            touchedPlatform8 = 3;
        }
    }
    
    else if([ninja action] == GRAPPLING)
    {
        //log
        jumpingFromGrappling8 = true;
        drawGrapplingHook8 = false;
        [joint invalidate];
        joint = nil;
        [self enableGrapplingHookButton];
        [ninja setAction:IDDLE];
        //[self unschedule:@selector(reduceCircle)];
        //[self resetCircle];
    }
    
    else
    {
        [AudioUtils stopEffects];
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
        
        angleYY8 = clampf(touchLocation.y - (ninja.boundingBox.origin.y + ninja.boundingBox.size.height/2), -80, 80);
        angleXX8 = clampf(touchLocation.x - (ninja.boundingBox.origin.x + ninja.boundingBox.size.width/2), -10, 10);
        
        //actualizar angulo e escala mira
        [ninja updateAim:angleYY8 withScale:-angleXX8/scaleAim8];
    }
}

- (void) touchEnded:(CCTouch *)touch withEvent:(CCTouchEvent *)event
{
    //DESACTIVAR BUTOES / TEMPO
    if([ninja action] == KNIFE){
        //log
        [AudioUtils playThrowKnife];
        
        numberOfWeaponsFired8++;
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
    [ninja action:_physicsNode withAngleX:angleXX8 withAngleY:angleYY8];
    
    //apagar mira
    [ninja enableAim:false];
    [AudioUtils stopEffects];
    
    
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
    
    if(!enableSlowMotion8){
        [AudioUtils stopEffects];
        [AudioUtils playSlowMotion];
        
        [self schedule:@selector(reduceCircle) interval:0.05 repeat:20 delay:0];
    }
    
    target1.visible = true;
    target2.visible = true;
    target3.visible = true;
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
    numberOfRetriesPerLevel8 ++;
    logUtils8.totalRetries ++;
    drawGrapplingHook8 = false;
    
    if(joint != nil){
        [joint invalidate];
        joint = nil;
    }
    pause.visible = true;
    grapplingHookButton.visible = true;
    knifeButton.visible = true;
    
    if(asRetryLocation8)
    {
        [AudioUtils playLevel1Bg];

        ninja.positionInPoints = retryLocation8;
        [ninja setCanJump:true];
        [ninja verticalJump];
    }
    else{
        [self selectReset];
    }
    
    
    numberTries8++;
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
    [AudioUtils stopEffects];
    [AudioUtils playSlowMotion];
    
    //fazer reset ao slow motion, caso tenho selecionado outra arma
    [ninja setAction:KNIFE];
    
    [self resetCircle];
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

- (void) disableKnifeButtonWithTimer:(BOOL)isTimer
{
    //disale button
    knifeButton.background.opacity = 0.2;
    knifeButton.label.opacity = 0.2;
    knifeButton.userInteractionEnabled = NO;
    
    if (isTimer) {
        //setup timer
        [self schedule:@selector(enableKnifeButton) interval:0.01];
    }
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
    
    
     if(joint != nil){
         [joint invalidate];
         joint = nil;
     
     }
     
    
    CCScene *gameplayScene = [CCBReader loadAsScene:@"Levels/Level8"];
    [[CCDirector sharedDirector] replaceScene:gameplayScene];
    [ninja setAction:IDDLE];
    
    //reset variaveis
    enableSlowMotion8=false;
    angleXX8 = 0.f, angleYY8 = 0.f;
    scaleAim8= 5.0f;
    slowVelocity8 = 0.3f;
    ninjaCircleOpacity8 = 0.15f;
    overlayLayerOpacity8 = 0.3f;
    numberOfEnemies8 = 19;
    asRetryLocation8 = false;
    drawGrapplingHook8 = false;
    target1.visible = false;
    target2.visible = false;
    target3.visible = false;
    //enteredWater = false;
    //collidedWithWaterEnd = false;
    
    numberTries8=0;
    
    //[[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d", numberTries] forKey:@"triesLevel1"];
    //[[NSUserDefaults standardUserDefaults] synchronize];
    
    overlayLayer2.opacity = 0.0f;
    textMomentum.opacity = 0.0f;
    
}
-(void) nextLevel
{
    CCScene *gameplayScene = [CCBReader loadAsScene:@"Victory"];
    [[CCDirector sharedDirector] replaceScene:gameplayScene];
    
    //reset variaveis
    enableSlowMotion8=false;
    angleXX8 = 0.f, angleYY8 = 0.f;
    scaleAim8 = 5.0f;
    slowVelocity8 = 0.3f;
    ninjaCircleOpacity8 = 0.15f;
    overlayLayerOpacity8 = 0.3f;
    numberOfEnemies8 = 19;
    asRetryLocation8 = false;
    
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
    
    //matar faca
    [[_physicsNode space] addPostStepBlock:^{
        [self killNode:nodeA];
    } key:nodeA];
    
    //log
    numberOfSucessKnifes8++;
    
    numberOfEnemies8--;
    if (numberOfEnemies8 == 0)
    {
        pause.visible = false;
        grapplingHookButton.visible = false;
        knifeButton.visible = false;
        
        [AudioUtils stopEverything];
        [AudioUtils playLevelCompleteSoundEffect];

        //log
        timeInterval8 = fabs([start8 timeIntervalSinceNow]);
        [self writeToLog8];
        
        //salvar tries
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d", numberTries8] forKey:@"triesLevel8"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        //acabei nivel
        [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"endedLevel8"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        //desbloquei proximo
        [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"unblockedLevel9"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        //[self nextLevel];
        
        layerEnd.opacity = 1.0f;
        textEnd.opacity = 1.0f;
        resetButton.visible = true;
        nextButton.visible = true;
        
        [[CCDirector sharedDirector] pause];
        
        if(numberTries8 == 0)
        {
            star1.opacity = 1.0f;
            star2.opacity = 1.0f;
            star3.opacity = 1.0f;
        }
        else if(numberTries8 >= 1 && numberTries8 <=4)
        {
            star1.opacity = 1.0f;
            star2.opacity = 1.0f;
            star3.opacity = 0.0f;
        }
        else if(numberTries8 >= 5)
        {
            star1.opacity = 1.0f;
            star2.opacity = 0.0f;
            star3.opacity = 0.0f;
        }
    }
}

//MORRER
-(void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair ninja:(CCNode *)nodeA ground:(CCNode *)nodeB
{
    
    [AudioUtils stopEverything];
    [AudioUtils playDeathSoundEffect];
    
    //log
    numberOfDeaths8++;
    logUtils8.totalDeaths++;
    
    retryButton.visible = true;
    startAgainButton.visible = true;
    retryButton.enabled = true;
    startAgainButton.enabled = true;
    
    pause.visible = false;
    grapplingHookButton.visible = false;
    knifeButton.visible = false;
    
    textMomentum.opacity = 1.0f;
    overlayLayer2.opacity = 0.9f;
    
    [[CCDirector sharedDirector] pause];
}

-(void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair ninja:(CCNode *)nodeA enemy:(CCNode *)nodeB
{
    [AudioUtils stopEffects];
    //[AudioUtils playKnifeStab];
    
    
    //log
    numberOfJumps8 ++;
    
    retryLocation8 = nodeB.positionInPoints;
    CGPoint mult = ccp(1,1.2);
    retryLocation8 = ccpCompMult(retryLocation8, mult);
    asRetryLocation8 = true;
    
    [self killNode:nodeB];// matar inimigo
    
    //ninja pode saltar
    [ninja setCanJump:true];
    [ninja verticalJump];
    
    numberOfEnemies8--;
    if (numberOfEnemies8 == 0)
    {
        
        pause.visible = false;
        grapplingHookButton.visible = false;
        knifeButton.visible = false;
        
        [AudioUtils stopEverything];
        [AudioUtils playLevelCompleteSoundEffect];

        //log
        timeInterval8 = fabs([start8 timeIntervalSinceNow]);
        [self writeToLog8];
        
        //salvar tries
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d", numberTries8] forKey:@"triesLevel8"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        //acabei nivel
        [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"endedLevel8"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        //desbloquei proximo
        [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"unblockedLevel9"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        //[self nextLevel];
        
        layerEnd.opacity = 1.0f;
        textEnd.opacity = 1.0f;
        resetButton.visible = true;
        nextButton.visible = true;
        
        [[CCDirector sharedDirector] pause];
        
        if(numberTries8 == 0)
        {
            star1.opacity = 1.0f;
            star2.opacity = 1.0f;
            star3.opacity = 1.0f;
        }
        else if(numberTries8 >= 1 && numberTries8 <=4)
        {
            star1.opacity = 1.0f;
            star2.opacity = 1.0f;
            star3.opacity = 0.0f;
        }
        else if(numberTries8 >= 5)
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
    
    // CCLOG(@"açao ninja %d", [ninja action]);
    [ninja setAction:-1];
    
    [self schedule:@selector(reduceCircle) interval:0.05 repeat:20 delay:0];
}

- (void) playSlowMotion{
    [AudioUtils playSlowMotion];
}

- (void) writeToLog8{
    NSArray *paths = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0]stringByAppendingPathComponent:@"currentLog.txt"];
    NSString *finalFilePath = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    
    NSString* deathNumberString = @"\n\nNumber of deaths in Level 8 = ";
    
    deathNumberString = [deathNumberString stringByAppendingString:[NSString stringWithFormat:@"%d", numberOfDeaths8]];
    [LogUtils writeAtEndOfFile:deathNumberString withFilePath:finalFilePath];
    
    NSString* numberOfJumpsString = @"\nNumber of jumps in Level 8 = ";
    
    numberOfJumpsString = [numberOfJumpsString stringByAppendingString:[NSString stringWithFormat:@"%d", numberOfJumps8]];
    [LogUtils writeAtEndOfFile:numberOfJumpsString withFilePath:finalFilePath];
    
    NSString* numberOfTouchesString = @"\nNumber of touches in Level 8 = ";
    
    numberOfTouchesString = [numberOfTouchesString stringByAppendingString:[NSString stringWithFormat:@"%d", numberOfTouches8]];
    [LogUtils writeAtEndOfFile:numberOfTouchesString withFilePath:finalFilePath];
    
    NSString* numberOfRetriesString = @"\nNumber of retries in Level 8 = ";
    
    numberOfRetriesString = [numberOfRetriesString stringByAppendingString:[NSString stringWithFormat:@"%d", numberOfRetriesPerLevel8]];
    [LogUtils writeAtEndOfFile:numberOfRetriesString withFilePath:finalFilePath];
    
    NSString* numberOfGrapplingString = @"\nNumber of Grappling Hook used in Level 8 = ";
    
    numberOfGrapplingString = [numberOfGrapplingString stringByAppendingString:[NSString stringWithFormat:@"%d", numberOfGrapplingHook8]];
    [LogUtils writeAtEndOfFile:numberOfGrapplingString withFilePath:finalFilePath];
    
    NSString* numberOfWeaponsString = @"\nNumber of Knifes used in Level 8 = ";
    
    numberOfWeaponsString = [numberOfWeaponsString stringByAppendingString:[NSString stringWithFormat:@"%d", numberOfWeaponsFired8]];
    [LogUtils writeAtEndOfFile:numberOfWeaponsString withFilePath:finalFilePath];
    
    NSString* timeString = @"\nTime to complete Level 8 in seconds = ";
    
    timeString = [timeString stringByAppendingString:[NSString stringWithFormat:@"%f", timeInterval8]];
    [LogUtils writeAtEndOfFile:timeString withFilePath:finalFilePath];
    
    NSString* sucessKnifesString = @"\nSucess in using knife to kill enemy ";
    
    sucessKnifesString = [sucessKnifesString stringByAppendingString:[NSString stringWithFormat:@"%d", numberOfSucessKnifes8]];
    sucessKnifesString = [sucessKnifesString stringByAppendingString:@" out of "];
    
    sucessKnifesString = [sucessKnifesString stringByAppendingString:[NSString stringWithFormat:@"%d", numberOfWeaponsFired8]];
    
    NSString* sucessGrapplingsString = @"\nSucess in using grappling to kill enemy ";
    
    sucessGrapplingsString = [sucessGrapplingsString stringByAppendingString:[NSString stringWithFormat:@"%d", numberOfSucessGrappling8]];
    sucessGrapplingsString = [sucessGrapplingsString stringByAppendingString:@" out of "];
    
    sucessGrapplingsString = [sucessGrapplingsString stringByAppendingString:[NSString stringWithFormat:@"%d", numberOfGrapplingHook8]];
    
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
    if(enableSlowMotion8)
    {
        [[[CCDirector sharedDirector] scheduler] setTimeScale:slowVelocity8];
        ninjaCircle.opacity = ninjaCircleOpacity8;
        overlayLayer.opacity = overlayLayerOpacity8;
    } else {
        [[[CCDirector sharedDirector] scheduler] setTimeScale:1.0f];
        ninjaCircle.opacity = 0.0f;
        overlayLayer.opacity = 0.0f;
        radiusCirle8 = 0;
        
    }
    ninjaCircle.position = [_contentNode convertToWorldSpace:ninja.position];
}

-(void) reduceCircle
{
    if((radiusCirle8 %20 == 0 && radiusCirle8!=0)
       || [ninja action] == IDDLE
       )
    {
        // CCLOG(@"reset circle");
        
        //parar tempo
        radiusCirle8 = 0;
        [self resetCircle];
        
    }
    else
    {
        ninjaCircle.scaleX -= 0.05f;
        ninjaCircle.scaleY -= 0.05f;
        
        radiusCirle8++;
        
        enableSlowMotion8 = true;
    }
}

-(void) resetCircle
{
    //reset tamanho circulo volta ninja
    ninjaCircle.scaleX = 1.0f;
    ninjaCircle.scaleY = 1.0f;
    
    //parar slow motion
    enableSlowMotion8 = false;
    radiusCirle8=0;
    
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