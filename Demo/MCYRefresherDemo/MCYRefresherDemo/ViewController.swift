//
//  ViewController.swift
//  MCYRefresherDemo
//
//  Created by maocaiyuan on 2017/6/13.
//  Copyright © 2017年 maocaiyuan. All rights reserved.
//

import UIKit
import MCYRefresher

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let mainTabelView = UITableView()
    let Width = UIScreen.main.bounds.width
    let Height = UIScreen.main.bounds.height
    var dataSource = [String]()
    
    var refreshTime = 0
    
    var headerView: MCYRefreshView?
    var footerView: MCYLoadMoreView?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setData()
        self.setTableView()
    }
    
    func setTableView(){
        
        mainTabelView.frame = CGRect(x: 0, y: 0, width: Width, height: Height)
        mainTabelView.backgroundColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
        mainTabelView.showsHorizontalScrollIndicator = false
        mainTabelView.tableFooterView = UIView(frame: CGRect.zero)
        mainTabelView.delegate = self
        mainTabelView.dataSource = self
        self.view.addSubview(mainTabelView)
        
        headerView = MCYRefreshView(subView: mainTabelView, target: self, imageName: "pull_refresh")
        footerView = MCYLoadMoreView(subView: mainTabelView, target: self, imageName: "pull_refresh")
        mainTabelView.tableFooterView = footerView
    }
    
    func setData(){
        dataSource = [String]()
        for i in refreshTime ..< refreshTime+20{
            dataSource.append(String(i))
        }
        refreshTime += 20
    }
    
    func loadMoreData(){
        for i in refreshTime ..< refreshTime+20{
            dataSource.append(String(i))
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    //每个cell内容
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellId = "cell"
        let cell =  UITableViewCell(style: .default, reuseIdentifier: cellId)
        cell.textLabel?.text = dataSource[indexPath.row]
        return cell
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension ViewController: MCYRefreshViewDelegate{
    //isfreshing中的代理方法
    func reFreshing(){
        
        self.setData()
        self.mainTabelView.reloadData()
        self.headerView?.endRefresh()
    }
}

extension ViewController: MCYLoadMoreViewDelegate{
    //isLoadMore中的代理方法
    func loadingMore(){
        //这里做你想做的事
        self.loadMoreData()
        self.mainTabelView.reloadData()
        self.footerView?.endRefresh()
    }
}

