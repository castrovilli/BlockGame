//
//  MyScene.m
//  BlockGame
//
//  Created by FT on 22/01/14.
//  Copyright (c) 2014 FT. All rights reserved.
//

#import "MyScene.h"

#define COLUMNS         6
#define ROWS            6

@implementation MyScene

-(void)createBlock:(CGSize)size withPosition:(CGPoint)position andColor:(UIColor *)color{
    
    // Create a block to be affected by Gravity
    SKSpriteNode *block = [SKSpriteNode spriteNodeWithColor:color size:size];
    
    // create a Physics body for this block and set attributes for it
    block.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:block.size];
    
    // set Restitution for physics body
    block.physicsBody.restitution  = 0.0f;
    
    // postion the block within the scene
    block.position = position;
    
    // add the block to the scene
    [self addChild:block];
}

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        // The background Color for our scene
        self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
        
        // Set the Gravity of our world
        self.physicsWorld.gravity = CGVectorMake(0, -1.f);
        
        // set up its physics body and set attributes
        SKSpriteNode *floor = [SKSpriteNode spriteNodeWithColor:[UIColor greenColor] size:CGSizeMake(320, 40)];
        floor.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:floor.size];
        floor.physicsBody.dynamic = FALSE;
        floor.position = CGPointMake(160,20);
        
        [self addChild:floor];
        
        for (int col=0; col<COLUMNS; col++) {
            for (int row = 0 ; row <ROWS; row++) {
                CGFloat dimension = self.scene.size.width / COLUMNS;
                CGFloat xPosition = (dimension/2) + col * dimension;
                NSArray *colors = @[[UIColor greenColor],[UIColor blueColor],[UIColor yellowColor]];
                NSUInteger colorIndex = arc4random() % colors.count;
                [self createBlock:CGSizeMake(dimension, dimension)
                     withPosition:CGPointMake(xPosition, 480)
                         andColor:[colors objectAtIndex:colorIndex]];
                
            }
        }
        
        
    }
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

@end
