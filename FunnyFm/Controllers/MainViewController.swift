//
//  ViewController.swift
//  FunnyFm
//
//  Created by Duke on 2018/11/8.
//  Copyright © 2018 Duke. All rights reserved.
//

import UIKit
import SnapKit
import SPStorkController
import Lottie
import CleanyModal
import NVActivityIndicatorView
import GoogleMobileAds

class MainViewController:  BaseViewController,UICollectionViewDataSource,UICollectionViewDelegate,UITableViewDelegate,UITableViewDataSource{
	
    var vm = MainViewModel.init()
    
    var containerView: UIView!
    
    var collectionView : UICollectionView!
    
    var tableview : UITableView!
	
	var titileLB: UILabel!
    
    var searchBtn : UIButton!
    
    var profileBtn : UIButton!
	
	var addBtn : UIButton!
	
	var emptyView: UIView!
	
	var loadAnimationView : AnimationView!
	
	var emptyAnimationView : AnimationView!
	
	var fetchLoadingView : NVActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
		self.view.backgroundColor = .white
		self.dw_addViews()
		self.addConstrains()
		self.addHeader();
		self.loadAnimationView.play()
		self.dw_addNofications()
		self.vm.delegate = self
		FMToolBar.shared.isHidden = true
		UIApplication.shared.windows.first!.addSubview(FMToolBar.shared)
		self.addEmptyViews()
		if !UserDefaults.standard.bool(forKey: "isFirstMain") {
			let emptyVC = EmptyMainViewController.init()
			self.navigationController?.pushViewController(emptyVC, animated: false)
			UserDefaults.standard.set(true, forKey: "isFirstMain")
		}
		self.vm.getAllPods()
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.emptyAnimationView.play()
		UIApplication.shared.windows.first!.bringSubviewToFront(FMToolBar.shared)
		FMToolBar.shared.explain()
		self.vm.getAd(vc: self)
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		FMToolBar.shared.shrink()
	}
	
}


// MARK: - Actions
extension MainViewController{
    
    @objc func toUserCenter() {
        let usercenterVC = UserCenterViewController()
        self.navigationController?.pushViewController(usercenterVC)
    }
    
    @objc func toSearch() {
		let search = SearchViewController.init()
		self.navigationController?.pushViewController(search);
	}
	
	func toDetail(episode: Episode) {
		let detailVC = EpisodeDetailViewController.init()
		detailVC.episode = episode
		self.navigationController?.pushViewController(detailVC);
	}
    
    @objc func refreshData(){
		self.fetchLoadingView.startAnimating()
        let feedBackGenertor = UIImpactFeedbackGenerator.init(style: .medium)
        feedBackGenertor.impactOccurred()
        self.vm.refresh()
    }
	
	func dw_addNofications(){
		NotificationCenter.default.addObserver(forName: NSNotification.Name.init("homechapterParserSuccess"), object: nil, queue: OperationQueue.main) { (notify) in
			self.fetchLoadingView.stopAnimating()
		}
		
		NotificationCenter.default.addObserver(forName: NSNotification.Name.init("homechapterParserBegin"), object: nil, queue: OperationQueue.main) { (notify) in
			self.fetchLoadingView.startAnimating()
		}
		
		NotificationCenter.default.addObserver(forName: NSNotification.Name.init(kParserNotification), object: nil, queue: OperationQueue.main) { (notify) in
			self.vm.refresh()
		}
	}
}


// MARK: - ViewModelDelegate
extension MainViewController : MainViewModelDelegate {
    
    func viewModelDidGetDataSuccess() {
        self.collectionView.reloadData()
    }
    
    func viewModelDidGetDataFailture(msg: String?) {
		self.fetchLoadingView.stopAnimating()
		self.loadAnimationView.removeFromSuperview()
        self.tableview.refreshControl?.endRefreshing()
        SwiftNotice.noticeOnStatusBar("请求失败".localized, autoClear: true, autoClearTime: 2)
    }
	
	func viewModelDidGetChapterlistSuccess() {
		self.tableview.isHidden = false
		self.loadAnimationView.removeFromSuperview()
		self.tableview.refreshControl?.endRefreshing()
		self.tableview.reloadData()
		self.emptyView.isHidden = self.vm.podlist.count > 0
	}
	
	func viewModelDidGetAdlistSuccess() {
		if self.vm.nativeAds.count < 1{
			return
		}
		var index = 0
		for nativeAd in self.vm.nativeAds {
			if index > self.vm.episodeList.count {
				if index > self.vm.episodeList.count - 1 {
					break
				}
				var episodelist = self.vm.episodeList[index]
				episodelist.append(nativeAd)
				index += 1
			} else {
				break
			}
		}
		self.tableview.reloadData()
	}
    
}

// MARK: UICollectionViewDelegate
extension MainViewController{
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let pod = self.vm.podlist[indexPath.row]
        let vc = PodDetailViewController.init(pod: pod)
        self.navigationController?.pushViewController(vc)
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let episodeList = self.vm.episodeList[indexPath.section]
		let item = episodeList[indexPath.row]
		guard item is Episode else {
			return;
		}

