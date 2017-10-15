//
//  YYTextViewController.swift
//  SwiftDemo
//
//  Created by 张元科 on 2017/10/15.
//  Copyright © 2017年 SDJG. All rights reserved.
//

import UIKit
import YYText
import SnapKit

//range转换为NSRange
extension String {
    func nsRange(from range: Range<String.Index>) -> NSRange {
        let from = range.lowerBound.samePosition(in: utf16)
        let to = range.upperBound.samePosition(in: utf16)
        return NSRange(location: utf16.distance(from: utf16.startIndex, to: from),
                       length: utf16.distance(from: from, to: to))
    }
}

// http://www.jianshu.com/p/60aee32ade55?nomobile=yes

class YYTextViewController: BaseViewController {

    let label1 = YYLabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        view.updateConstraintsIfNeeded()
    }
    
    func setupUI()
    {
        label1.numberOfLines = 0
//        label1.textAlignment = NSTextAlignment.center
//        label1.textVerticalAlignment = YYTextVerticalAlignment.center
        // //这个属性必须设置，多行才有效
        label1.preferredMaxLayoutWidth = UIScreen.main.bounds.width
        view.addSubview(label1)
        // 1.
        /*
        let text = "特别声名:本站充分的认识到保护音乐版权的重要性，本站为更好的保护歌曲著作人权益。链接：http://www.jianshu.com/p/60aee32ade55 來源：简书"
        let attrText = NSMutableAttributedString(string: text)
        attrText.yy_font = UIFont.systemFont(ofSize: 20)
        attrText.yy_lineSpacing = 20// 行间距
        label1.attributedText = attrText
 */
        
        // 2
        
        /*
        let text = "特别声名:本站充分的认识到保护音乐版权的重要性，本站为更好的保护歌曲著作人权益。链接：http://www.jianshu.com/p/60aee32ade55 來源：简书"
        let range1  = text.nsRange(from: text.range(of: "本站为更好的保护歌曲")!)
//        let range1 = text.range(of: "本站为更好的保护歌曲")
        let attrText = NSMutableAttributedString(string: text)
        //字体
        attrText.yy_font = UIFont.systemFont(ofSize: 20)
        attrText.yy_setFont(UIFont.systemFont(ofSize: 25), range: range1)
        //文字颜色
        attrText.yy_setColor(UIColor.purple, range: range1)
        //文字间距
        attrText.yy_setKern(2, range: range1)
//        attrText.yy_font = UIFont.systemFont(ofSize: 20)
        attrText.yy_lineSpacing = 20// 行间距
        label1.attributedText = attrText
 */
        
        /*边框：
         NSRange range3 = [[text string] rangeOfString:@"请你打开电视看看 多少人" options:NSCaseInsensitiveSearch];
         
         //边框
         YYTextBorder *border = [YYTextBorder new];
         border.strokeColor = [UIColor colorWithRed:1.000 green:0.029 blue:0.651 alpha:1.000];
         border.strokeWidth = 3;
         border.lineStyle = YYTextLineStylePatternCircleDot;
         border.cornerRadius = 3;
         border.insets = UIEdgeInsetsMake(0, -2, 0, -2);
         
         [text yy_setTextBorder:border range:range3];
         
         作者：0o冻僵的企鹅o0
         链接：http://www.jianshu.com/p/60aee32ade55
         來源：简书
         著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。
         
        
        
        //文本高亮pro
        UIColor *colorNormal = [UIColor colorWithRed:0.093 green:0.492 blue:1.000 alpha:1.000];
        UIColor *colorHighlight = [UIColor purpleColor];
        
        NSRange range9 = [[text string] rangeOfString:@"微微笑 小时候的梦我知道" options:NSCaseInsensitiveSearch];
        
        
        YYTextDecoration *decorationNomal = [YYTextDecoration decorationWithStyle:YYTextLineStyleSingle
        width:@(1)
        color:colorNormal];
        YYTextDecoration *decorationHighlight = [YYTextDecoration decorationWithStyle:YYTextLineStyleSingle
        width:@(1)
        color:colorHighlight];
        //未点击时颜色
        [text yy_setColor:colorNormal range:range9];
        //未点击时下划线
        [text yy_setTextUnderline:decorationNomal range:range9];
        
        //点击后的状态
        YYTextHighlight *highlight = [YYTextHighlight new];
        [highlight setColor:colorHighlight];
        [highlight setUnderline:decorationHighlight];
        highlight.tapAction = ^(UIView *containerView, NSAttributedString *text, NSRange range, CGRect rect) {
            [AppUtility showMessage:[NSString stringWithFormat:@"Tap: %@",[text.string substringWithRange:range]]];
        };
        [text yy_setTextHighlight:highlight range:range9];
        

         CGSize size = CGSizeMake(SCREEN_WIDTH, CGFLOAT_MAX);
         YYTextLayout *layout = [YYTextLayout layoutWithContainerSize:size text:text];
         
         // 获取文本显示位置和大小
         //layout.textBoundingRect; // get bounding rect
         //layout.textBoundingSize; // get bounding size
         可以由YYTextLayout获取文本的bonding rect和size。
         
         作者：0o冻僵的企鹅o0
         链接：http://www.jianshu.com/p/60aee32ade55
         來源：简书
         著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。
         
         添加gif动画
         
         实现代码
         
         YYImage *image = [YYImage imageNamed:@"zuqiu"];
         image.preloadAllAnimatedImageFrames = YES;
         YYAnimatedImageView *imageView = [[YYAnimatedImageView alloc] initWithImage:image];
         imageView.autoPlayAnimatedImage = NO;
         [imageView startAnimating];
         
         NSMutableAttributedString *attachText = [NSMutableAttributedString yy_attachmentStringWithContent:imageView contentMode:UIViewContentModeCenter attachmentSize:imageView.size alignToFont:[UIFont systemFontOfSize:16] alignment:YYTextVerticalAlignmentBottom];
         [text appendAttributedString:attachText];
         
         作者：0o冻僵的企鹅o0
         链接：http://www.jianshu.com/p/60aee32ade55
         來源：简书
         著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。
         
         
         
         
         YYLabel添加tap事件
         
         实现代码
         
         YYLabel *label = [YYLabel new];
         label.highlightTapAction = ^(UIView *containerView, NSAttributedString *text, NSRange range, CGRect rect) {
         if ([self.clickDelegate respondsToSelector:@selector(label:tapHighlight:inRange:)])
         {
         YYTextHighlight *highlight = [text yy_attribute:YYTextHighlightAttributeName atIndex:range.location];
         [self.clickDelegate label:(YYLabel *)containerView tapHighlight:highlight inRange:range];
         }
         };
         label.frame = CGRectMake(0, 0, SCREEN_WIDTH, layout.textBoundingSize.height);
         label.textAlignment = NSTextAlignmentCenter;
         label.textVerticalAlignment = YYTextVerticalAlignmentCenter;
         label.numberOfLines = 0;
         label.backgroundColor = RGBCOLOR(246, 246, 246);
         label.textLayout = layout;
         [self addSubview:label];
         这里有个属性highlightTapAction就是用来处理点击高亮文字事件的，在这里，我定义了一个delegate：
         
         @protocol YYHiglightTextClickDelegate <NSObject>
         
         - (void)label:(YYLabel *)label
         tapHighlight:(YYTextHighlight *)highlight
         inRange:(NSRange)textRange;
         
         @end
         只要实现这个delegate就能方便的处理点击各种高亮文字的事件。YYTextHighlight里面包含了一个userInfo，包含了很多需要处理的信息，通过它，能够很容易的处理点击事件，我这里在UIViewController中做了一个实现：
         
         #pragma mark - YYHiglightTextClickDelegate
         - (void)label:(YYLabel *)label
         tapHighlight:(YYTextHighlight *)highlight
         inRange:(NSRange)textRange
         {
         NSDictionary *info = highlight.userInfo;
         LinkType linkType = [info[@"linkType"] integerValue];
         NSString *linkValue = info[@"linkValue"];
         switch (linkType) {
         case LinkTypeAt:
         {
         [AppUtility showMessage:[NSString stringWithFormat:@"选中at：%@",linkValue]];
         }
         break;
         case LinkTypeTopic:
         {
         [AppUtility showMessage:[NSString stringWithFormat:@"选中话题：%@",linkValue]];
         }
         break;
         case LinkTypeEmail:
         {
         [AppUtility showMessage:[NSString stringWithFormat:@"选中email：%@",linkValue]];
         }
         break;
         case LinkTypeURL:
         {
         [AppUtility showMessage:[NSString stringWithFormat:@"选中url：%@",linkValue]];
         }
         break;
         case LinkTypePhoneNum:
         {
         [AppUtility showMessage:[NSString stringWithFormat:@"选中phone：%@",linkValue]];
         }
         break;
         default:
         break;
         }
         }
         我在userInfo中传入了两对键值：
         
         作者：0o冻僵的企鹅o0
         链接：http://www.jianshu.com/p/60aee32ade55
         來源：简书
         著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。
         
         
        
        */
        
        // 3
        let text = "特别声名:本站充分的认识到保护音乐版权的重要性，本站为更好的保护歌曲著作人权益。链接：http://www.jianshu.com/p/60aee32ade55 來源：简书 著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。商业转载请联系作者获得授权，非商业转载请注明出处。商业转载请联系作者获得授权，非商业转载请注明出处。商业转载请联系作者获得授权，非商业转载请注明出处。"
        let range1  = text.nsRange(from: text.range(of: "本站为更好的保护歌曲")!)
        //        let range1 = text.range(of: "本站为更好的保护歌曲")
        let attrText = NSMutableAttributedString(string: text)
        //字体
        attrText.yy_font = UIFont.systemFont(ofSize: 20)
        attrText.yy_setFont(UIFont.systemFont(ofSize: 25), range: range1)
        
        // 文字描边空心字 本站充分的认识到
        let range2 = text.nsRange(from: text.range(of: "本站充分的认识到")!)
        //文字描边（空心字）默认黑色，必须设置width
        attrText.yy_setStroke(UIColor.orange, range: range2)
        attrText.yy_setStrokeWidth(2, range: range2)
        
        
//        删除样式、下划线 重要性
        let range3 = text.nsRange(from: text.range(of: "重要性")!)
        let decoration = YYTextDecoration(style: YYTextLineStyle.single, width: 1, color: UIColor.red)
        //删除样式
        attrText.yy_setTextStrikethrough(decoration, range: range3)
        //下划线
        attrText.yy_setTextUnderline(decoration, range: range3)

        
        
        // 文本高亮
        //文本高亮简单版
        let range4 = text.nsRange(from: text.range(of: "简书")!)

        attrText.yy_setTextHighlight(range4, color: UIColor.red, backgroundColor: UIColor.blue) { (view, text, range, rect) in
            print(text)
        }

        
        
        //link
        // 高亮状态的背景
        let highlightBorder = YYTextBorder()
        highlightBorder.insets = UIEdgeInsetsMake(-2, 0, -2, 0)
        highlightBorder.cornerRadius = 3
        highlightBorder.fillColor = UIColor.green

        
        let range5 = text.nsRange(from: text.range(of: "http://www.jianshu.com/p/60aee32ade55")!)
        attrText.yy_attribute(YYTextHighlightAttributeName, at: UInt(range5.location))
        attrText.yy_setColor(UIColor.blue, range: range5)
        let highlight = YYTextHighlight()
        highlight.setBackgroundBorder(highlightBorder)
        // 数据信息，用于稍后用户点击
        //highlight.userInfo = @{@"linkValue" : [text.string substringWithRange:NSMakeRange(at.range.location, at.range.length)],@"linkType":@(LinkTypeURL)};
        attrText.yy_setTextHighlight(highlight, range: range5)

        

        
        
        //文字颜色
        attrText.yy_setColor(UIColor.purple, range: range1)
        //文字间距
        attrText.yy_setKern(2, range: range1)
        //        attrText.yy_font = UIFont.systemFont(ofSize: 20)
        attrText.yy_lineSpacing = 20// 行间距
        label1.attributedText = attrText
    
        
        // 高亮的点击事件
        label1.highlightTapAction = { (view, text, range, rect) in
            print(text)
        }
        
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        label1.snp.remakeConstraints { (make) in
            make.top.equalTo(self.view).offset(64)
            make.left.right.equalTo(self.view)
        }
    }
}
/*
 
 利用YYLabel 进行图文混排+高度计算
 
 1、项目需求：
 
 用一个控件显示图片和文字，并且依据图片和文字动态计算控件的高度。
 
 2、方案：
 
 利用YYLabel控件和属性字符串处理。
 
 注：（在使用YYLabel之前，使用UILabel测试过，但是发现在图文混排的时候。利用属性字符串计算高度不太准确。会有多余的文字不显示。）
 
 示例代码
 
 //使用YYText 处理富文本行高
 
 YYLabel *contentL = [[YYLabel alloc] init];
 //设置多行
 contentL.numberOfLines = 0;
 //这个属性必须设置，多行才有效
 contentL.preferredMaxLayoutWidth = kScreenWidth -32;
 
 NSMutableAttributedString *attri = [[NSMutableAttributedString alloc] initWithAttributedString:[OSCBaseCommetView contentStringFromRawString:commentItem.content withFont:24.0]];
 
 //可以将要插入的图片作为特殊字符处理
 //需要使用 YYAnimatedImageView 控件，直接使用UIImage添加无效。
 
 YYAnimatedImageView *imageView1= [[YYAnimatedImageView alloc] initWithImage:[UIImage imageNamed:@"ic_quote_left"]];
 imageView1.frame = CGRectMake(0, 0, 16, 16);
 
 YYAnimatedImageView *imageView2= [[YYAnimatedImageView alloc] initWithImage:[UIImage imageNamed:@"ic_quote_right"]];
 imageView2.frame = CGRectMake(0, 0, 16, 16);
 // attchmentSize 修改，可以处理内边距
 NSMutableAttributedString *attachText1= [NSMutableAttributedString attachmentStringWithContent:imageView1 contentMode:UIViewContentModeScaleAspectFit attachmentSize:imageView1.frame.size alignToFont:[UIFont systemFontOfSize:24] alignment:YYTextVerticalAlignmentCenter];
 
 NSMutableAttributedString *attachText2= [NSMutableAttributedString attachmentStringWithContent:imageView2 contentMode:UIViewContentModeScaleAspectFit attachmentSize:imageView2.frame.size alignToFont:[UIFont systemFontOfSize:24] alignment:YYTextVerticalAlignmentCenter];
 
 //插入到开头
 [attri insertAttributedString:attachText1 atIndex:0];
 //插入到结尾
 [attri appendAttributedString:attachText2];
 
 //用label的attributedText属性来使用富文本
 contentL.attributedText = attri;
 
 CGSize maxSize = CGSizeMake([UIScreen mainScreen].bounds.size.width - 32, MAXFLOAT);
 
 //计算文本尺寸
 YYTextLayout *layout = [YYTextLayout layoutWithContainerSize:maxSize text:attri];
 contentL.textLayout = layout;
 CGFloat introHeight = layout.textBoundingSize.height;
 
 
 contentL.frame =  commentItem.layoutInfo.contentTextViewFrame;
 contentL.width = maxSize.width;
 
 contentL.height = introHeight + 50;
 
 [self addSubview:contentL];
 
 作者：吴佩在天涯海角
 链接：http://www.jianshu.com/p/3a47426487af
 來源：简书
 著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。
 
 */
