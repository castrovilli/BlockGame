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
    block.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(size.width-2, size.height-2)];
    
    // set Restitution for physics body
    block.physicsBody.restitution  = 0.0f;
    
    // Set Rotation to False to protect block from falling sideways
    block.physicsBody.allowsRotation = FALSE;
    
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
        self.physicsWorld.gravity = CGVectorMake(0,-1.f);
        
        // set up its physics body and set attributes
        SKSpriteNode *floor = [SKSpriteNode spriteNodeWithColor:[UIColor blackColor] size:CGSizeMake(320, 40)];
        floor.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:floor.size];
        floor.physicsBody.dynamic = FALSE;
        floor.position = CGPointMake(160,20);
        
        // add the floor to our scene
        [self addChild:floor];
        
        // Rotate through however many rows we have
        for (int row=0; row<COLUMNS; row++) {
            
            // and in each row iterate through number of columns we want
            for (int col = 0 ; col <ROWS; col++) {
                
                // generate the width and height of each block
                CGFloat dimension = 320 / COLUMNS;
                
                // generate the xPosition & yPosition base on each row and column they are in
                CGFloat xPosition = (dimension/2) + col * dimension;
                CGFloat yPosition = 480 + ((dimension/2)+ row * dimension);
                
                // Create list of color to apply to the block
                NSArray *colors = @[[UIColor greenColor],[UIColor blueColor],[UIColor yellowColor]];
                
                // generate the random number to choose from the list of color
                NSUInteger colorIndex = arc4random() % colors.count;
                
                // Generate the blocks with specified dimension, position and color
                [self createBlock:CGSizeMake(dimension, dimension)
                     withPosition:CGPointMake(xPosition, yPosition)
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
    for (SKNode* node in self.scene.children){
        node.position = CGPointMake(round(node.position.x), (node.position.y));
    }
}

@end
