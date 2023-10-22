//
//  ListCell.swift
//  KDDragAndDropCollectionViews

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
        
        listTableView.backgroundColor = UIColor.lightGray
        headerView.backgroundColor = UIColor.lightGray
        
        updateListTableHight ()
        
      /*  let totalHight = self.frame.height
        var tableHeight = self.listTableView.contentSize.height
        let headerHeight = headerViewHeight.constant
        let footerHight = footerViewHight.constant
        
        if (tableHeight > (totalHight - headerHeight - footerHight)){
            tableHeight = totalHight - (headerHeight + footerHight)
        }
        
        let containerViewHeight = tableHeight + headerHeight + footerHight
        self.containerViewHeight.constant = containerViewHeight - 5

        
        let scrollSize = CGSize(width: self.frame.width, height: self.listTableView.contentSize.height)
        
        listTableView.contentSize = scrollSize

        listTableView.frame = CGRect(x:0,y:headerViewHeight.constant,width:self.bounds.width,height: tableHeight)
        
        listTableView.backgroundColor = UIColor.gray
        listTableView.contentSize = scrollSize
        listTableView.frame = CGRect(x:0,y:headerViewHeight.constant,width:self.bounds.width,height:self.listTableView.contentSize.height)
        */
    }
    
    func updateListTableHight () {
        let totalHight = self.frame.height
        var tableHeight = self.listTableView.contentSize.height
        let headerHeight = headerViewHeight.constant
        let footerHight = footerViewHight.constant
        
        if (tableHeight > (totalHight - headerHeight - footerHight)){
            tableHeight = totalHight - (headerHeight + footerHight)
        }
        
        listTableView.frame = CGRect(x:0,y:headerViewHeight.constant,width:self.bounds.width,height: tableHeight)
        containerViewHeight.constant = tableHeight + headerHeight + footerHight
        //listTableView.layoutIfNeeded()
        cellView.layoutIfNeeded()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.addSubview(listTableView)
        self.listTableView.dataSource = self
        listTableView.decelerationRate = UIScrollViewDecelerationRateFast
        listTableView.separatorStyle = .none
        // Initialization code
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
