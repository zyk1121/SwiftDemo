//
//  RxSwiftViewController.swift
//  SwiftDemo
//
//  Created by 张元科 on 2017/10/15.
//  Copyright © 2017年 SDJG. All rights reserved.
//

import UIKit
import YYText
import WebKit
import CoreText
import TFHpple

enum HTMLType {
    case Text
    case Image
    case UnKnown
}

enum HTMLTextAttrType:Int {
    case none = 0x0
    case bold = 0x1
    case undline = 0x2
    case iii = 0x4
}

class HTMLData {
    var content:String = ""
    var type:HTMLType = .UnKnown
}

class HTMLTextData: HTMLData {
    var attr:Int = 0
}

class HTMImageData: HTMLData {
    var width:String = ""
    var height:String = ""
    
}

class RxSwiftViewController: BaseViewController {


    // 判断是否是HTML(题库试题答案等)字符串 "<p>" 开始
    func isHTMLString(htmlString:String)->Bool {
        return htmlString.hasPrefix("<p>")
    }
    
    // HTML转属性字符串
    func convertHTML2AttriString(htmlString:String)->NSAttributedString {
        if (!isHTMLString(htmlString: htmlString)) {
            return NSAttributedString(string:htmlString)
        }
        let retMutableAttriString = NSMutableAttributedString(string: "")
        guard let htmlParser = try? HTMLParser(string: htmlString),
                let bodyNode = htmlParser.body(),
                let inputNodes = bodyNode.findChildTags("p") as? [HTMLNode] else {
            return retMutableAttriString
        }
        
        for rootNode in inputNodes {
            let rootStr = convertHTMLNode2AttriString(node: rootNode)
            // 默认居左
            if rootNode.rawContents().contains("text-align: left;") {
                rootStr.yy_alignment = NSTextAlignment.left
            }
            if rootNode.rawContents().contains("text-align: center;") {
                rootStr.yy_alignment = NSTextAlignment.center
            }
            if rootNode.rawContents().contains("text-align: right;") {
                rootStr.yy_alignment = NSTextAlignment.right
            }
            retMutableAttriString.append(rootStr)
            retMutableAttriString.append(NSAttributedString(string:"\n"))
        }
        
        return retMutableAttriString
    }
    
    // HTMLNode 2 String
    func convertHTMLNode2AttriString(node:HTMLNode)->NSMutableAttributedString {
        let retMutableAttriString = NSMutableAttributedString(string: "")
        let nodeCount = node.children().count
        if (nodeCount == 0) {
            return retMutableAttriString
        }
        if nodeCount == 1 {
            // 解析当前节点数据
            // 空
            if node.rawContents().characters.count <= 8 {
                return retMutableAttriString
            }
            // 注释
            if node.rawContents().contains("<!--") {
                return retMutableAttriString
            }
            // 图片
            if node.rawContents().contains("<img") {
                let imgAttriText = convertHTMLImageNode2AttriString(node: node)
                retMutableAttriString.append(imgAttriText)
            } else {
                // 文本
                let textAttri = convertHTMLTextNode2AttriString(node: node)
                retMutableAttriString.append(textAttri)
            }
        } else {
            for item in node.children() {
                let temp = item as! HTMLNode
                // 空
                if temp.rawContents().characters.count <= 8 {
                    continue
                }
                // 注释
                if temp.rawContents().contains("<!--") {
                    continue
                }
                // 图片
                if temp.rawContents().contains("<img") {
                    let imgAttriText = convertHTMLImageNode2AttriString(node: temp)
                    retMutableAttriString.append(imgAttriText)
                } else {
                    // 文本
                    let textAttri = convertHTMLTextNode2AttriString(node: temp)
                    retMutableAttriString.append(textAttri)
                }
            }
        }
        return retMutableAttriString
    }
    
