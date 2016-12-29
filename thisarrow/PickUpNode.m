//
//  PickUpNode.m
//  thisarrow
//
//  Created by jam on 16/12/19.
//  Copyright © 2016年 jamstudio. All rights reserved.
//

#import "PickUpNode.h"
#import "MegaBombNode.h"
#import "RailGunNode.h"
#import "MissileTrackNode.h"

const CGFloat speedRate=0.25;
const NSString* rotationActionKey=@"rotationActionKey";

@implementation PickUpNode
{
    ZZSpriteNode* gloss;
}

+(instancetype)randomNode
{
    /*
     + (UIColor *)grayColor;       // 0.5 white
     + (UIColor *)redColor;        // 1.0, 0.0, 0.0 RGB
     + (UIColor *)greenColor;      // 0.0, 1.0, 0.0 RGB
     + (UIColor *)blueColor;       // 0.0, 0.0, 1.0 RGB
     + (UIColor *)cyanColor;       // 0.0, 1.0, 1.0 RGB
     + (UIColor *)yellowColor;     // 1.0, 1.0, 0.0 RGB
     + (UIColor *)magentaColor;    // 1.0, 0.0, 1.0 RGB
     + (UIColor *)orangeColor;     // 1.0, 0.5, 0.0 RGB
     + (UIColor *)purpleColor;     // 0.5, 0.0, 0.5 RGB
     + (UIColor *)brownColor;      // 0.6, 0.4, 0.2 RGB
     */
    
    PickUpType ran=
//        PickUpTypeYellow;
        arc4random()%PickUpTypeNothing;
    SKColor* randomColor;
    SKTexture* texture;
    if (ran==PickUpTypeOrange) {
        randomColor=[SKColor orangeColor];
        texture=[MyTextureAtlas textureNamed:@"orangePickUp"];
    }
    else if(ran==PickUpTypePurple)
    {
        randomColor=[SKColor purpleColor];
        texture=[MyTextureAtlas textureNamed:@"purplePickUp"];
    }
    else if(ran==PickUpTypeYellow)
    {
        randomColor=[SKColor yellowColor];
        texture=[MyTextureAtlas textureNamed:@"yellowPickUp"];
    }
    PickUpNode* node=texture?[PickUpNode spriteNodeWithTexture:texture]:[PickUpNode spriteNodeWithColor:randomColor size:CGSizeMake(23,23)];
    
    node.zPosition=Pick_Z_Position;
    
    node.type=ran;
    if (ran==PickUpTypePurple&&!texture) {
        ZZSpriteNode* chi=[ZZSpriteNode spriteNodeWithColor:[SKColor whiteColor] size:CGSizeMake(5,5)];
        chi.position=CGPointMake(5, 5);
        [node addChild:chi];
    }
    else if(ran==PickUpTypeYellow)
    {
        NSArray* positions=[NSArray arrayWithObjects:
                            [NSValue valueWithCGPoint:CGPointMake(3, 4)],
                            [NSValue valueWithCGPoint:CGPointMake(4, -3)],
                            [NSValue valueWithCGPoint:CGPointMake(-3, 4)],
                            [NSValue valueWithCGPoint:CGPointMake(-4, -5)],
                            [NSValue valueWithCGPoint:CGPointMake(-5, 1)],
                            nil];
        CGFloat maxW=6;
        SKAction* scales=[SKAction repeatActionForever:[SKAction sequence:[NSArray arrayWithObjects:[SKAction resizeToWidth:maxW height:maxW  duration:0.6],[SKAction resizeToWidth:0 height:0  duration:0.6], nil]]];
        for (int i=0;i<positions.count;i++) {
            NSValue* va=[positions objectAtIndex:i];
            CGPoint p=va.CGPointValue;
            ZZSpriteNode* spot=[ZZSpriteNode spriteNodeWithTexture:[MyTextureAtlas textureNamed:@"orangeDot"]];
            spot.position=p;
            spot.size=CGSizeMake(0, 0);
            [spot runAction:[SKAction sequence:[NSArray arrayWithObjects:[SKAction waitForDuration:i*0.4],scales, nil]]];
            [node addChild:spot];
        }
    }
    
    CGFloat sp=2;
    node.speedX=ZZRandom_1_0_1()*sp;
    node.speedY=ZZRandom_1_0_1()*sp;
    
    [node showUp];
    
    return node;
}

