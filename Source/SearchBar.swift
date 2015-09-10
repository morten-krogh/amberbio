import UIKit

func colored_search_bar(color color: UIColor, background_color: UIColor, size: CGSize) -> UISearchBar {
        let search_bar = UISearchBar(frame: CGRect(origin: CGPoint.zeroPoint, size: size))

        search_bar.searchBarStyle = UISearchBarStyle.Minimal

        search_bar.backgroundColor = background_color
        search_bar.barTintColor = background_color

        let rect = CGRect(origin: CGPoint.zeroPoint, size: size)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        UIBezierPath(roundedRect: rect, cornerRadius: size.height / 2).addClip()
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        search_bar.setSearchFieldBackgroundImage(image, forState: .Normal)

        return search_bar
}

let custom_search_bar_size = CGSize(width: 250, height: 25)

func custom_search_bar() -> UISearchBar {
        let color = UIColor(red: 0.8, green: 0.85, blue: 0.95, alpha: 1)
        let background_color = UIColor(red: 0.97, green: 1.0, blue: 0.98, alpha: 1.0)
        let search_bar = colored_search_bar(color: color, background_color: background_color, size: custom_search_bar_size)

        search_bar.autocapitalizationType = .None
        search_bar.autocorrectionType = .No

        return search_bar
}
