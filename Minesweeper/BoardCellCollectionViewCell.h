//
//  BoardCellCollectionViewCell.h
//  Minesweeper
//
//  Created by Deshmukh,Richa on 10/26/15.
//  Copyright (c) 2015 Richa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BoardCellCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end
