//
//  ListCell.swift
//  KDDragAndDropCollectionViews
//
//  Created by Joshua O'Connor on 2/13/17.
//  Copyright © 2017 Karmadust. All rights reserved.
//

import Foundation
import UIKit




class ListCell: UICollectionViewCell, UITableViewDataSource {
    
    @IBOutlet weak var listTableView: UITableView!
    
    var inBetweenDataSource:InBetweenCollectionViewCellTableDataSource?
    
    @IBOutlet weak var cellView: UIView!
    
    @IBOutlet private weak var headerView: UIView!
    
    @IBOutlet weak var containerViewHeight: NSLayoutConstraint!
    
    @IBOutlet private weak var footerView: UIView!
    
    @IBOutlet weak var headerViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var footerViewHight: NSLayoutConstraint!
    var passedHeaderView: UIView?
    var passedFooterView: UIView?
    override func layoutSubviews() {
        
        cellView.layer.cornerRadius = 10
        
        super.layoutSubviews()

        for subUIView in headerView.subviews as [UIView] {
            subUIView.removeFromSuperview()
        }
        for subUIView in footerView.subviews as [UIView] {
            subUIView.removeFromSuperview()
        }
        
        let listTableTag = listTableView.tag
        
        if let passedHeaderView = self.passedHeaderView {
            
            headerViewHeight.constant = (inBetweenDataSource?.InBetweenTableView(headerHeightIn: listTableTag))!
            headerView.layoutIfNeeded()
            passedHeaderView.frame = CGRect(origin:headerView.bounds.origin, size:CGSize(width:headerView.bounds.width,height:headerViewHeight.constant))
            headerView.addSubview(passedHeaderView)
        }
        
        
        if let passedFooterView = self.passedFooterView {
            
            footerViewHight.constant = (inBetweenDataSource?.InBetweenTableView(footerHeightIn: listTableTag))!
            footerView.layoutIfNeeded()
            passedFooterView.frame = CGRect(origin:footerView.bounds.origin, size:CGSize(width:footerView.bounds.width,height:footerViewHight.constant))
            footerView.addSubview(passedFooterView)
        }
        
        listTableView.backgroundColor = UIColor(colorLiteralRed: 230.0/256.0, green: 230.0/256.0, blue: 230/256.0, alpha: 1.0)
        headerView.backgroundColor = UIColor(colorLiteralRed: 230.0/256.0, green: 230.0/256.0, blue: 230/256.0, alpha: 1.0)
        
        updateListTableHight ()
        
    }
    
    func updateListTableHight () {
        listTableView.layoutIfNeeded()

        let totalHight = self.bounds.height
        var tableHeight = self.listTableView.contentSize.height + 20
        let headerHeight = headerViewHeight.constant
        let footerHight = footerViewHight.constant
        
        if (tableHeight > (totalHight - headerHeight - footerHight)){
            tableHeight = totalHight - (headerHeight + footerHight)
        }

        DispatchQueue.main.async(execute: {
            self.listTableView.frame = CGRect(x:0,y:self.headerViewHeight.constant,width:self.bounds.width,height: tableHeight)
            self.containerViewHeight.constant = tableHeight + headerHeight + footerHight - 5
            self.listTableView.layoutIfNeeded()
        })
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.addSubview(listTableView)
        self.listTableView.dataSource = self

        listTableView.addObserver(self, forKeyPath: "contentSize", options: [.old, .new], context: nil)
        listTableView.decelerationRate = UIScrollViewDecelerationRateFast
        listTableView.separatorStyle = .none
        // Initialization code
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        self.updateListTableHight()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (inBetweenDataSource?.InBetweenTableView( numberOfRowsInSection:listTableView.tag))!
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        return (inBetweenDataSource?.InBetweenTableView(cellForRowAt:IndexPath(row:indexPath.row ,section:listTableView.tag) ))!
    }
    
       
}
