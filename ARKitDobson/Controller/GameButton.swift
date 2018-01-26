//  GameButton.swift
//  ARKitDobson
//  Created by Josh Dobson on 1/26/18.
//  Copyright © 2018 Jacob Dobson. All rights reserved.
import UIKit

class GameButton: UIButton {
    var callback: () -> ()
    private var timer: Timer!
    //init frame with callback
    init(frame: CGRect, callback: @escaping () -> ()) {
        self.callback = callback
        super.init(frame: frame)
    }
    //begin touches for controlling car
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true, block: { [weak self] (timer: Timer) in
            self?.callback()
        })
    }
    //halt touches for controlling car
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.timer.invalidate()
    }
    //init required to run
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

