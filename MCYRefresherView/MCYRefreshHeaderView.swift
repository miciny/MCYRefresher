//
//  MyRefreshView.swift
//  MostWanted
//
//  Created by maocaiyuan on 16/3/15.
//  Copyright © 2016年 maocaiyuan. All rights reserved.
//

import UIKit

//下拉刷新的代理
public protocol MCYRefreshViewDelegate{
    func reFreshing()
}

public enum MCYRefreshState{
    case  refreshStateNormal //正常
    case  refreshStatePulling //正在下啦
    case  refreshStateLoading //正在加载
}

public class MCYRefreshView: UIView{
    
    public var refreshState: MCYRefreshState?
    
    fileprivate var imageName: String!
    fileprivate var delegate: MCYRefreshViewDelegate?
    fileprivate let RefreshHeaderHeight: CGFloat = 64 //高度
    fileprivate var titleLabel: UILabel!
    fileprivate var scrollView: UIScrollView!
    fileprivate var actView: UIActivityIndicatorView?
    fileprivate var arrowImage: UIImageView?
    fileprivate var isRefreshing = false
    
    public init(subView: UIScrollView, target: MCYRefreshViewDelegate, imageName: String){
        super.init(frame: subView.frame)
        scrollView = subView
        self.delegate = target
        self.refreshState = MCYRefreshState.refreshStateNormal
        self.imageName = imageName
        
        initUI()
        designKFC()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //结束刷新
    public func endRefresh(){
        if refreshState == MCYRefreshState.refreshStateLoading {
            setRrefreshState(.refreshStateNormal)
            self.scrollView.isScrollEnabled = true
            
            //动画返回
            UIView.animate(withDuration: 0.3, delay: 0.4, options: .curveEaseInOut, animations: {
                self.scrollView.contentInset.top = -self.RefreshHeaderHeight + self.getInsetTop()
            }, completion: { (done) in
                self.isRefreshing = false
            })
        }
    }
    
    //开始刷新 可以手动调用
    public func startRefresh(){
        guard self.isRefreshing == false else{
            return
        }
        //此处不宜有动画
        self.scrollView.contentOffset = CGPoint(x: 0, y: -(self.getInsetTop() + self.RefreshHeaderHeight))
        self.setRrefreshState(MCYRefreshState.refreshStateLoading)
    }
    
    
    //设置观察者
    fileprivate func designKFC(){
        scrollView.addObserver(self, forKeyPath: "contentOffset", options: NSKeyValueObservingOptions.new, context: nil)
    }
    
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if(keyPath == "contentOffset"){
            scrollViewContentOffsetDidChange(scrollView)
        }
    }
    
    func removeOberver(){
        scrollView.removeObserver(self, forKeyPath: "contentOffset")
    }
    
    //设置页面
    fileprivate func initUI(){
        
        self.frame = CGRect(x: 0, y: -RefreshHeaderHeight, width: scrollView.frame.width, height: RefreshHeaderHeight)
        self.backgroundColor = UIColor.clear
        scrollView.addSubview(self)
        
        titleLabel = UILabel()
        titleLabel?.font = UIFont.systemFont(ofSize: 12)
        titleLabel?.textAlignment = .center
        titleLabel?.text = "下拉刷新"
        
        actView = UIActivityIndicatorView()
        actView?.color = UIColor.gray
        
        arrowImage = UIImageView(image: UIImage(named: self.imageName))
        
        self.addSubview(titleLabel!)
        self.addSubview(arrowImage!)
        self.addSubview(actView!)
        
        titleLabel.frame.size.width = 100
        titleLabel.frame.size.height = 30
        titleLabel.center = CGPoint(x: self.center.x, y: RefreshHeaderHeight-30)
        
        actView!.frame.size.width = 30
        actView!.frame.size.height = 30
        actView!.frame.origin.x = titleLabel.frame.minX - 30
        actView!.frame.origin.y = RefreshHeaderHeight-45
        
        arrowImage!.frame.size.width = 30
        arrowImage!.frame.size.height = 30
        arrowImage!.frame.origin.x = titleLabel.frame.minX - 30
        arrowImage!.frame.origin.y = RefreshHeaderHeight-45
        
    }
    
    
    fileprivate func scrollViewContentOffsetDidChange(_ scrollView: UIScrollView) {
        
        if(dragHeight() < 0 || refreshState == MCYRefreshState.refreshStateLoading ){
            return
        }else{
            if(scrollView.isDragging){
                if(dragHeight() < RefreshHeaderHeight){
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
            titleLabel?.text = "下拉刷新"
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                self.arrowImage?.transform  = CGAffineTransform.identity
            })
            break
            
        case .refreshStatePulling:
            titleLabel?.text = "松开刷新"
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                self.arrowImage?.transform  = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
            })
            break
            
        case .refreshStateLoading:
            isRefreshing = true
            titleLabel?.text = "正在刷新"
            arrowImage?.isHidden = true
            actView?.startAnimating()
            
            scrollView.isScrollEnabled = false
            //固定顶部
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
                self.scrollView.contentInset.top = self.RefreshHeaderHeight + self.getInsetTop()
            }, completion: { (done) in
                self.delegate?.reFreshing()
            })
            
            break
        }
    }
    
    
    //计算拉的高度
    fileprivate func dragHeight()->CGFloat{
        return  -(scrollView.contentOffset.y + getInsetTop())
    }
    
    fileprivate func getInsetTop() -> CGFloat{
        return scrollView.contentInset.top
    }
    
}

