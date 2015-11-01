//
//  GameViewController.h
//  Minesweeper
//
//  Created by Deshmukh,Richa on 10/25/15.
//  Copyright (c) 2015 Richa. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, GameStatus)
{
    GameWon,
    GameLost,
    GamePlaying
};

@interface GameViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate>

@end
