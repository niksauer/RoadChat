//
//  DirectMessageCell.swift
//  RoadChat
//
//  Created by Niklas Sauer on 17.05.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import UIKit

class DirectMessageCell: UICollectionViewCell {
    
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
        imageView.tintColor = UIColor(white: 0.90, alpha: 1)
        return imageView
    }()
    
    // MARK: Private Properties
    static let leftBubble = #imageLiteral(resourceName: "bubble_left").resizableImage(withCapInsets: UIEdgeInsets(top: 22, left: 26, bottom: 22, right: 26)).withRenderingMode(.alwaysTemplate)
    static let rightBubble = #imageLiteral(resourceName: "bubble_right") .resizableImage(withCapInsets: UIEdgeInsets(top: 22, left: 26, bottom: 22, right: 26)).withRenderingMode(.alwaysTemplate)
    
    // MARK: Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Private Methods
    private func setupViews() {
        addSubview(textBubbleView)
        addSubview(messageTextView)
        
        textBubbleView.addSubview(bubbleImageView)
        bubbleImageView.translatesAutoresizingMaskIntoConstraints = false
        bubbleImageView.pin(to: textBubbleView)
    }

}