		FMToolBar.shared.isHidden = false
		FMToolBar.shared.configToolBarAtHome(item as! Episode)
    }
}


// MARK: - TablviewDataSource
extension MainViewController{
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return self.vm.episodeList.count
	}
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		let episodeList = self.vm.episodeList[section]
        return episodeList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let episodeList = self.vm.episodeList[indexPath.section]
		let item = episodeList[indexPath.row]
		if item is Episode {
			let cell = tableView.dequeueReusableCell(withIdentifier: "tablecell", for: indexPath)
			return cell
		}else{
			let cell = tableView.dequeueReusableCell(withIdentifier: "adcell", for: indexPath)
			return cell
		}
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		
		let episodeList = self.vm.episodeList[indexPath.section]
        let item = episodeList[indexPath.row]
		if item is Episode{
			guard let cell = cell as? HomeAlbumTableViewCell else { return }
			let episode = item as! Episode
			cell.configHomeCell(episode)
			cell.tranferNoParameterClosure { [weak self] in
				self?.toDetail(episode: episode)
			}
		}
		
		if item is GADUnifiedNativeAd {
			guard let cell = cell as? AdMobTableViewCell else { return }
			let ad = item as! GADUnifiedNativeAd
			cell.config(nativeAd: ad)
		}
    }
	
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let episodeList = self.vm.episodeList[section]
		let view = UIView.init()
		view.backgroundColor = .white
		let episode = episodeList.first! as! Episode
		let titleLB = UILabel.init(text: episode.pubDate)
		titleLB.textColor = CommonColor.content.color
		titleLB.font = p_bfont(12)
		view.addSubview(titleLB)
		titleLB.snp.makeConstraints { (make) in
			make.center.equalTo(view)
		}
		
		let line = UIView.init()
		line.backgroundColor = CommonColor.mainRed.color
		view.addSubview(line)
		line.snp.makeConstraints { (make) in
			make.centerX.equalTo(view)
			make.top.equalTo(titleLB.snp.bottom).offset(2)
			make.height.equalTo(3)
			make.width.equalTo(10)
		}
		return view
	}
	
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 30
	}
	
}


// MARK: UICollectionViewDataSource
extension MainViewController{
    
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return self.vm.podlist.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var header = HomePodListHeader()
        if kind == UICollectionView.elementKindSectionHeader {
            header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath as IndexPath) as! HomePodListHeader;
            header.tapClosure = {
                let podlistvc = PodListViewController()
                self.navigationController?.pushViewController(podlistvc)
                
            }
        }
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? HomePodCollectionViewCell else { return }
        let pod = self.vm.podlist[indexPath.row]
		if pod.collectionId.length() < 1 {
			return
		}
        cell.configCell(pod)
    }
}


// MARK: - UI
extension MainViewController {
	
	func addFooter(){
		let label = UILabel.init(text: "- only last 15 -")
		label.textColor = UIColor.init(hex: "e0e2e6")
		label.textAlignment = .center
		label.frame = CGRect.init(x: 0, y: 0, width: kScreenWidth, height: 36);
		label.font = h_bfont(14)
		label.backgroundColor = .white
		self.tableview.tableFooterView = label
	}
    
