//
//  LoadMoreView.swift
//  iPets
//
//  Created by maocaiyuan on 16/3/24.
//  Copyright © 2016年 maocaiyuan. All rights reserved.
//

import UIKit

//上啦加载更多
protocol isLoadMoreDelegate {
    func loadingMore()
}

class LoadMoreView: UIView, UIScrollViewDelegate{
    
    let Width = UIScreen.main.bounds.width
    let Height = UIScreen.main.bounds.height
    
    let LoadMoreHeaderHeight: CGFloat = 50
    
    fileprivate var delegate: isLoadMoreDelegate?
    fileprivate var titleLabel: UILabel!
    fileprivate var scrollView: UIScrollView!
    fileprivate var actView: UIActivityIndicatorView?
    fileprivate var arrowImage: UIImageView?
    fileprivate var isRefreshing = false
    
    var refreshState: RefreshState?
    
    init(subView: UIScrollView, target: isLoadMoreDelegate) {
        
        super.init(frame: subView.frame)
        scrollView = subView
        self.delegate = target
        setupFooterView()
        designKFC()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //设置观察者
    func designKFC(){
        scrollView.addObserver(self, forKeyPath: "contentOffset", options: NSKeyValueObservingOptions.new, context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if(keyPath == "contentOffset"){
            scrollViewContentOffsetDidChange(scrollView);
        }
    }
    
    func removeOberver(){
        scrollView.removeObserver(self, forKeyPath: "contentOffset")
    }
    
    //底部刷新
    fileprivate func setupFooterView(){
        
        self.frame = CGRect(x: 0, y: scrollView.contentSize.height, width: Width, height: LoadMoreHeaderHeight)
        self.autoresizingMask = UIViewAutoresizing.flexibleWidth
        self.backgroundColor = UIColor.clear
        
        titleLabel = UILabel()
        titleLabel?.font = UIFont.systemFont(ofSize: 12)
        titleLabel?.textAlignment = NSTextAlignment.center
        titleLabel?.text = "上拉加载"
        
        actView = UIActivityIndicatorView()
        actView?.color = UIColor.gray
        
        arrowImage = UIImageView(image: UIImage(named: "pull_refresh"))
        self.arrowImage?.transform  = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
        
        self.addSubview(titleLabel!)
        self.addSubview(arrowImage!)
        self.addSubview(actView!)
        
        titleLabel.frame.size.width = 100
        titleLabel.frame.size.height = 30
        titleLabel.center = CGPoint(x: self.center.x, y: LoadMoreHeaderHeight-30)
        
        actView!.frame.size.width = 30
        actView!.frame.size.height = 30
        actView!.frame.origin.x = titleLabel.frame.minX - 30
        actView!.frame.origin.y = LoadMoreHeaderHeight-45
        
        arrowImage!.frame.size.width = 30
        arrowImage!.frame.size.height = 30
        arrowImage!.frame.origin.x = titleLabel.frame.minX - 30
        arrowImage!.frame.origin.y = LoadMoreHeaderHeight-45
    }
    
    func scrollViewContentOffsetDidChange(_ scrollView: UIScrollView) {
        
        let dragHeight = scrollView.contentOffset.y - scrollView.contentInset.bottom
        let tableHeigt = scrollView.contentSize.height - scrollView.frame.size.height
        
        if(dragHeight < tableHeigt || refreshState == RefreshState.refreshStateLoading){
            return
        }else{
            if(scrollView.isDragging){
                if(dragHeight < tableHeigt + LoadMoreHeaderHeight*0.4){
                    setRrefreshState(.refreshStateNormal)
                }else{
                    setRrefreshState(.refreshStatePulling)
                }
            }else{
                if(refreshState == RefreshState.refreshStatePulling){
                    setRrefreshState(.refreshStateLoading)
                }
            }
        }
    }
    
    func hideView(){
        self.removeFromSuperview()
    }
    
    //刷新状态变换
    func setRrefreshState(_ state: RefreshState){
        
        refreshState = state
        switch state{
        case .refreshStateNormal:
            
            arrowImage?.isHidden = false
            actView?.stopAnimating()
            titleLabel?.text = "上拉加载"
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                self.arrowImage?.transform  = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
            })
            break
        case .refreshStatePulling:
            titleLabel?.text = "松开加载"
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                self.arrowImage?.transform  = CGAffineTransform.identity
            })
            break
        case .refreshStateLoading:
            
            isRefreshing = true
            titleLabel?.text = "正在加载"
            arrowImage?.isHidden = true
            actView?.startAnimating()
            
            scrollView.isScrollEnabled = false
            
            //固定底部
            UIView.animate(withDuration: 0.2, delay: 0.2, options: .curveEaseInOut, animations: {
                self.scrollView.contentInset.bottom = self.scrollView.contentInset.bottom
            }, completion: { (done) in
                self.delegate?.loadingMore()
            })
        }
    }
    
    //开始刷新
    func startRefresh(){
        guard self.isRefreshing == false else{
            return
        }
        self.setRrefreshState(RefreshState.refreshStateLoading)
    }
    
    func endRefresh(){
        if refreshState == RefreshState.refreshStateLoading {
            setRrefreshState(.refreshStateNormal)
            self.scrollView.isScrollEnabled = true
            self.isRefreshing = false
        }
    }
}

