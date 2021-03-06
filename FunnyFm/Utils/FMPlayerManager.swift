//
//  FMPlayerManager.swift
//  FunnyFm
//
//  Created by Duke on 2018/12/7.
//  Copyright © 2018 Duke. All rights reserved.
//

import UIKit
import MediaPlayer
import Kingfisher

enum MAudioPlayState {
    case playing
    case paused
    case waiting
}

protocol FMPlayerManagerDelegate {
    func playerStatusDidChanged(isCanPlay:Bool)
	func playerDidPlay()
	func playerDidPause()
    
}

class FMPlayerManager: NSObject {
    
    static let shared = FMPlayerManager()
    
    var delegate: FMPlayerManagerDelegate?
    
    var isPlay: Bool = false
    
    var isCanPlay: Bool = false
    
    var player: AVPlayer?
    
    var playerItem: AVPlayerItem?
    
    var currentTime: NSInteger = 0
    
    var totalTime: NSInteger = 0
    
    var playState: MAudioPlayState = .waiting
    
    var ratevalue: Float = 0
    
    var currentModel: Chapter?
    
    override init() {
        super.init()
//        NotificationCenter.default.addObserver(self, selector: #selector(setBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    deinit {
        self.playerItem?.removeObserver(self, forKeyPath: "status")
        self.player?.removeTimeObserver(self)

    }
    
    func changePlayItem(_ item: AVPlayerItem){
        self.isCanPlay = false
        self.delegate?.playerStatusDidChanged(isCanPlay: false)
        self.playerItem?.removeObserver(self, forKeyPath: "status")
        self.playerItem?.removeObserver(self, forKeyPath: "loadedTimeRanges")
        self.playerItem = item
        self.playerItem?.addObserver(self, forKeyPath: "status", options: .new, context: nil)
        self.playerItem?.addObserver(self, forKeyPath: "loadedTimeRanges", options: .new, context: nil)
    }
    
    func config(_ chapter:Chapter) {
        self.currentModel = chapter
        configPlayBackgroungMode()
        self.setBackground()
        let item = AVPlayerItem.init(url: URL.init(string: chapter.trackUrl_normal)!)
        if self.playerItem.isSome {
            if(self.playerItem! == item) {
                SwiftNotice.noticeOnStatusBar("正在播放", autoClear: true, autoClearTime: 2)
                return
                
            }else{
               self.changePlayItem(item)
            }
        }else{
            self.changePlayItem(item)
        }
        if self.player.isNone {
            self.player = AVPlayer.init(playerItem: self.playerItem)
        }else{
            self.player?.replaceCurrentItem(with: self.playerItem)
        }
        
        self.player?.addPeriodicTimeObserver(forInterval: CMTime.init(seconds: 0.1, preferredTimescale: 600), queue: DispatchQueue.main, using: { [unowned self] (time) in
            self.setBackground()
        })
    }
    
    
    func play(){
        
        if(self.isCanPlay){
            self.isPlay = true
            self.player?.play()
			self.delegate?.playerDidPlay()
        }else{
           SwiftNotice.noticeOnStatusBar("暂时无法播放", autoClear: true, autoClearTime: 1)
        }
    }
    
    func pause() {
        self.isPlay = false
        self.player?.pause()
		self.delegate?.playerDidPause()
    }
    

}

extension FMPlayerManager{
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        let value = change?[NSKeyValueChangeKey.newKey]
        if value.isNone {
            return
        }
        if keyPath == "status" {
            let status = value! as! Int
            if(status == 1){
                self.isCanPlay = true
                self.delegate?.playerStatusDidChanged(isCanPlay: true)
            }else{
                self.isCanPlay = false
                self.delegate?.playerStatusDidChanged(isCanPlay: false)
            }
        }
        
        if keyPath == "loadedTimeRanges" {
            
        }
        
    }
}


extension FMPlayerManager {
	
	@objc func setBackground() {
        let image = KingfisherManager.shared.cache.retrieveImageInDiskCache(forKey: (self.currentModel?.pod_cover_url)!)
		var info = Dictionary<String, Any>()
		info[MPMediaItemPropertyTitle] = self.currentModel?.title//歌名
		info[MPMediaItemPropertyArtist] = self.currentModel?.pod_name//作者
        info[MPMediaItemPropertyArtwork] = MPMediaItemArtwork.init(boundsSize: CGSize.init(width: 100, height: 100), requestHandler: { (size) -> UIImage in
            if image.isSome{
                return image!
            }
            return UIImage.init(named: "ImagePlaceHolder")!
        })
		info[MPMediaItemPropertyPlaybackDuration] = self.currentModel?.duration
		info[MPNowPlayingInfoPropertyPlaybackRate] = 1.0
        info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = self.player?.currentTime()
		MPNowPlayingInfoCenter.default().nowPlayingInfo = info
        UIApplication.shared.registerForRemoteNotifications()
	}
    
    
}