    func convertHTMLImageNode2AttriString(node:HTMLNode)->NSAttributedString {
        print(node.rawContents())
        let retMutableAttriString = NSMutableAttributedString(string: "")
        if !node.rawContents().contains("<img") {
            return retMutableAttriString
        }
        let temp = node
        let width:CGFloat = CGFloat((temp.getAttributeNamed("width") as NSString).floatValue)
        let height:CGFloat = CGFloat((temp.getAttributeNamed("height") as NSString).floatValue)
        
        let imageView = UIImageView.init(frame: CGRect(x: 0, y: 0, width: width, height: height))
        imageView.sd_setImage(with: URL.init(string: temp.getAttributeNamed("src")), completed: nil)
        let attachment =  NSMutableAttributedString.yy_attachmentString(withContent: imageView, contentMode: UIViewContentMode.center, attachmentSize: imageView.frame.size, alignTo: UIFont.systemFont(ofSize: 17.0), alignment: YYTextVerticalAlignment.center)
        retMutableAttriString.append(attachment)
        return retMutableAttriString
    }
    
    func convertHTMLTextNode2AttriString(node:HTMLNode)->NSAttributedString {
        let retMutableAttriString = NSMutableAttributedString(string: "")
        let temp = node
        let strTemp = NSMutableAttributedString(string: temp.allContents(), attributes: nil)
        strTemp.yy_font  = UIFont.systemFont(ofSize: 17.0)
        // 加粗、斜体、下划线
        if (temp.rawContents().contains("<b>")) {
            strTemp.yy_font  = UIFont.boldSystemFont(ofSize: 17.0)
        }
        if (temp.rawContents().contains("<i>")) {
            let matrix = CGAffineTransform(a: 1, b: 0, c: CGFloat(tanf(15 * Float(Double.pi) / 180)), d: 1, tx: 0, ty: 0)
            strTemp.yy_textGlyphTransform = matrix
        }
        if (temp.rawContents().contains("<u>")) {
            strTemp.yy_underlineStyle = NSUnderlineStyle.styleSingle
        }
        // 默认居左
        if temp.rawContents().contains("text-align: left;") {
            strTemp.yy_alignment = NSTextAlignment.left
        }
        if temp.rawContents().contains("text-align: center;") {
            strTemp.yy_alignment = NSTextAlignment.center
        }
        if temp.rawContents().contains("text-align: right;") {
            strTemp.yy_alignment = NSTextAlignment.right
        }
        
        retMutableAttriString.append(strTemp)
        
        return retMutableAttriString
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        "<html><body><h1>春晓</h1><p>春眠不觉晓，处处闻啼鸟。夜来风雨声，花落知多少。</p><p>注意，浏览器忽略了源代码中的排版（省略了多余的空格和换行）。</p></body></html>"
        
//        let htmlString = "<html><body> Some html string \n <font size=\"13\" color=\"red\">This is some text!</font> </body></html>"
        
        let path = Bundle.main.path(forResource: "测试题库", ofType: "html")
        let htmlString = try? String.init(contentsOf: URL(fileURLWithPath: path!))
//         let htmlString = "<html><body>春眠不觉晓，处处闻啼鸟。夜来风雨声，花落知多少。</body></html>"
        
        /*
        let attrStr = try? NSMutableAttributedString(data: (htmlString?.data(using: .unicode)!)!, options: [NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType], documentAttributes: nil)
//        print(attrStr)
        
    
//        let myLabel = UILabel(frame: self.view.bounds)
//        myLabel.attributedText = attrStr
//        myLabel.isUserInteractionEnabled = true
//        
//        myLabel.numberOfLines = 0
//        self.view.addSubview(myLabel)

        
        
        
        let myLabel = UILabel(frame: self.view.bounds)
            myLabel.numberOfLines = 0
        myLabel.attributedText = attrStr
        myLabel.isUserInteractionEnabled = true
//        myLabel.displaysAsynchronously = true
    
        self.view.addSubview(myLabel)
    
        myLabel.layoutIfNeeded()
        
        
         let  textField = UITextField(frame: CGRect(x: 0, y: 100, width: 70, height: 30))
        textField.backgroundColor = UIColor.red
        myLabel.addSubview(textField)
        
        
//        http://www.cnblogs.com/lychee-li/p/6090450.html
        
//        TFHpple
//        let data = htmlString?.data(using: .unicode)
//        
//        let xpathParser = TFHpple(htmlData: data!)
//        let elements = xpathParser?.search(withXPathQuery: "//p") as! [TFHppleElement]
////        print(elements)
//        for elsement in elements {
//            if (elsement.content != nil) {
////                print(elsement.raw)
////                print(elsement.text())
//                print(elsement.attributes)
//            }
//        }
 
 */
//        HTMLParser 可以研究 不错
        
//        let tt = convertHTML2AttriString(htmlString: "<p>测试真题试卷名称</p>")
//        let ddd = convertHTML2AttriString(htmlString: htmlString!)
        
        let parser = try? HTMLParser(string: htmlString!)
//        let htmlBody = parser?.body()
//        print(htmlBody)
        let bodyNode = parser?.body()
        let inputNodes = bodyNode?.findChildTags("p") as? [HTMLNode]
        
//        print(inputNodes)
        
//        for item in inputNodes! {
////            print(item.contents())
//            print(item.children())
//        }
        
        var arr:[HTMLData] = []
        
             let mutAttrStr = NSMutableAttributedString()
        for item in inputNodes! {
       
            
            for itt in item.children() {
                let temp = itt as! HTMLNode
                //            print(temp.rawContents())
                //            print(temp.children())
                //            print(temp.rawContents().characters.count)
                if temp.rawContents().characters.count <= 8 {
                    continue
                }
                if temp.rawContents().contains("<!--") {
                    continue
                }
//                print(temp.rawContents())
                
                //            print(temp.getAttributeNamed("width"))
                //            print(temp.getAttributeNamed("src"))
                //            print(temp.allContents())
                //            print("\n")
                if (temp.children().count > 0) {
                    let ttt = temp.children()[0] as! HTMLNode
                    //                print(ttt.contents())
                    //                print(ttt.children())
                }
                
                let rawStr = temp.rawContents()
                if rawStr!.contains("<img") {
                    let image = HTMImageData()
                    image.content = temp.getAttributeNamed("src")
                    image.type = HTMLType.Image
                    image.width = temp.getAttributeNamed("width")
                    image.height = temp.getAttributeNamed("height")
                    arr.append(image)
                    
                    let imageView = UIImageView.init(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
                    imageView.sd_setImage(with: URL.init(string: temp.getAttributeNamed("src")), completed: nil)
                    let attachment2 =  NSMutableAttributedString.yy_attachmentString(withContent: imageView, contentMode: UIViewContentMode.center, attachmentSize: imageView.frame.size, alignTo: UIFont.systemFont(ofSize: 17.0), alignment: YYTextVerticalAlignment.center)
                    mutAttrStr.append(attachment2)
                    
                    
                    let textField = UITextField(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
                    textField.placeholder = "请输入正文"
                    textField.text = "22334444"
                    textField.isUserInteractionEnabled = true
                    textField.borderStyle = .roundedRect
                    textField.backgroundColor = UIColor.blue
                    let attachment =  NSMutableAttributedString.yy_attachmentString(withContent: textField, contentMode: UIViewContentMode.center, attachmentSize: textField.frame.size, alignTo: UIFont.systemFont(ofSize: 17.0), alignment: YYTextVerticalAlignment.center)
                    let highlight = YYTextHighlight()
                    highlight.tapAction = {(containerView, text, range, rect) in
                    }
                    attachment.yy_setTextHighlight(highlight, range: attachment.yy_rangeOfAll())
                    
                    
                    
                    mutAttrStr.append(attachment)
                    
                    
                    
                    
                } else {
                    let text = HTMLTextData()
                    text.type = .Text
                    //                print(temp.tagName())
                    //                print(temp.contents())
                    
                    let str = NSMutableAttributedString(string: temp.allContents(), attributes: nil)
                    //               str.addAttribute(NSObliquenessAttributeName, value: 1, range: NSRange.init(location: 0, length: 4))
                    str.yy_font  = UIFont.systemFont(ofSize: 17.0)
                    text.content = temp.allContents()
                    if (temp.rawContents().contains("<b>")) {
                        str.yy_font  = UIFont.boldSystemFont(ofSize: 17.0)
                        //                    str.
                        text.attr = text.attr | HTMLTextAttrType.bold.rawValue
                    }
                    if (temp.rawContents().contains("<i>")) {
                        //                    str.yy_setAttribute(NSObliquenessAttributeName, value: 3.0, range:NSRange(location: 0,length: str.length))
                        //                    print(str.yy_obliqueness)
                        //                    str.yy_setObliqueness(NSNumber.init(value: 10.0), range: NSRange(location: 0,length: 4))
                        //                    print(str.yy_obliqueness)
                        
                        //                    str.yy_obliqueness = NSNumber.init(value: 0.4)
                        //                    str.yy_textGlyphTransform = CGAffineTransform(rotationAngle: -0.05)
                        let matrix = CGAffineTransform(a: 1, b: 0, c: CGFloat(tanf(15 * Float(Double.pi) / 180)), d: 1, tx: 0, ty: 0)
                        str.yy_textGlyphTransform = matrix
                        //                str.addAttribute(NSObliquenessAttributeName, value: 0.5, range: NSRange(location: 0,length: 4))
                        text.attr =  text.attr | HTMLTextAttrType.iii.rawValue
                    }
                    if (temp.rawContents().contains("<u>")) {
                        str.yy_underlineStyle = NSUnderlineStyle.styleSingle
                        text.attr = text.attr | HTMLTextAttrType.undline.rawValue
                    }
                    
                    mutAttrStr.append(str)
                    //                arr.append(text)
                }
                
            }
            
             mutAttrStr.append(NSMutableAttributedString(string: "\n"))
            
//            print( item.children().count )
            if  item.children().count == 1 {
                let temp = item as! HTMLNode
                //            print(temp.rawContents())
                //            print(temp.children())
                //            print(temp.rawContents().characters.count)
                if temp.rawContents().characters.count <= 8 {
                    continue
                }
                if temp.rawContents().contains("<!--") {
                    continue
                }
              
                
              
                
                let str = NSMutableAttributedString(string: temp.allContents(), attributes: nil)
                //               str.addAttribute(NSObliquenessAttributeName, value: 1, range: NSRange.init(location: 0, length: 4))
                str.yy_font  = UIFont.systemFont(ofSize: 17.0)
//                text.content = temp.allContents()
                if (temp.rawContents().contains("<b>")) {
                    str.yy_font  = UIFont.boldSystemFont(ofSize: 17.0)
                    //                    str.
                    
                }
                
                
                if temp.rawContents().contains("text-align: center;") {
                    // 居中
                    /*
                    var paragraphStyle = NSMutableParagraphStyle()
                    //        paragraphStyle.firstLineHeadIndent = 80.0// 首行缩近
                    paragraphStyle.alignment = NSTextAlignment.center
                    attrText.append( NSMutableAttributedString(string: "\n居中显示", attributes: [NSParagraphStyleAttributeName:paragraphStyle]))
                    
                    
                    var paragraphStyle2 = NSMutableParagraphStyle()
                    //        paragraphStyle.firstLineHeadIndent = 80.0// 首行缩近
                    paragraphStyle2.alignment = NSTextAlignment.right
                    attrText.append( NSMutableAttributedString(string: "\n居右显示", attributes: [NSParagraphStyleAttributeName:paragraphStyle2]))*/
                    var paragraphStyle = NSMutableParagraphStyle()
                    //        paragraphStyle.firstLineHeadIndent = 80.0// 首行缩近
                    paragraphStyle.alignment = NSTextAlignment.center
                    mutAttrStr.append( NSMutableAttributedString(string: temp.allContents(), attributes: [NSParagraphStyleAttributeName:paragraphStyle]))
                }
                
                
                if temp.rawContents().contains("text-align: right;") {
                    // 居中
                    /*
                     var paragraphStyle = NSMutableParagraphStyle()
                     //        paragraphStyle.firstLineHeadIndent = 80.0// 首行缩近
                     paragraphStyle.alignment = NSTextAlignment.center
                     attrText.append( NSMutableAttributedString(string: "\n居中显示", attributes: [NSParagraphStyleAttributeName:paragraphStyle]))
                     
                     
                     var paragraphStyle2 = NSMutableParagraphStyle()
                     //        paragraphStyle.firstLineHeadIndent = 80.0// 首行缩近
                     paragraphStyle2.alignment = NSTextAlignment.right
                     attrText.append( NSMutableAttributedString(string: "\n居右显示", attributes: [NSParagraphStyleAttributeName:paragraphStyle2]))*/
                    var paragraphStyle = NSMutableParagraphStyle()
                    //        paragraphStyle.firstLineHeadIndent = 80.0// 首行缩近
                    paragraphStyle.alignment = NSTextAlignment.right
                    mutAttrStr.append( NSMutableAttributedString(string: temp.allContents(), attributes: [NSParagraphStyleAttributeName:paragraphStyle]))
                    
                    mutAttrStr.append(NSMutableAttributedString(string: "\n"))
                }
                
                

//                 mutAttrStr.append(str)

            } else {
            
            }
            
           
            
            
            
        }
        

        
        
        
//        mutAttrStr.yy_obliqueness = NSNumber.init(value: 0.4)
        let myLabel = YYLabel(frame: self.view.bounds)
        myLabel.numberOfLines = 0
//        myLabel.font = UIFont.systemFont(ofSize: 17.0)
//        myLabel.attributedText = mutAttrStr
        myLabel.attributedText = convertHTML2AttriString(htmlString: htmlString!)
        myLabel.isUserInteractionEnabled = true
        
        
        self.view.addSubview(myLabel)
        myLabel.layoutIfNeeded()
     
        
//        print(arr)
        
//        HTMLParser *parser = [[HTMLParser alloc] initWithString:htmlS error:&error];
//        
//        if (error) {
//            NSLog(@"Error: %@", error);
//            return;
//        }
//        
//        HTMLNode *bodyNode = [parser body];
        
        
        //开始整理数据
//        for (TFHppleElement *elsement in elements) {
//            if ([elsement content] != nil) {
//                
//                if (![[elsement objectForKey:@"style"]isEqualToString:@"text-align"]) {//筛选属性是里有style 并且值是text-align的标签
//                    
//                    //打印出该节点的所有内容  包括标签
//                    NSLog(@"%@",elsement.raw);
//                    //打印出该节点的所有内容   不包括标签
//                    NSLog(@"%@",elsement.text);
//                }
//            }
//        }
        
        /*
        
        let webView = WKWebView(frame: self.view.bounds)
        webView.loadHTMLString(htmlString!, baseURL: nil)
        
        self.view.addSubview(webView)
        */
        
        
        
    /*
        
        let font = UIFont.systemFont(ofSize: 17)
        let textField = UITextField(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
        textField.placeholder = "请输入正文（。。。）"
        textField.text = "22334444"
        textField.isUserInteractionEnabled = true
        textField.borderStyle = .roundedRect
        textField.backgroundColor = UIColor.blue
        let attachment =  NSMutableAttributedString.yy_attachmentString(withContent: textField, contentMode: UIViewContentMode.center, attachmentSize: textField.frame.size, alignTo: font, alignment: YYTextVerticalAlignment.center)
//        let highlight = YYTextHighlight()
//        highlight.tapAction = {(containerView, text, range, rect) in
//        }
//        attachment.yy_setTextHighlight(highlight, range: attachment.yy_rangeOfAll())
        
        let atta = NSMutableAttributedString.yy_attachmentString(withContent: UISwitch(), contentMode: UIViewContentMode.center, attachmentSize: CGSize(width:50,height:20), alignTo: font, alignment: YYTextVerticalAlignment.center)
    
        attrStr?.append(atta)
        
        attrStr?.append(NSAttributedString(string: "123456"))
        attrStr?.append(atta)
        
        attrStr?.append(NSAttributedString(string: "123456"))

        
        
//        attrStr?.append(attrStr!)
        
        let myLabel = UILabel(frame: self.view.bounds)
        myLabel.attributedText = attrStr
        myLabel.isUserInteractionEnabled = true
        
        myLabel.numberOfLines = 0
        self.view.addSubview(myLabel)
 
 */

//        let myLabel = UILabel(frame: self.view.bounds)
//        myLabel.attributedText = attrStr
//        myLabel.numberOfLines = 0
//        self.view.addSubview(myLabel)
//        let font = UIFont.systemFont(ofSize: 18)
//
//        let textField = UITextField(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
//        textField.placeholder = "请输入正文（。。。）"
//        textField.text = "22334444"
//        textField.isUserInteractionEnabled = true
//        textField.borderStyle = .roundedRect
//        textField.backgroundColor = UIColor.blue
//        let attachment =  NSMutableAttributedString.yy_attachmentString(withContent: textField, contentMode: UIViewContentMode.center, attachmentSize: textField.frame.size, alignTo: font, alignment: YYTextVerticalAlignment.center)
//        let highlight = YYTextHighlight()
//        highlight.tapAction = {(containerView, text, range, rect) in
//        }
//        attachment.yy_setTextHighlight(highlight, range: attachment.yy_rangeOfAll())
//
//
//        
//        attrStr?.append(attachment)
        
        
//            let myLabel = UILabel(frame: self.view.bounds)
//            myLabel.attributedText = attrStr
//            myLabel.numberOfLines = 0
//            self.view.addSubview(myLabel)
        
//        let btn = UIButton(frame: self.view.bounds)
//        btn.titleLabel?.attributedText = attrStr
//        self.view.addSubview(btn)
        
    /*
        
        NSString * htmlString = @"<html><body> Some html string \n <font size=\"13\" color=\"red\">This is some text!</font> </body></html>";
        NSAttributedString * attrStr = [[NSAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
        UILabel * myLabel = [[UILabel alloc] initWithFrame:self.view.bounds];
        myLabel.attributedText = attrStr;
        [self.view addSubview:myLabel];
 */
        
    }

}

class RxSwiftViewController2: BaseViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let v = TestView(frame:CGRect(x: 0, y: 100, width: 100, height: 40))
//        v.backgroundColor = UIColor.lightGray
//        
//        self.view.addSubview(v)
        
        
        let path = Bundle.main.path(forResource: "测试题库", ofType: "html")
        let htmlString = try? String.init(contentsOf: URL(fileURLWithPath: path!))
        //         let htmlString = "<html><body>春眠不觉晓，处处闻啼鸟。夜来风雨声，花落知多少。</body></html>"
        let attrStr = try? NSMutableAttributedString(data: (htmlString?.data(using: .unicode)!)!, options: [NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType], documentAttributes: nil)
//        print(attrStr?.string)
        
        
        let myLabel = YYLabel(frame: self.view.bounds)
        myLabel.numberOfLines = 0
//        myLabel.textAlignment = NSTextAlignment.natural
        
        let attrText = NSMutableAttributedString(string: "测试1234")
        
//        launch_logo
        let attachment =  NSMutableAttributedString.yy_attachmentString(withContent: UISwitch(), contentMode: UIViewContentMode.center, attachmentSize: CGSize(width:50,height:30), alignTo: myLabel.font, alignment: YYTextVerticalAlignment.center)
//        print(attachment)
        attrText.append(attachment)
        
        let aaa = NSMutableAttributedString.yy_attachmentString(withEmojiImage: UIImage(named:"launch_logo")!, fontSize: 40)
        attrText.append(aaa!)
        
//           attrText.append( NSMutableAttributedString(string: "测试"))
        
//        let imageView = UIImageView(image: UIImage(named:"launch_logo")!)
        
//        let bbb =  NSMutableAttributedString.yy_attachmentString(withContent: imageView, contentMode: UIViewContentMode.center, attachmentSize: CGSize(width:60,height:60), alignTo: myLabel.font, alignment: YYTextVerticalAlignment.center)
//        attrText.append(bbb)
        
    
    
        
        attrText.append( NSMutableAttributedString(string: "测试5678abc"))
        
        let  textField = UITextField(frame: CGRect(x: 0, y: 0, width: 70, height: 30))
        textField.backgroundColor = UIColor.blue
        let dddd = NSMutableAttributedString.yy_attachmentString(withContent: textField, contentMode: UIViewContentMode.center, attachmentSize: CGSize(width:70,height:30), alignTo: myLabel.font, alignment: YYTextVerticalAlignment.center)
        attrText.append(dddd)
        
         attrText.append( NSMutableAttributedString(string: "颜色", attributes: [NSForegroundColorAttributeName:UIColor.red]))
        
         attrText.append( NSMutableAttributedString(string: "\n换行", attributes: [NSForegroundColorAttributeName:UIColor.red]))
        
//        attrText.append( NSMutableAttributedString(string: "下划线", attributes: [NSUnderlineStyleAttributeName:NSUnderlineStyle.patternSolid]))
        
        var paragraphStyle = NSMutableParagraphStyle()
//        paragraphStyle.firstLineHeadIndent = 80.0// 首行缩近
        paragraphStyle.alignment = NSTextAlignment.center
        attrText.append( NSMutableAttributedString(string: "\n居中显示", attributes: [NSParagraphStyleAttributeName:paragraphStyle]))
        
        
        var paragraphStyle2 = NSMutableParagraphStyle()
        //        paragraphStyle.firstLineHeadIndent = 80.0// 首行缩近
        paragraphStyle2.alignment = NSTextAlignment.right
        attrText.append( NSMutableAttributedString(string: "\n居右显示", attributes: [NSParagraphStyleAttributeName:paragraphStyle2]))
        
        myLabel.attributedText = attrText
        myLabel.isUserInteractionEnabled = true
        
        self.view.addSubview(myLabel)
        
    }
}

