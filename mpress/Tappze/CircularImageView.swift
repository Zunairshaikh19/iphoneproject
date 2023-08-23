//
//  CircularImageView.swift
//  Tappze
//
//  Created by zunair on 12/08/2023.
//

import Foundation
import UIKit

class CircularImageView: UIImageView {
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.width / 2
        clipsToBounds = true
    }
}

