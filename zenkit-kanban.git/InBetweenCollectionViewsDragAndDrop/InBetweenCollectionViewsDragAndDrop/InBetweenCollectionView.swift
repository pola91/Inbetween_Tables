//
//  InBetweenCollectionView.swift
//  InBetweenCollectionViewsDragAndDrop
//
//  Created by Jean Joseph on 9/13/17.
//  Copyright © 2017 Jean Joseph. All rights reserved.
//

import UIKit

protocol InBetweenCollectionViewCellTableDataSource {
    
    func InBetweenTableView(cellForRowAt indexPath: IndexPath) -> UITableViewCell
    func InBetweenTableView(deleteItemAt indexPath: IndexPath)
    func InBetweenTableView(insertItemAt indexPath: IndexPath)
    func InBetweenTableView(insertDummmyItemWhenHoveringAt indexPath: IndexPath)
    func InBetweenTableView(removeDummmyItemWhenHoveringAt indexPath: IndexPath)
    func InBetweenTableView(numberOfRowsInSection section: Int) -> Int
    func InBetweenTableView(headerHeightIn section: Int) -> CGFloat
    func InBetweenTableView(footerHeightIn section: Int) -> CGFloat
    func InBetweenTableView(headerViewIn section: Int) -> UIView
    func InBetweenTableView(footerViewIn section: Int) -> UIView
    func numberOfSections() -> Int
    
}
enum ScrollingDirection{
    case up
    case down
    case left
    case right
    case none
    
}
class InBetweenCollectionView: UICollectionView,UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    let listCellNibName = "ListCell"
    let listCellIdentifier = "list_cell"
    let fixedRowIndex = 0
    let fixedSectionIndex = 0
    let animationDuration = 0.25
    let collectionScrollingAnimationDuration = 0.015
    let tableScrollingAnimationDuration = 0.015
    let leftScrollingOffset = CGFloat(-9)
    let rightScrollingOffset = CGFloat(9)
    let upScrollingOffset = CGFloat(-5)
    let downScrollingOffset = CGFloat(5)
    
    let cellWidth = CGFloat(300)
    let dummyTableView = UITableView()
    
    var inBetweenDataSource:InBetweenCollectionViewCellTableDataSource?
    var headerHeightDictionary = Dictionary<Int, CGFloat>()
    
    var cellSnapshot: UIView?
    var dummyCellInsertedNotRemovedYet = false
    
    var currentDummyIndexPath: IndexPath?
    
    var olderDraggingGestureLocation: CGPoint? //dragging gesture before current location
    var lastChildIndexPath: IndexPath?  //the last indexPath where the cell was dragged near
    var lastParentIndexPath: IndexPath?  //the last indexPath of the parent cell where the cell was dragged near
    var lastDisplacedIndexPath: IndexPath?  //the last combined indexPath of the unity cell where the cell was dragged near
    var lastCellTableViewLocation: CGPoint? //cell location of last valid Indexpath
    var draggingSigma: CGPoint?
    
    fileprivate var rightScrollDetectorRect : CGRect?
    fileprivate var leftScrollDetectorRect : CGRect?
    fileprivate var upScrollDetectorRect : CGRect?
    fileprivate var downScrollDetectorRect : CGRect?
    let horizontalRectMargin = CGFloat(0.15)
    let verticalRectHeight = CGFloat(150)
    
    var longPressGesture:UILongPressGestureRecognizer?
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let nib = UINib(nibName: listCellNibName, bundle: nil)
        self.register(nib, forCellWithReuseIdentifier: listCellIdentifier)
        commonInit()
    }
    
    
    private func commonInit(){
        self.dataSource = self
        self.delegate = self
        self.contentInset = UIEdgeInsets(top:10, left:10, bottom:10, right:10)
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.longPressGestureRecognized(_:)))
        self.addGestureRecognizer(longPressGesture!)
        setDraggingRects()
    }
    
    
    private func setDraggingRects(){
        
        rightScrollDetectorRect = CGRect(x:(1-horizontalRectMargin)*UIScreen.main.bounds.width,y:verticalRectHeight + self.frame.origin.y ,width:horizontalRectMargin*UIScreen.main.bounds.width,height:self.frame.height - 2*verticalRectHeight)
        
        leftScrollDetectorRect = CGRect(x:0, y:verticalRectHeight + self.frame.origin.y, width:horizontalRectMargin*UIScreen.main.bounds.width, height:self.frame.height - 2*verticalRectHeight)
        
        upScrollDetectorRect = CGRect(x:0, y:self.frame.origin.y, width:UIScreen.main.bounds.width,height:verticalRectHeight)
        
        downScrollDetectorRect = CGRect(x:0,y:self.frame.height - verticalRectHeight,width:UIScreen.main.bounds.width,height:verticalRectHeight)
    }
    
    
    func longPressGestureRecognized(_ gestureRecognizer: UILongPressGestureRecognizer) {
        let state = gestureRecognizer.state
        let locationInView = gestureRecognizer.location(in: self)
        let indexPath = self.indexPathForItem(at: locationInView) ?? nil
        var parentCell:ListCell!
        var locationInCellTableView:CGPoint!
        var childIndexPath :IndexPath!
        var childCell:UITableViewCell!
        let locationInScreen = gestureRecognizer.location(in: self.window)
        
        if(indexPath != nil){
            parentCell = self.cellForItem(at: indexPath!) as? ListCell
            locationInCellTableView = gestureRecognizer.location(in: parentCell?.listTableView)
            if let chIndexPath = parentCell?.listTableView.indexPathForRow(at: locationInCellTableView!){
                childIndexPath = chIndexPath
                childCell = parentCell?.listTableView.cellForRow(at: childIndexPath!)
                lastCellTableViewLocation = locationInView
            }else if(parentCell.listTableView.indexPathsForVisibleRows?.count == parentCell.listTableView.numberOfRows(inSection: fixedSectionIndex)){
                var rowIndex = parentCell.listTableView.numberOfRows(inSection: fixedSectionIndex) - 1
                if(rowIndex<0){
                    rowIndex = 0
                }
                childIndexPath = IndexPath(row:rowIndex,section:fixedSectionIndex)
                childCell = parentCell?.listTableView.cellForRow(at: childIndexPath!)
                lastCellTableViewLocation = locationInView
            }else if(parentCell.listTableView.indexPathsForVisibleRows?.count == 0 ){
                childIndexPath = IndexPath(row:fixedRowIndex,section:(indexPath?.section)!)
                childCell = parentCell?.listTableView.cellForRow(at: childIndexPath!)
                lastCellTableViewLocation = locationInView
            }
        }
        
        setDraggingRects()
        
        switch state {
        case .began:
            if((indexPath != nil)  && (childIndexPath != nil) ){
                gestureBegin(at: childIndexPath, and: indexPath!, where: childCell, for: locationInView)
            }
            
        case .changed:
            if(indexPath != nil && childIndexPath != nil && cellSnapshot != nil){
                let displacedIndexPath = IndexPath(row:(childIndexPath?.row)!,section:(indexPath!.section))
                if(indexPath != lastParentIndexPath || childIndexPath != lastChildIndexPath){
                    displaceCell(at: displacedIndexPath)
                }
                updateDraggingParameters(at: displacedIndexPath)
            }
            gestureChanged(with: indexPath ?? lastParentIndexPath, and: childIndexPath ?? lastChildIndexPath, at: locationInView, and: locationInScreen)
            
        case .ended:
            gestureEnding()
        case .cancelled, .failed, .possible:
            haltScrolling()
        }
        olderDraggingGestureLocation = gestureRecognizer.location(in: self)
        
    }
    
    private func gestureBegin(at childIndexPath: IndexPath,and parentIndexPath: IndexPath, where childCell: UITableViewCell, for locationInView:CGPoint){
        let draggingPoint = self.convert(locationInView, to: childCell)
        let cellCenter = CGPoint(x: childCell.bounds.width/2,y: childCell.bounds.height/2)
        draggingSigma = CGPoint(x:draggingPoint.x - cellCenter.x, y:draggingPoint.y - cellCenter.y)
        let center = CGPoint(x:locationInView.x - (draggingSigma?.x)!, y:locationInView.y - (draggingSigma?.y)!)
        setSnapshot(of: childCell, withCenter:center)
        selectDraggedItem(at :parentIndexPath, and :childIndexPath)
        let displacedIndexPath = IndexPath(row:(childIndexPath.row),section:(parentIndexPath.section))
        displaceCell(at: displacedIndexPath)
        updateDraggingParameters(at: displacedIndexPath)
    }
    
    private func dragArround(draggingPoint: CGPoint){
        if(cellSnapshot != nil){
            let center = CGPoint(x:draggingPoint.x - (draggingSigma?.x)!, y:draggingPoint.y - (draggingSigma?.y)!)
            self.cellSnapshot?.center = center
        }
    }
    private func selectDraggedItem(at parentIndexPath:IndexPath, and childIndexPath: IndexPath){
        let initialParentCell = self.cellForItem(at: parentIndexPath) as? ListCell
        let draggedIndexPath = IndexPath(row:(childIndexPath.row),section:(parentIndexPath.section))
        initialParentCell?.listTableView.beginUpdates()
        inBetweenDataSource?.InBetweenTableView(deleteItemAt: draggedIndexPath)
        initialParentCell?.listTableView.deleteRows(at: [childIndexPath], with: .none)
        initialParentCell?.listTableView.endUpdates()
    }
    
    
    private func gestureChanged(with parentIndexPath:IndexPath?, and childIndexPath: IndexPath?, at locationInCollectionView:CGPoint, and locationInWindow:CGPoint){
        if(lastChildIndexPath != nil && lastParentIndexPath != nil){
            calculateScrollingDirection(locationInWindow: locationInWindow)
            scrollAround(parentIndexPath: parentIndexPath!, childIndexPath: childIndexPath!)
            if(!isCollectionViewScrolling){
                self.dragArround(draggingPoint:locationInCollectionView)
            }
        }
    }
    
    private func updateDraggingParameters(at displacedIndexPath:IndexPath){
        lastDisplacedIndexPath = displacedIndexPath
        lastParentIndexPath = IndexPath(row:fixedRowIndex,section:displacedIndexPath.section)
        lastChildIndexPath = IndexPath(row:displacedIndexPath.row,section:fixedSectionIndex)
    }
    
    private func gestureEnding(){
        if(lastParentIndexPath != nil && lastChildIndexPath != nil){
            removeDummyCell()
            dropItem()
            animateCellDropping()
        }
        haltScrolling()
        resetDraggingGesture()
    }
    
    private func dropItem(){
        let finalParentCell = self.cellForItem(at: lastParentIndexPath!) as? ListCell
        finalParentCell?.listTableView.beginUpdates()
        inBetweenDataSource?.InBetweenTableView(insertItemAt: IndexPath(row:(lastChildIndexPath?.row)!,section:(lastParentIndexPath?.section)!))
        finalParentCell?.listTableView.insertRows(at: [lastChildIndexPath!], with: .none)
        finalParentCell?.listTableView.endUpdates()
        if ((finalParentCell?.listTableView.numberOfRows(inSection: fixedSectionIndex))! == ((lastChildIndexPath?.row)! + 1)){
            finalParentCell?.listTableView.scrollToRow(at: lastChildIndexPath!, at: .bottom, animated: true)
        }
        finalParentCell?.updateListTableHight()
    }
    
    
    private func setSnapshot(of cell:UITableViewCell, withCenter center:CGPoint){
        self.cellSnapshot = snapshotOfCell(cell)
        self.cellSnapshot!.center = center
        self.addSubview(self.cellSnapshot!)
        cell.isHidden = true
    }
    
    private func displaceCell(at combinedIndexPath:IndexPath){
        removeDummyCell()
        insertDummyCell(at: combinedIndexPath)
    }
    
    private func insertDummyCell(at combinedIndexPath:IndexPath){
        if(!dummyCellInsertedNotRemovedYet){
            let finalParentCell = self.cellForItem(at: IndexPath(row:fixedRowIndex,section:combinedIndexPath.section)) as? ListCell
            finalParentCell?.listTableView.beginUpdates()
            inBetweenDataSource?.InBetweenTableView(insertDummmyItemWhenHoveringAt: combinedIndexPath)
            finalParentCell?.listTableView.insertRows(at: [ IndexPath(row:combinedIndexPath.row,section:fixedSectionIndex)], with: .none)
            currentDummyIndexPath = IndexPath(row:combinedIndexPath.row,section:fixedSectionIndex)
            finalParentCell?.listTableView.endUpdates()
            finalParentCell?.updateListTableHight()
            dummyCellInsertedNotRemovedYet = true
        }
    }
    
    private func removeDummyCell(){
        if( dummyCellInsertedNotRemovedYet){
            if let finalParentCell = self.cellForItem(at: lastParentIndexPath!) as? ListCell{
                removeCell(from: (finalParentCell.listTableView)!)
                finalParentCell.updateListTableHight()
                dummyCellInsertedNotRemovedYet = false
            }
        }
    }
    
    private func removeCell(from tableView:UITableView){
        tableView.beginUpdates()
        inBetweenDataSource?.InBetweenTableView(removeDummmyItemWhenHoveringAt: lastDisplacedIndexPath!)
        tableView.deleteRows(at: [lastChildIndexPath!], with: .none)
        tableView.endUpdates()

    }
    
    
    private func animateCellDropping(){
        UIView.animate(withDuration: animationDuration, animations: { () -> Void in
            self.cellSnapshot?.center = self.lastCellTableViewLocation!
        }, completion: { (finished) -> Void in
            if finished {
                self.resetDraggedCellSnapshot()
            }
        })
    }
    
    private func resetDraggingGesture(){
        lastDisplacedIndexPath = nil
        lastChildIndexPath = nil
        lastParentIndexPath = nil
    }
    
    private func resetDraggedCellSnapshot(){
        self.lastCellTableViewLocation = nil
        self.cellSnapshot?.removeFromSuperview()
        self.cellSnapshot = nil
        
    }
    
    private func calculateScrollingDirection(locationInWindow: CGPoint){
        if( rightScrollDetectorRect!.contains(locationInWindow)){
            currentScrollingDirection = .right
            return
        }
        
        if( leftScrollDetectorRect!.contains(locationInWindow)){
            currentScrollingDirection = .left
            return
        }
        
        if( upScrollDetectorRect!.contains(locationInWindow)){
            currentScrollingDirection = .up
            return
        }
        
        if( downScrollDetectorRect!.contains(locationInWindow)){
            currentScrollingDirection = .down
            return
        }
        currentScrollingDirection = .none
        
    }
    
    var isCollectionViewScrolling = false
    var currentScrollingDirection: ScrollingDirection = .none
    private func scrollAround(parentIndexPath: IndexPath, childIndexPath: IndexPath){
        let combinedIndexPath = IndexPath(row:(childIndexPath.row),section:(parentIndexPath.section))
        switch currentScrollingDirection {
        case .down:
            scrollVertically(from: combinedIndexPath, by: downScrollingOffset)
        case .up:
            scrollVertically(from: combinedIndexPath, by: upScrollingOffset)
        case .left:
            scrollHorizontally(by: leftScrollingOffset)
        case .right:
            scrollHorizontally(by: rightScrollingOffset)
        case .none:
            haltScrolling()
        }
    }
    
    
    private func scrollVertically(from combinedIndexPath:IndexPath, by offset:CGFloat){
        let parentIndexPath = IndexPath(row:fixedRowIndex,section:combinedIndexPath.section)
        let childIndexPath = IndexPath(row:combinedIndexPath.row,section:fixedSectionIndex)
        let parentCell = self.cellForItem(at: parentIndexPath) as! ListCell
        let newIndexPath = IndexPath(row:childIndexPath.row + Int(offset/fabs(offset)), section: childIndexPath.section)
        let parentCellTable = parentCell.listTableView
        if(tableHasRowAtIndexPath(table: parentCellTable!, indexPath: newIndexPath) && (parentCellTable?.indexPathsForVisibleRows?.last == childIndexPath || parentCellTable?.indexPathsForVisibleRows?.first == childIndexPath)){
            scroll(tableView: parentCellTable!, by: offset)
        }
    }
    
    
    private func scrollHorizontally(by offset:CGFloat){
        if(!isCollectionViewScrolling){
            isCollectionViewScrolling = true
            let scrollerContentOffset = self.contentOffset
            
            UIView.animate(withDuration: collectionScrollingAnimationDuration, animations: { () -> Void in
                let newOffset = CGPoint(x:scrollerContentOffset.x + offset,y:scrollerContentOffset.y)
                let gestureLocation = self.longPressGesture?.location(in: self)
                let contentBoundary = CGSize(width:self.contentSize.width - 100, height:self.contentSize.height)
                let tableContentFrame = CGRect(origin:CGPoint(x:50,y:0), size:contentBoundary)
                if(tableContentFrame.contains(gestureLocation!)){
                    self.setContentOffset(newOffset, animated: false)
                    self.dragArround(draggingPoint: gestureLocation!)
                }else{
                    self.haltScrolling()
                }
                
            }, completion: { (finished) -> Void in
                if finished {
                    self.isCollectionViewScrolling = false
                    switch self.currentScrollingDirection{
                    case .up, .down, .none:
                        self.haltScrolling()
                    case .left, .right:
                        self.scrollHorizontally(by: offset)
                    }
                }
            })
        }
    }
    
    private func scroll(tableView:UITableView, by offset:CGFloat){
        if(!isCollectionViewScrolling){
            isCollectionViewScrolling = true
            let tableContentOffset = tableView.contentOffset
            UIView.animate(withDuration: tableScrollingAnimationDuration, animations: { () -> Void in
                let newOffset = CGPoint(x:tableContentOffset.x ,y:tableContentOffset.y + offset)
                let gestureLocation = self.longPressGesture?.location(in: tableView)
                let tableContentFrame = CGRect(origin:CGPoint(x:0,y:0), size:tableView.contentSize)
                if(tableContentFrame.contains(gestureLocation!)){
                    tableView.setContentOffset(newOffset, animated: false)
                    let gestureLocationInCollectionView = self.longPressGesture?.location(in: self)
                    self.dragArround(draggingPoint: gestureLocationInCollectionView!)
                }else{
                    self.haltScrolling()
                }
            }, completion: { (finished) -> Void in
                if finished {
                    self.isCollectionViewScrolling = false
                    switch self.currentScrollingDirection{
                    case .up, .down:
                        self.scroll(tableView: tableView, by: offset)
                    case .left, .right, .none:
                        self.haltScrolling()
                        
                    }
                }
            })
        }
    }
    
    
    private func haltScrolling(){
        currentScrollingDirection = .none
        isCollectionViewScrolling = false
    }
    
    
    private func snapshotOfCell(_ inputView: UIView) -> UIView {
        UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, 0.0)
        inputView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()! as UIImage
        UIGraphicsEndImageContext()
        
        let cellSnapshot : UIView = UIImageView(image: image)
        cellSnapshot.layer.masksToBounds = false
        cellSnapshot.layer.cornerRadius = 0.0
        cellSnapshot.layer.shadowOffset = CGSize(width: -5.0, height: 0.0)
        cellSnapshot.layer.shadowRadius = 5.0
        cellSnapshot.layer.shadowOpacity = 0.4
        return cellSnapshot
    }
    
    func collectionHasRowAtIndexPath(indexPath: IndexPath) -> Bool {
        return indexPath.section < self.numberOfSections &&  0 <= indexPath.section && indexPath.row < self.numberOfItems(inSection: indexPath.section)
    }
    
    func tableHasRowAtIndexPath(table tableView: UITableView, indexPath: IndexPath) -> Bool {
        return indexPath.section < tableView.numberOfSections && indexPath.row < tableView.numberOfRows(inSection: indexPath.section) && 0 <= indexPath.row
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        headerHeightDictionary[indexPath.section] = (inBetweenDataSource?.InBetweenTableView(headerHeightIn: indexPath.section))!
        
        let cellWidth : CGFloat = self.cellWidth
        let cellheight : CGFloat = self.bounds.height -  90
        return CGSize(width: cellWidth , height:cellheight)
    }
    
    func register(unityCell:UINib, with identifier:String){
        dummyTableView.register(unityCell, forCellReuseIdentifier: identifier)
    }
    
    func dequeuUnityCell(with identifier:String)->UITableViewCell{
        return (dummyTableView.dequeueReusableCell(withIdentifier: identifier))!
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return (inBetweenDataSource?.numberOfSections())!
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell =  collectionView.dequeueReusableCell(withReuseIdentifier:listCellIdentifier, for: indexPath) as? ListCell
        cell?.layer.shouldRasterize = true;
        cell?.layer.rasterizationScale = UIScreen.main.scale;
        cell?.inBetweenDataSource = inBetweenDataSource
        cell?.passedFooterView = inBetweenDataSource?.InBetweenTableView(footerViewIn: indexPath.section)
        cell?.passedHeaderView = inBetweenDataSource?.InBetweenTableView(headerViewIn: indexPath.section)
        cell?.backgroundColor = UIColor.clear
        cell?.listTableView.tag = indexPath.section
        cell?.listTableView.reloadData()
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.deselectItem(at: indexPath, animated: true)
    }
    
    
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
}