-(void)rotateAuto
{
    int ra=arc4random();
    CFTimeInterval duration=(ra%50+50)/100.0;
    if (duration<0.1) {
        duration=0.1;
    }
    CGFloat radian=ra>0?M_PI_2:-M_PI_2;
    SKAction* repeatRotation=[SKAction repeatActionForever:[SKAction rotateByAngle:radian duration:duration]];
    repeatRotation.timingMode=SKActionTimingEaseIn;
    [self runAction:repeatRotation withKey:rotationActionKey.description];
}

-(void)showUp
{
    gloss=[ZZSpriteNode spriteNodeWithTexture:[MyTextureAtlas textureNamed:@"pickUpGloss"]];
    [self addChild:gloss];
    
    SKAction* seq=[SKAction sequence:[NSArray arrayWithObjects:[SKAction scaleTo:1.2 duration:0.2],[SKAction scaleTo:1 duration:0.2], nil]];
    
    [self runAction:seq completion:^{
        self.shouldMoving=YES;
        if (self.type==PickUpTypeOrange) {
            [self rotateAuto];
        }
    }];
}

-(void)disappear
{
    if (self.disappearing) {
        return;
    }
    self.disappearing=YES;
    self.shouldMoving=NO;
    [self removeActionForKey:rotationActionKey.description];
    [self runAction:[SKAction sequence:[NSArray arrayWithObjects:[SKAction scaleTo:1.2 duration:0.25],[SKAction scaleTo:0.1 duration:0.25],nil]] completion:^{
        [self removeFromParent];
    }];
}

-(void)movingAround
{
    if (!self.shouldMoving) {
        return;
    }
    CGSize pSize=self.parent.frame.size;
    CGPoint position=self.position;
    CGFloat w2=self.size.width/2;
    BOOL isTouchTop=position.y+w2>=pSize.height;
    BOOL isTouchBottom=position.y-w2<=0;
    BOOL isTouchRight=position.x+w2>=pSize.width;
    BOOL isTouchLeft=position.x-w2<=0;
    if (isTouchTop) {
        self.speedY=-fabs(self.speedY);
    }
    if (isTouchBottom) {
        self.speedY=fabs(self.speedY);
    }
    if (isTouchRight) {
        self.speedX=-fabs(self.speedX);
    }
    if (isTouchLeft) {
        self.speedX=fabs(self.speedX);
    }
    gloss.zRotation=-self.zRotation;
    self.position=CGPointMake(position.x+self.speedX*speedRate, position.y+self.speedY*speedRate);
}

-(void)bePickedUpByNode:(SKNode *)node
{
    [self removeAllActions];
    if (self.type==PickUpTypeOrange) {
        MegaBombNode* mega=[MegaBombNode defaultNode];
        mega.position=self.position;
        [node.parent addChild:mega];
    }
    else if(self.type==PickUpTypePurple)
    {
        RailGunNode* rail=[RailGunNode defaultNode];
        [rail loadedToGun:node];
    }
    else if(self.type==PickUpTypeYellow)
    {
        int count=6;
        CGFloat ranRad=M_PI*ZZRandom_0_1();
        for (int i=0; i<count; i++) {
            MissileTrackNode* miss=[MissileTrackNode defaultNode];
            miss.zRotation=i*M_PI*2/count+ranRad;
            miss.position=self.position;
            [node.parent addChild:miss];
        }
    }
    [self removeFromParent];
}

@end