    func addHeader(){
        let refreshControl = UIRefreshControl.init()
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        self.tableview.refreshControl = refreshControl;
    }
    
    
    fileprivate func addConstrains() {
        self.view.addSubview(self.profileBtn)
        self.view.addSubview(self.searchBtn)
        self.view.addSubview(self.titileLB)
        self.view.addSubview(self.tableview)
		self.view.addSubview(self.loadAnimationView);
		self.view.sendSubviewToBack(self.tableview)
		
		let topBgView = UIView.init()
		topBgView.backgroundColor = .white
		self.view.addSubview(topBgView)
		self.view.insertSubview(topBgView, belowSubview: self.profileBtn)
		topBgView.snp.makeConstraints { (make) in
			make.left.width.top.equalToSuperview()
			make.bottom.equalTo(self.titileLB)
		}
        
        self.profileBtn.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize.init(width: 35, height: 35))
            make.right.equalTo(self.searchBtn.snp.left).offset(-5)
            make.centerY.equalTo(self.titileLB)
        }
        
        self.searchBtn.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize.init(width: 40, height: 40))
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalTo(self.titileLB)
        }
        
        self.titileLB.snp.makeConstraints { (make) in
            make.left.equalTo(self.view).offset(16)
            make.top.equalTo(self.view.snp.topMargin)
        }
                
        self.tableview.snp.makeConstraints { (make) in
            make.left.width.equalToSuperview()
            make.bottom.equalToSuperview()
            make.top.equalTo(self.view.snp.topMargin)
        }
		
		self.loadAnimationView.snp.makeConstraints { (make) in
			make.center.equalTo(self.view);
			make.size.equalTo(CGSize.init(width: 100, height: 100))
		}
		
		self.fetchLoadingView.snp.makeConstraints { (make) in
			make.size.equalTo(CGSize.init(width:AdaptScale(30), height: AdaptScale(30)))
			make.centerY.equalTo(self.titileLB);
			make.left.equalTo(self.titileLB.snp.right).offset(AdaptScale(20))
		}
    }
    
    func dw_addViews(){
        let layout = UICollectionViewFlowLayout.init()
        layout.itemSize = CGSize(width: 65, height: 65)
        layout.headerReferenceSize = CGSize(width: 95, height: 65)
        layout.scrollDirection = .horizontal
        self.collectionView = UICollectionView.init(frame: CGRect.init(x: 0, y: 0, width: kScreenWidth, height: 80), collectionViewLayout: layout)
        self.collectionView.showsHorizontalScrollIndicator = false
        let nib = UINib(nibName: String(describing: HomePodCollectionViewCell.self), bundle: nil)
        self.collectionView.register(nib, forCellWithReuseIdentifier: "cell")
        self.collectionView.register(HomePodListHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        self.collectionView.backgroundColor = .white
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        
        self.tableview = UITableView.init(frame: CGRect.zero, style: .plain)
        let cellnib = UINib(nibName: String(describing: HomeAlbumTableViewCell.self), bundle: nil)
		let adNib = UINib.init(nibName: String.init(describing: AdMobTableViewCell.self), bundle: nil)
        self.tableview.sectionHeaderHeight = 36
        self.tableview.register(cellnib, forCellReuseIdentifier: "tablecell")
		self.tableview.register(adNib, forCellReuseIdentifier: "adcell")
		self.tableview.backgroundColor = .clear
        self.tableview.separatorStyle = .none
        self.tableview.rowHeight = 100
        self.tableview.delegate = self
        self.tableview.dataSource = self
        self.tableview.showsVerticalScrollIndicator = false
        self.tableview.contentInset = UIEdgeInsets.init(top: 30.adapt(), left: 0, bottom: 120, right: 0)
        self.tableview.tableHeaderView = self.collectionView;
		self.tableview.isHidden = true
        
        self.searchBtn = UIButton.init(type: .custom)
        self.searchBtn.setBackgroundImage(UIImage.init(named: "search"), for: .normal)
        self.searchBtn.addTarget(self, action: #selector(toSearch), for:.touchUpInside)
		
		self.titileLB = UILabel.init(text: "最近更新".localized)
		self.titileLB.font = p_bfont(titleFontSize)
		self.titileLB.textColor = CommonColor.subtitle.color
        
        self.profileBtn = UIButton.init(type: .custom)
        self.profileBtn.setBackgroundImage(UIImage.init(named: "profile"), for: .normal)
        self.profileBtn.addTarget(self, action: #selector(toUserCenter), for:.touchUpInside)
		
		self.loadAnimationView = AnimationView(name: "refresh")
		self.loadAnimationView.loopMode = .loop;
		
		self.emptyAnimationView = AnimationView(name:"home_empty")
		self.emptyAnimationView.loopMode = .loop;
		
		self.addBtn = UIButton.init(type: .custom)
		addBtn.setTitle("发现播客".localized, for: .normal)
		addBtn.setTitleColor(.white, for: .normal)
		addBtn.backgroundColor = CommonColor.mainRed.color
		addBtn.cornerRadius = 15.0
		addBtn.titleLabel?.font = p_bfont(14);
		addBtn.addTarget(self, action: #selector(toSearch), for: .touchUpInside)
		addBtn.addShadow(ofColor: CommonColor.mainPink.color, radius: 16, offset: CGSize.init(width: 0, height: 9), opacity: 0.6)
		
		self.emptyView = UIView.init()
		emptyView.backgroundColor = .white
		emptyView.isHidden = true
		
		self.fetchLoadingView = NVActivityIndicatorView.init(frame: CGRect.zero, type: NVActivityIndicatorType.pacman, color: CommonColor.mainRed.color, padding: 2);
		self.view.addSubview(self.fetchLoadingView);
    }
    
}



// MARK: - 空页面 UI 布局
extension MainViewController {
	
	func addEmptyViews(){
		self.view.addSubview(self.emptyView)
		self.emptyView.snp.makeConstraints { (make) in
			make.left.width.bottom.equalToSuperview()
			make.top.equalTo(self.tableview)
		}
		
		self.emptyView.addSubview(self.emptyAnimationView)
		self.emptyAnimationView.snp.makeConstraints { (make) in
			make.centerX.equalToSuperview()
			make.centerY.equalToSuperview().offset(-50)
			make.size.equalTo(CGSize.init(width: kScreenWidth, height: AdaptScale(150)))
		}
		
		let label = UILabel.init(text: "快来添加你的第一个播客吧".localized)
		label.textColor = .lightGray
		label.font = pfont(14);
		self.emptyView.addSubview(label)
		label.snp.makeConstraints { (make) in
			make.centerX.equalToSuperview()
			make.top.equalTo(self.emptyAnimationView.snp.bottom).offset(15)
		}
		
		self.emptyView.addSubview(self.addBtn);
		self.addBtn.snp.makeConstraints { (make) in
			make.centerX.equalToSuperview()
			make.top.equalTo(label.snp.bottom).offset(40)
			make.width.equalTo(180)
			make.height.equalTo(50)
		}
		
		self.emptyAnimationView.play()
		
	}
	
}


