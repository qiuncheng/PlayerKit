//
//  PlayerViewController.swift
//  PlayerKit
//
//  Created by King, Gavin on 3/8/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import PlayerKit
import AVFoundation

class PlayerViewController: UIViewController, PlayerDelegate {
    private struct Constants {
        static let VideoURL = URL(string: "https://om.tc.qq.com/b0033e3enxz.mp4?vkey=756D8DE58BD5ECA933FF0BE768EE9B59477CEAC84A302700FD7D1E85C527A18AF2CF11233AE5F57026006AAE31FFAB5262EC511CBBA835EB0B7E98651FB617C599717087F2DFCD7AAED1EF418AB0E51C7EE01B646F018ADCB2BB315C0925A08E994295C917A507F29E871348B6495936")!
    }
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private let player = RegularPlayer()
    
    let rate = Float(2)
    var isPaused = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        player.delegate = self
        
        self.addPlayerToView()
        
        self.player.set(AVURLAsset(url: Constants.VideoURL))
        player.automaticallyWaitsToMinimizeStalling = false
        
        self.player.playImmediately(atRate: rate)
    }
    
    // MARK: Setup
    
    private func addPlayerToView() {
        player.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        player.view.frame = self.view.bounds
        self.view.insertSubview(player.view, at: 0)
    }
    
    // MARK: Actions
    
    @IBAction func didTapPlayButton() {
        self.player.playing ? pause() : play()
    }
    
    @IBAction func didChangeSliderValue() {
        let value = Double(self.slider.value)
        
        let time = value * self.player.duration
        
        self.player.seek(to: time)
    }
    
    func pause() {
        isPaused = true
        player.pause()
    }
    
    func play() {
        isPaused = false
        player.playImmediately(atRate: rate)
    }
    
    // MARK: VideoPlayerDelegate
    
    func playerDidUpdateState(player: Player, previousState: PlayerState) {
        self.activityIndicator.isHidden = true
        
        switch player.state {
        case .loading:
            
            self.activityIndicator.isHidden = false
            
        case .ready:
            if !isPaused {
                self.player.playImmediately(atRate: rate)
            }
            
        case .failed:
            
            NSLog("🚫 \(String(describing: player.error))")
        }
    }
    
    func playerDidUpdatePlaying(player: Player) {
        self.playButton.isSelected = player.playing
        print(">>>>>>", player.playing)
    }
    
    func playerDidUpdateTime(player: Player) {
        guard player.duration > 0 else {
            return
        }
        
        let ratio = player.time / player.duration
        
        if self.slider.isHighlighted == false {
            self.slider.value = Float(ratio)
        }
    }
    
    func playerDidUpdateBufferedTime(player: Player) {
        guard player.duration > 0 else {
            return
        }
        
        let ratio = Int((player.bufferedTime / player.duration) * 100)
        
        self.label.text = "Buffer: \(ratio)%"
    }
}
