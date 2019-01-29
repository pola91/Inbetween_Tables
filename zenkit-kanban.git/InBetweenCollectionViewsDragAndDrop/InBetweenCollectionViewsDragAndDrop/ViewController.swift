//
//  ViewController.swift
//  InBetweenCollectionViewsDragAndDrop
//
//  Created by Jean Joseph on 9/13/17.
//  Copyright © 2017 Jean Joseph. All rights reserved.
//

import UIKit

class ViewController: UIViewController, InBetweenCollectionViewCellTableDataSource, UICollectionViewDelegate {
    var dataList = [[String]]()
    var headerList = [String]()

    @IBOutlet weak var inBetweenCollection: InBetweenCollectionView!
    
        func setUpCollectionViewData(){
        dataList = [["Red", "Blue", "Green", "Brown", "Black", "Purple", "Orange", "Gray", "White", "Yellow", "Teal", "Magenta"]
                        ,["Korean War", "WWI", "WWII", "Mexican Revolution", "Brooks-Baxter War", "Greek Punic Wars", "First Crusade", "Russian Revolution", "Vietnam War", "Gulf War"]
                        ,["Captain Crunch", "Reeses Puff", "Fruit Loops", "Fruity Pebbles", "Cocoa Puffs", "Raisin Bran", "Honey Nut Cheerios", "Apple Jacks", "Cinnamon Toast Crunch"]
                        ,["Oakland Raiders", "New England Patriots", "Carolina Panthers", "Green Bay Packers", "San Francisco 49ers", "San Diego Chargers", "Denver Broncos", "Detroit Lions", "Seattle Seahawks", "Minnesota Vikings", "Atlanta Falcons"]
                        ,["United States of America", "Canada", "Mexico", "England", "Germany", "Japan", "Korea", "China", "India", "Russia", "Israel", "Colombia", "Norway", "Poland", "Spain"]
                        ,["Cat", "Dog", "Owl", "Manatee", "Gorilla", "Snake", "Goat", "Cow", "Chicken", "Pig", "Ostrich", "Alligator", "Elephant", "Bear", "Salmon", "Platypus", "Chameleon", "Sparrow", "Horse", "Mantis"]
                        ,["Soronan Desert", "Kalahari Desert", "Gobi Desert", "Mojave Desert", "Great Basin Desert", "Thar Desert", "Great Sandy Desert", "Gibson Desert", "Namib Desert"]
                        ,["Pacific Ocean", "Atlantic Ocean", "Indian Ocean", "Southern Ocean", "Artic Ocean"]
                        ,["Mercury", "Venus", "Earth", "Mars", "Jupiter", "Saturn", "Uranus", "Neptune", "Pluto"]
                        ,["Helium", "Argon", "Krypton", "Iron", "Gold", "Mercury", "Uranium", "Lead", "Bromine", "Iodine", "Lithium", "Magnesium", "Hydrogen", "Carbon", "Calcium", "Nickel", "Cobalt", "Phosphorus", "Sulfur", "Oxygen", "Nitrogen", "Sodium"]]
        headerList = ["colors","wars","cereals","basketball teams","nations","animals","deserts","oceans","planets","Elements"]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpCollectionViewData()       
        
        inBetweenCollection.inBetweenDataSource = self

        setUpCollectionViewData()
        //inBetweenCollection.backgroundColor = UIColor.blue
        let nib = UINib(nibName: "UnityItemTableViewCell", bundle: nil)
        inBetweenCollection.register(unityCell: nib, with: "unity_cell")
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .horizontal
        inBetweenCollection!.collectionViewLayout = layout
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func InBetweenTableView(numberOfRowsInSection section: Int) -> Int {
        return dataList[section].count
    }
    
    func InBetweenTableView(cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  inBetweenCollection.dequeuUnityCell(with:"unity_cell") as? UnityItemTableViewCell
        cell?.backgroundColor = UIColor.clear
        cell?.view.backgroundColor = UIColor.white
        cell?.view.layer.cornerRadius = 3
        cell?.descriptionLabel.text = dataList[indexPath.section][indexPath.row]
        cell?.descriptionLabel.textAlignment = .left
        cell?.descriptionLabel.backgroundColor = UIColor.clear
        

        if(pivotIndexPath == indexPath){
            cell?.descriptionLabel.removeFromSuperview()
            cell?.descriptionLabel = nil
            cell?.view.backgroundColor = UIColor.clear
        }
        return cell!
    }
    
    func InBetweenTableView(headerViewIn section: Int) -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor(colorLiteralRed: 230.0/256.0, green: 230.0/256.0, blue: 230/256.0, alpha: 1.0)
        
        let label = UILabel()
        label.text = headerList[section]
        label.textAlignment = .left
        label.font = UIFont(name: "HiraginoSans-W6" , size: 17)
        label.backgroundColor = UIColor.clear
        label.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(label)
        
        let trailing = NSLayoutConstraint(item: view, attribute: .trailing, relatedBy: .equal, toItem: label, attribute: .trailing, multiplier: 1, constant: 0)
        let leading = NSLayoutConstraint(item: view, attribute: .leading, relatedBy: .equal, toItem: label, attribute: .leading, multiplier: 1, constant: -10)
        let top = NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: label, attribute: .top, multiplier: 1, constant: 0)
        let bottom = NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal, toItem: label, attribute: .bottom, multiplier: 1, constant: 0)
        
        view.addConstraints([trailing, leading, top, bottom])
        
        
        
        return view
    }
    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        inBetweenCollection.collectionViewLayout.invalidateLayout()
        self.view.setNeedsDisplay()
    }
    
    func InBetweenTableView(footerViewIn section: Int) -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor(colorLiteralRed: 230.0/256.0, green: 230.0/256.0, blue: 230/256.0, alpha: 1.0)
        
        let addButton = UIButton()
        addButton.setTitle("Add Card", for: .normal)
        addButton.setTitleColor(UIColor.gray, for: .normal)
        addButton.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 13)
        addButton.backgroundColor = UIColor.clear
        addButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(addButton)
        
        let trailing = NSLayoutConstraint(item: view, attribute: .trailing, relatedBy: .equal, toItem: addButton, attribute: .trailing, multiplier: 1, constant: 10)
        let leading = NSLayoutConstraint(item: view, attribute: .leading, relatedBy: .equal, toItem: addButton, attribute: .leading, multiplier: 1, constant: -10)
        let top = NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: addButton, attribute: .top, multiplier: 1, constant: 0)
        let bottom = NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal, toItem: addButton, attribute: .bottom, multiplier: 1, constant: 10)
        
        view.addConstraints([trailing, leading, top, bottom])

        return view
    }
    
    func InBetweenTableView(headerHeightIn section: Int) -> CGFloat {
        return CGFloat(65)
    }
    
    func InBetweenTableView(footerHeightIn section: Int) -> CGFloat {
        return CGFloat(50)
    }
    
    func numberOfSections() -> Int{
        return dataList.count
    }
    var pivot: String?
    var pivotIndexPath: IndexPath?
    func InBetweenTableView(deleteItemAt indexPath: IndexPath) {
        pivot = dataList[indexPath.section].remove(at: indexPath.row)
        pivotIndexPath = indexPath
    }
    
    func InBetweenTableView(insertItemAt indexPath: IndexPath) {
        dataList[indexPath.section].insert(pivot!, at: indexPath.row)
        pivotIndexPath = nil
    }
    
    func InBetweenTableView(insertDummmyItemWhenHoveringAt indexPath: IndexPath) {
        pivotIndexPath = indexPath

        dataList[indexPath.section].insert(pivot ?? "", at: indexPath.row)
    }
    
    func InBetweenTableView(removeDummmyItemWhenHoveringAt indexPath: IndexPath) {
        pivotIndexPath = nil
        dataList[indexPath.section].remove(at: indexPath.row)
    }
    
   }

