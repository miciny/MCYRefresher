//
//  LoadMoreView.swift
//  iPets
//
//  Created by maocaiyuan on 16/3/24.
//  Copyright © 2016年 maocaiyuan. All rights reserved.
//

import UIKit

//上拉加载更多
public protocol MCYLoadMoreViewDelegate {
    func loadingMore()
}


public class MCYLoadMoreView: UIView, UIScrollViewDelegate{
    
    let Width = UIScreen.main.bounds.width
    let Height = UIScreen.main.bounds.height
    let LoadMoreHeaderHeight: CGFloat = 50
    
    fileprivate var imageName: String!
    fileprivate var delegate: MCYLoadMoreViewDelegate?
    fileprivate var titleLabel: UILabel!
    fileprivate var scrollView: UIScrollView!
    fileprivate var actView: UIActivityIndicatorView?
    fileprivate var arrowImage: UIImageView?
    fileprivate var isRefreshing = false
    
    public var refreshState: MCYRefreshState?
    
    public init(subView: UIScrollView, target: MCYLoadMoreViewDelegate, imageName: String) {
        
        super.init(frame: subView.frame)
        self.scrollView = subView
        self.delegate = target
        self.imageName = imageName
        
        setupFooterView()
        designKFC()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    public func endRefresh(){
        if refreshState == MCYRefreshState.refreshStateLoading {
            setRrefreshState(.refreshStateNormal)
            self.scrollView.isScrollEnabled = true
            self.isRefreshing = false
        }
    }
    
    
    
    public func hideView(){
        self.endRefresh()
        self.removeOberver()
        self.removeFromSuperview()
    }
    
    
    //开始刷新
    public func startRefresh(){
        guard self.isRefreshing == false else{
            return
        }
        self.setRrefreshState(MCYRefreshState.refreshStateLoading)
    }
    
    //设置观察者
    fileprivate func designKFC(){
        scrollView.addObserver(self, forKeyPath: "contentOffset", options: NSKeyValueObservingOptions.new, context: nil)
    }
    
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if(keyPath == "contentOffset"){
            scrollViewContentOffsetDidChange(scrollView);
        }
    }
    
    fileprivate func removeOberver(){
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
        
        arrowImage = UIImageView(image: UIImage(named: self.imageName))
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
    
    fileprivate func scrollViewContentOffsetDidChange(_ scrollView: UIScrollView) {
        
        let dragHeight = scrollView.contentOffset.y - scrollView.contentInset.bottom
        let tableHeigt = scrollView.contentSize.height - scrollView.frame.size.height
        
        if(dragHeight < tableHeigt || refreshState == MCYRefreshState.refreshStateLoading){
            return
        }else{
            if(scrollView.isDragging){
                if(dragHeight < tableHeigt + LoadMoreHeaderHeight*0.4){
                    setRrefreshState(.refreshStateNormal)
                }else{
                    setRrefreshState(.refreshStatePulling)
                }
            }else{
                if(refreshState == MCYRefreshState.refreshStatePulling){
                    setRrefreshState(.refreshStateLoading)
                }
            }
        }
    }
    
    //刷新状态变换
    fileprivate func setRrefreshState(_ state: MCYRefreshState){
        
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
}

