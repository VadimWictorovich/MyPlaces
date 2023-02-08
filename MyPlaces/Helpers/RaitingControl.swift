//
//  RaitingControl.swift
//  MyPlaces
//
//  Created by Вадим Игнатенко on 16.11.22.
//

import UIKit

@IBDesignable class RaitingControl: UIStackView {
    
    // MARK: Properties
    
    var raiting = 0 {
        didSet {
            updateButtonSelectionState()
        }
    }
    
    var raitingButtons = [UIButton]()
    
    @IBInspectable var starSize: CGSize = CGSize(width: 44.0, height: 44.0) {
        didSet {
            setupButtons()
        }
    }
    @IBInspectable var starCount: Int = 5 {
        didSet {
            setupButtons()
        }
    }
    

    
    
    
    // MARK: Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButtons()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupButtons()
    }
    
    // MARK: Button Action
    
    @objc func ratingButtonTapped(button: UIButton) {
        
        guard let index = raitingButtons.firstIndex(of: button) else { return }
        
        // calculate the raiting of the selected button
        let selectedRaiting = index + 1
        
        if selectedRaiting == raiting {
            raiting = 0
        } else {
            raiting = selectedRaiting
        }
    }
    
    // MARK: private methods
    
    private func setupButtons() {
        
        for button in raitingButtons {
            removeArrangedSubview(button)
            button.removeFromSuperview()
        }
        
        
        // Load button image
        let bundle = Bundle(for: type(of: self))
        
        let filledStar = UIImage(named: "желтая звезда",
                                in: bundle,
                                compatibleWith: self.traitCollection)
        
        let emptyStar = UIImage(named: "пустая звезда",
                                in: bundle,
                                compatibleWith: self.traitCollection)
        
        let highLightedStar = UIImage(named: "синяя звезда",
                                in: bundle,
                                compatibleWith: self.traitCollection)
        
        raitingButtons.removeAll()
        
        for _ in 0..<starCount {
            // Create the button
            let button = UIButton()
           
            // Set the button image
            button.setImage(emptyStar, for: .normal)
            button.setImage(filledStar, for: .selected)
            button.setImage(highLightedStar, for: .highlighted)
            button.setImage(highLightedStar, for: [.highlighted,.selected])
            
            // Add constraind
            button.translatesAutoresizingMaskIntoConstraints = false
            button.heightAnchor.constraint(equalToConstant: starSize.height).isActive = true
            button.widthAnchor.constraint(equalToConstant: starSize.width).isActive = true
            
            // Setup the button action
            button.addTarget(self, action: #selector(ratingButtonTapped(button:  )), for: .touchUpInside)
            
            // Add the button to the stack
            addArrangedSubview(button)
            
            // Add the new button on the raiting button array
            raitingButtons.append(button)
        }
        
        updateButtonSelectionState()
    }
    
    
    private func updateButtonSelectionState() {
        for (index, button) in raitingButtons.enumerated() {
            button.isSelected = index < raiting
        }
    }
}
