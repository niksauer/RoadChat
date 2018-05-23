//
//  DirectMessageCell.swift
//  RoadChat
//
//  Created by Niklas Sauer on 17.05.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import UIKit

class DirectMessageCell: UICollectionViewCell {
    
    // MARK: - Typealiases
    typealias ColorPalette = ChatColorPalette
    
    // MARK: Views
    let messageTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 18)
        textView.backgroundColor = UIColor.clear
        textView.isEditable = false
        return textView
    }()
    
    let textBubbleView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 15
        view.layer.masksToBounds = true
        return view
    }()
    
    let bubbleImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    // MARK: Private Properties
    private var message: DirectMessage!
    private var activeUserID: Int!
    private var colorPalette: ColorPalette!
    
    // MARK: Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(textBubbleView)
        addSubview(messageTextView)
        
        textBubbleView.addSubview(bubbleImageView)
        bubbleImageView.translatesAutoresizingMaskIntoConstraints = false
        bubbleImageView.pin(to: textBubbleView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Public Methods
    func configure(message: DirectMessage, activeUserID: Int, colorPalette: ColorPalette) {
        self.colorPalette = colorPalette
        self.activeUserID = activeUserID
        self.message = message
        
        messageTextView.text = message.message
    }
    
    func preferredLayoutSizeFittingWidth(_ width: CGFloat) -> CGSize {
        let size = CGSize(width: 0.65 * width, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let estimatedFrame = NSString(string: message.message!).boundingRect(with: size, options: options, attributes: [.font : UIFont.systemFont(ofSize: 18)], context: nil)
        
        return CGSize(width: width, height: estimatedFrame.height + 20)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // use full width
        let width = self.frame.width
        
        // calculate size of textView
        let size = CGSize(width: 0.65 * width, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let estimatedFrame = NSString(string: message.message!).boundingRect(with: size, options: options, attributes: [.font : UIFont.systemFont(ofSize: 18)], context: nil)
        
        // adjust cell accordingly
        if message.senderID == activeUserID {
            // outgoing message
            messageTextView.frame = CGRect(x: width - estimatedFrame.width - 16 - 8 - 8 - 4, y: 5, width: estimatedFrame.width + 16, height: estimatedFrame.height + 20)
            textBubbleView.frame = CGRect(x: width - estimatedFrame.width - 16 - 8 - 10 - 8 - 4, y: 0, width: estimatedFrame.width + 16 + 16 + 10, height: estimatedFrame.height + 20 + 8)
            
            messageTextView.textColor = colorPalette.outgoingTextColor
            bubbleImageView.tintColor = colorPalette.outgoingBubbleColor
            bubbleImageView.image = #imageLiteral(resourceName: "bubble_right") .resizableImage(withCapInsets: UIEdgeInsets(top: 22, left: 26, bottom: 22, right: 26)).withRenderingMode(.alwaysTemplate)
        } else {
            // incoming message
            messageTextView.frame = CGRect(x: 8 + 8 + 10, y: 6, width: estimatedFrame.width + 16, height: estimatedFrame.height + 20)
            textBubbleView.frame = CGRect(x: 8, y: 0, width: estimatedFrame.width + 16 + 16 + 10, height: estimatedFrame.height + 20 + 8)
            
            messageTextView.textColor = colorPalette.incomingTextColor
            bubbleImageView.tintColor = colorPalette.incomingBubbleColor
            bubbleImageView.image = #imageLiteral(resourceName: "bubble_left").resizableImage(withCapInsets: UIEdgeInsets(top: 22, left: 26, bottom: 22, right: 26)).withRenderingMode(.alwaysTemplate)
        }
        
    }
    
}
