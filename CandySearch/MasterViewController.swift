/// Copyright (c) 2019 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit

class MasterViewController: UIViewController {
  @IBOutlet var tableView: UITableView!
  @IBOutlet var searchFooter: SearchFooter!
  @IBOutlet var searchFooterBottomConstraint: NSLayoutConstraint!
  
  
  
  let searchController = UISearchController(searchResultsController: nil)
  var candies: [Candy] = []
  
//   arama verileri için bi değişken tanımlandı
  var filteredCandies: [Candy] = []
  
//  arama yhapıp yağılmadığın kontrol ediyor
  var isSearchBarEmpty: Bool {
    return searchController.searchBar.text?.isEmpty ?? true
  }
  var isFiltering: Bool {
    
    let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
    return searchController.isActive &&
      (!isSearchBarEmpty || searchBarScopeIsFiltering)
  }
//   filtre yapıp yapılmadığını kontol ediyor
//  var isFiltering: Bool {
////    return searchController.isActive && !isSearchBarEmpty
//    let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
//      return searchController.isActive &&
//        (!isSearchBarEmpty || searchBarScopeIsFiltering)
//  }



  //  arama çubuğunuoluşturmuş olduk
 

  
  override func viewDidLoad() {
    super.viewDidLoad()
    
//    şekerlemelerizi bir edeğişkene atayarak oluşturmuş olduk
    
    candies = Candy.candies()
    
    // 1
//    eklediğimiz extencıon sayesınde SearchıngUpdate yazılı fonskıyonu kullanıyoruz
    
    searchController.searchResultsUpdater = self
    // 2
//     arama sırasında arka planı kararmak ıstersek bu ıfadeyı true ile değiştirmemiz yeterli
    searchController.obscuresBackgroundDuringPresentation = false
//    searchController.obscuresBackgroundDuringPresentation = true
    // 3
//    arama butonun içindeki çıkacak ifadeyi belirledik
    searchController.searchBar.placeholder = "Search Candies"
    // 4
//    arama çubuğunun nerede gösterlieceğini söylemiş olduk navigasondaki arama özelliğini aktifleştirmiş olduk
    navigationItem.searchController = searchController
    // 5
//    ??
    definesPresentationContext = true
    
//    kategoriler kısmını oluşturdu
    searchController.searchBar.scopeButtonTitles = Candy.Category.allCases
      .map { $0.rawValue }
    searchController.searchBar.delegate = self
//alt bilgi kısmını oluşturuyor
    let notificationCenter = NotificationCenter.default
    notificationCenter.addObserver(
      forName: UIResponder.keyboardWillChangeFrameNotification,
      object: nil, queue: .main) { (notification) in
        self.handleKeyboard(notification: notification)
    }
    notificationCenter.addObserver(
      forName: UIResponder.keyboardWillHideNotification,
      object: nil, queue: .main) { (notification) in
        self.handleKeyboard(notification: notification)
    }



  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    if let indexPath = tableView.indexPathForSelectedRow {
      tableView.deselectRow(at: indexPath, animated: true)
    }
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard
      segue.identifier == "ShowDetailSegue",
      let indexPath = tableView.indexPathForSelectedRow,
      let detailViewController = segue.destination as? DetailViewController
      else {
        return
    }
    
//   let candy = candies[indexPath.row]
//     filtreleme işlemei yapıldıkdan sonrasında filteleme işlemeinin yapıldığı verilerin atanmış güncel hali
    let candy: Candy
    if isFiltering {
      candy = filteredCandies[indexPath.row]
    } else {
      candy = candies[indexPath.row]
    }


    detailViewController.candy = candy
  }
  func filterContentForSearchText(_ searchText: String,
                                  category: Candy.Category? = nil) {
    filteredCandies = candies.filter { (candy: Candy) -> Bool in
      let doesCategoryMatch = category == .all || candy.category == category
         
         if isSearchBarEmpty {
           return doesCategoryMatch
         } else {
           return doesCategoryMatch && candy.name.lowercased()
             .contains(searchText.lowercased())
         }
//      return candy.name.lowercased().contains(searchText.lowercased())
    }
    
    tableView.reloadData()
  }
  
  func handleKeyboard(notification: Notification) {
    // 1
    guard notification.name == UIResponder.keyboardWillChangeFrameNotification else {
      searchFooterBottomConstraint.constant = 0
      view.layoutIfNeeded()
      return
    }

    guard
      let info = notification.userInfo,
      let keyboardFrame = info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
      else {
        return
    }

    // 2
    let keyboardHeight = keyboardFrame.cgRectValue.size.height
    UIView.animate(withDuration: 0.1, animations: { () -> Void in
      self.searchFooterBottomConstraint.constant = keyboardHeight
      self.view.layoutIfNeeded()
    })
  }


}

extension MasterViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView,
                 numberOfRowsInSection section: Int) -> Int {
// değişim yapılmadan önce aşağıdaki satırdaki kod vardı
    //    return candies.count

    //     burda eğer filtreleme yapıldıysa filtreleme sonucu kadar tabşe view dönmesini yok filtreleme işlemi true gelmediyse şekerleme verilerini göstermeye devam edecek
    
    if isFiltering {
        
//      bu satır sonuc panelının oluşmasını sağlıyor
//      kullanılan verı bılgılerı SearcFooterdan gelmektedir(fonksıyon ve ve özellikler)
      
      searchFooter.setIsFilteringToShow(filteredItemCount:filteredCandies.count, of: candies.count)
      
      return filteredCandies.count
      }
    searchFooter.setNotFiltering()
      return candies.count
  }
  
  func tableView(_ tableView: UITableView,
                 cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell",
                                             for: indexPath)
//     değişimden önce bütün verileri gösteririken yeni hali 4 satır sonrasında ekledim
//    let candy = candies[indexPath.row]
//    cell.textLabel?.text = candy.name
//    cell.detailTextLabel?.text = candy.category.rawValue
//    return cell
    
//    eğer filtreleme varsa table viewun içinde oluşacak satırlardaki hücrelerdeki blgi içerikleri
     let candy: Candy
      if isFiltering {
        candy = filteredCandies[indexPath.row]
      } else {
        candy = candies[indexPath.row]
      }
      cell.textLabel?.text = candy.name
      cell.detailTextLabel?.text = candy.category.rawValue
      return cell
  }
}

//bu extensıonı arama işlemlerini güncelleme yapabilmel yaptık
//1 yazan ıfadeyı yazabılmemiz için bu sınıdaki yazılmış IOS kutuphanesınden yardım alıyoruz

extension MasterViewController: UISearchResultsUpdating {
  func updateSearchResults(for searchController: UISearchController) {
//   değişikleri kontrol edecek kod bloğumuz
    
//    let searchBar = searchController.searchBar
//    filterContentForSearchText(searchBar.text!)
    let searchBar = searchController.searchBar
      let category = Candy.Category(rawValue:
        searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex])
      filterContentForSearchText(searchBar.text!, category: category)

  }
}

extension MasterViewController: UISearchBarDelegate {
  func searchBar(_ searchBar: UISearchBar,selectedScopeButtonIndexDidChange selectedScope: Int) {
    let category = Candy.Category(rawValue:
      searchBar.scopeButtonTitles![selectedScope])
    filterContentForSearchText(searchBar.text!, category: category)
  }
}

