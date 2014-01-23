//
//  MyScene.m
//  BlockGame
//
//  Created by FT on 22/01/14.
//  Copyright (c) 2014 FT. All rights reserved.
//

#import "MyScene.h"
#import "BlockNode.h"

// define some class-wide attributes for our scene
#define COLUMNS         6
#define ROWS            7
#define MIN_BLOCK_BUST  2

@interface MyScene() {
    NSArray *_colors;
}

- (NSArray*) getAllBlocks;

@end

@implementation MyScene

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        
        // The background color for our scene
        self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
        
        // set the gravity of our world
        self.physicsWorld.gravity = CGVectorMake(0, -8.f);
        
        // define a list of colors the blocks can potentially be
        _colors = @[[UIColor greenColor], [UIColor blueColor], [UIColor yellowColor], [UIColor purpleColor]];
        
        // create the floor for our scene
        SKSpriteNode *floor = [SKSpriteNode spriteNodeWithColor:[UIColor blackColor] size:CGSizeMake(320, 40)];
        
        // set up its physics body and set attributes
        floor.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:floor.size];
        floor.physicsBody.restitution = 0.f;
        floor.physicsBody.dynamic = FALSE; // other objects react to it, but gravity doesn't affect it
        floor.position = CGPointMake(160, 20);
        
        // add the floor to our scene
        [self addChild:floor];
        
        
        // iterate through however many rows we want
        for(int row=0; row<ROWS; row++) {
            
            // and in each row, iterate through the number of columns we want
            for (int col=0; col<COLUMNS; col++) {
                
                // generate the width/height of the blocks based on the column count
                CGFloat dimension = 320 / COLUMNS;
                
                // generate a random number within the range of our color list
                NSUInteger colorIndex = arc4random() % _colors.count;
                
                // create the block with the specified size and position + the random color
                BlockNode *node = [[BlockNode alloc] initWithRow:row
                                                       andColumn:col
                                                       withColor:[_colors objectAtIndex:colorIndex]
                                                         andSize:CGSizeMake(dimension, dimension)];
                
                // add the block to our scene
                [self.scene addChild:node];
                
            }
            
        }
        
        
    }
    return self;
}

// determine if a node is directly on one side of the base node AND it is the same color
- (BOOL) inRange:(BlockNode*)testNode of:(BlockNode*)baseNode
{
    // if the nodes are in the same row/column
    BOOL isRow = (baseNode.row == testNode.row);
    BOOL isCol = (baseNode.column == testNode.column);
    
    // if the nodes are one row/column apart
    BOOL oneOffCol = (baseNode.column+1 == testNode.column || baseNode.column-1 == testNode.column);
    BOOL oneOffRow = (baseNode.row+1 == testNode.row || baseNode.row-1 == testNode.row);
    
    // if the nodes are the same color
    BOOL sameColor = [baseNode.color isEqual:testNode.color];
    
    // returns true when they are next to each other AND the same color
    return ( (isRow && oneOffCol) || (isCol && oneOffRow) ) && sameColor;
}

// a recursive method used to find all similar blocks around a base block.
// the recursion allows us to reach beyond the current block's immediate neighbors to
// neighbors of neighbors, etc
- (NSMutableArray*) nodesToRemove:(NSMutableArray*)removedNodes aroundNode:(BlockNode*)baseNode
{
    // make sure our base node is being removed
    [removedNodes addObject:baseNode];
    
    // go through all the blocks on the screen
    for(BlockNode *childNode in [self getAllBlocks]) {
        
        // if the node being tested is on one of the four sides off our base node
        // and it is the same color, it is in range and valid to be removed
        if([self inRange:childNode of:baseNode]) {
            
            // if we have not already checked if this block is being removed
            if(![removedNodes containsObject:childNode]) {
                
                // test the blocks around this one for possible removal
                removedNodes = [self nodesToRemove:removedNodes aroundNode:childNode];
            }
            
        }
    }
    
    return removedNodes;
}

// retrive objects for every block within the scene
- (NSArray*) getAllBlocks
{
    NSMutableArray *blocks = [NSMutableArray array];
    
    // iterate through all nodes
    for(SKNode *childNode in self.scene.children) {
        
        // see if it's of type 'BlockNode'
        if([childNode isKindOfClass:[BlockNode class]]) {
            
            // add it to our tracking array
            [blocks addObject:childNode];
        }
    }
    
    return [NSArray arrayWithArray:blocks];
}

// a touch event occurred on the scene
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    // get a touch object
    UITouch *touch = [touches anyObject];
    
    // and the touch's location
    CGPoint location = [touch locationInNode:self];
    
    // see which node was touched based on the location of the touch
    SKNode *node = [self nodeAtPoint:location];
    
    // if it was a block being touched
    if([node isKindOfClass:[BlockNode class]]) {
        
        // cast it so we can access the attributes
        BlockNode *clickedBlock = (BlockNode*)node;
        
        // print a notice to the log
        NSLog(@"Node clicked: %@ => %d, %d", clickedBlock, clickedBlock.row, clickedBlock.column);
        
        // recursively retrieve all valid blocks around it
        NSMutableArray *objectsToRemove = [self nodesToRemove:[NSMutableArray array] aroundNode:clickedBlock];
        
        // ensure that there are enough connected blocks selected
        if(objectsToRemove.count >= MIN_BLOCK_BUST) {
            
            // iterate through everything we need to delete
            for(BlockNode *deleteNode in objectsToRemove) {
                
                // remove it from the scene
                [deleteNode removeFromParent];
                
                // and decrement the 'row' variable for all blocks that sit above the one being removed
                for(BlockNode *testNode in [self getAllBlocks]) {
                    if(deleteNode.column == testNode.column && (deleteNode.row < testNode.row)) {
                        --testNode.row;
                    }
                }
            }
            
            
            // make sure our grid stays full even when blocks are removed by...
            
            // initialize an array of 'maximum indexes for each column'
            NSUInteger totalRows[COLUMNS];
            for(int i=0; i<COLUMNS; i++) totalRows[i] = 0;
            
            // walk through our blocks
            for(BlockNode *node in [self getAllBlocks]) {
                
                // get the index of the highest row in each column
                if(node.row > totalRows[node.column]) {
                    totalRows[node.column] = node.row;
                }
            }
            
            // walk through each column
            for(int col=0; col<COLUMNS; col++) {
                
                // while there are not enough rows to fill the grid, create new blocks
                while (totalRows[col] < ROWS-1) {
                    
                    // generate the width/height of the blocks based on the column count
                    CGFloat dimension = 320 / COLUMNS;
                    
                    // generate a random number within the range of our color list
                    NSUInteger colorIndex = arc4random() % _colors.count;
                    
                    // create the block with the specified size and position + the random color
                    BlockNode *node = [[BlockNode alloc] initWithRow:totalRows[col]+1 // the new row will be the top row in this column
                                                           andColumn:col
                                                           withColor:[_colors objectAtIndex:colorIndex]
                                                             andSize:CGSizeMake(dimension, dimension)];
                    
                    // add the block to our scene
                    [self.scene addChild:node];
                    
                    // increment the number of rows in this particular column
                    ++totalRows[col];
                    
                }
                
            }
            
        }
        
        
    }
    
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    
    // go through all the blocks in our scene
    for(SKNode *node in self.scene.children) {
        
        // and normalize the position so it falls exactly on a pixel
        node.position = CGPointMake(roundf(node.position.x), roundf(node.position.y));
    }
    
}



@end