/*
 
 #import "ViewController.h"
 
 @interface ViewController ()
 
 @end
 
 @implementation ViewController
 
 - (void)viewDidLoad {
 [super viewDidLoad];
 
 NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@"NSAttributeString 可以用来设置字体、段落样式，字体颜色，字体背景颜色，可以添加删除线、下划线，可以设置字间距、阴影、空心字、斜体、扁平化"];
 [attributedString addAttribute:NSExpansionAttributeName value:@1 range:NSMakeRange(0, 17)];  // 扁平化
 [attributedString addAttribute:NSObliquenessAttributeName value:@1 range:NSMakeRange(18, 8)];// 倾斜
 
 // 段落
 NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
 paragraphStyle.firstLineHeadIndent = 80;        // 首行缩进
 paragraphStyle.headIndent = 25;                 // 其它行缩进
 paragraphStyle.lineSpacing = 10;                // 行间距
 
 [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, attributedString.length)];// 段落
 
 
 NSShadow *shadow = [[NSShadow alloc] init];
 shadow.shadowBlurRadius = 5;    // 模糊度
 shadow.shadowColor = [UIColor yellowColor];
 shadow.shadowOffset = CGSizeMake(1, 3);
 [attributedString addAttribute:NSVerticalGlyphFormAttributeName value:@(0) range:NSMakeRange(27, 4)];
 [attributedString addAttribute:NSShadowAttributeName value:shadow range:NSMakeRange(27, 4)];
 [attributedString addAttribute:NSStrokeWidthAttributeName value:@(-3.0) range:NSMakeRange(32, 11)];// 边线宽度
 [attributedString addAttribute:NSStrokeColorAttributeName value:[UIColor greenColor] range:NSMakeRange(32, 11)];//边线颜色，需要先设置边线宽度
 [attributedString addAttribute:NSStrikethroughStyleAttributeName value:@(NSUnderlineStyleSingle) range:NSMakeRange(44, 7)]; // 删除线
 [attributedString addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle) range:NSMakeRange(52, 3)]; // 下划线
 
 
 [attributedString setAttributes:@{
 NSFontAttributeName:[UIFont fontWithName:@"Arial-BoldItalicMT" size:18],      // 字体、字号
 NSKernAttributeName:@(10),    // 字间距
 NSForegroundColorAttributeName:[UIColor blueColor],
 NSBackgroundColorAttributeName:[UIColor brownColor]
 }
 range:NSMakeRange(56, 20)];
 
 UILabel *label = [[UILabel alloc] initWithFrame:self.view.bounds];
 label.numberOfLines = 0;
 label.backgroundColor = [UIColor grayColor];
 label.attributedText = attributedString;
 
 [self.view addSubview:label];
 }
 
 @end
 
 
 */


class TestView:UIView
{

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //1
    override func draw(_ rect: CGRect) {
        // 2
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.textMatrix = .identity
        context.translateBy(x: 0, y: bounds.size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        // 3
        let path = CGMutablePath()
        path.addRect(bounds)
        // 4
        let attrString = NSAttributedString(string: "Hello World")
        // 5
        let framesetter = CTFramesetterCreateWithAttributedString(attrString as CFAttributedString)
        // 6
        let frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, attrString.length), path, nil)
        // 7
        CTFrameDraw(frame, context)
    }
    
}
