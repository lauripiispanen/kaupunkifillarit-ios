//
//  InfoDrawerView.swift
//  Kaupunkifillarit
//
//  Created by Lauri Piispanen on 21/09/16.
//  Copyright © 2016 Lauri Piispanen. All rights reserved.
//

import Foundation

class InfoDrawerView: UIView {

    let infoText = UITextView()

    convenience init() {
        self.init(frame: CGRect.zero)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        didLoad()
    }

    func didLoad() {
        self.backgroundColor = UIColor(red: 251.0 / 255.0, green: 188.0 / 255.0, blue: 26.0 / 255.0, alpha: 1.0)
        let image = UIImageView(image: UIImage(named: "kaupunkifillarit-logo.png"))
        self.addSubview(image)

        image.contentMode = .scaleAspectFit
        image.clipsToBounds = true

        image.translatesAutoresizingMaskIntoConstraints = false
        image.topAnchor.constraint(equalTo: self.topAnchor, constant: 20).isActive = true
        image.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 30).isActive = true
        image.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -30).isActive = true
        image.heightAnchor.constraint(equalTo: image.widthAnchor).isActive = true

        let title = UILabel()
        title.text = "KAUPUNKI-\nFILLARIT.FI"
        title.numberOfLines = 0
        title.font = UIFont(name: "Arial-BoldMT", size: 32.0)
        title.textColor = UIColor(red: 51.0 / 255.0, green: 51.0 / 255.0, blue: 51.0 / 255.0, alpha: 1.0)

        self.addSubview(title)

        title.translatesAutoresizingMaskIntoConstraints = false
        title.topAnchor.constraint(equalTo: image.bottomAnchor).isActive = true
        title.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 30).isActive = true
        title.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -30).isActive = true

        let html = textAsHtml
        infoText.attributedText = try? NSAttributedString(html:html)
        infoText.isScrollEnabled = true
        infoText.isSelectable = true
        infoText.isEditable = false
        infoText.linkTextAttributes = [ NSAttributedStringKey.foregroundColor.rawValue: title.textColor ]

        infoText.textColor = title.textColor
        infoText.backgroundColor = UIColor.clear
        infoText.font = UIFont(name: "Arial", size: 12.0)

        self.addSubview(infoText)

        infoText.translatesAutoresizingMaskIntoConstraints = false

        infoText.topAnchor.constraint(equalTo: title.bottomAnchor).isActive = true
        infoText.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 30).isActive = true
        infoText.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -30).isActive = true
        infoText.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -20).isActive = true

    }

    override func layoutSubviews() {
        super.layoutSubviews()
        infoText.setContentOffset(CGPoint.zero, animated: false)
    }

    func didFinishAnimating() {
        infoText.setContentOffset(CGPoint.zero, animated: false)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        didLoad()
    }

    fileprivate let textAsHtml = "<style type=\"text/css\">a { color: #333333; }</style>" +
        "<p>Polkupyöräily lisää kaupunkilaisten onnea. Innostuimme <a href=\"http://reaktor.fi/careers/?utm_source=kaupunkifillarit&amp;utm_medium=referral&amp;utm_campaign=kaupunkifillarit_2016\" target=\"_blank\" title=\"Reaktor careers\">Reaktorilla</a> maan mainioista Helsingin kaupunkipyöristä.</p>" +
        "<p>Kaupunkifillareiden ainoa ongelma on niiden kova suosio. Siispä me kaupunkipyöräilijät, <a href=\"https://twitter.com/sampsakuronen\" target=\"_blank\" title=\"Sampsa Kuronen Twitter\">Sampsa Kuronen</a>, <a href=\"https://twitter.com/albrto\" target=\"_blank\">Antero Päärni</a>, <a href=\"https://twitter.com/lauripiispanen\" target=\"_blank\">Lauri Piispanen</a> ja <a href=\"https://twitter.com/hleinone\" target=\"_blank\">Hannu Leinonen</a>, päätimme vapaa-ajallamme avittaa muita kaupunkilaisia.</p>" +
        "<p>Pyöriä käyttämään pääsee tosi helposti: <a href=\"https://www.hsl.fi/kaupunkipy%C3%B6r%C3%A4t\" target=\"_blank\">hsl.fi/kaupunkipyörät</a></p>" +
        "<p><a href=\"https://www.dropbox.com/sh/ni5lq7nu0waqprs/AAD5hdNUydglidjCfhM27zyDa?dl=0\" target=\"_blank\" title=\"Kaupunkifillarit.fi lehdistömateriaalit\">Press kit löytyy täältä.</a></p>" +
    "<p>Tiedot ovat HSL:n tarjoamaa avointa dataa.</p>"

}

private extension NSAttributedString {
    convenience init(html:String) throws {
        guard let data = html.data(using: String.Encoding.utf8) else {
            throw NSError(domain: "Invalid HTML", code: -500, userInfo: nil)
        }

        let options = [
            NSAttributedString.DocumentReadingOptionKey.documentType : NSAttributedString.DocumentType.html,
            NSAttributedString.DocumentReadingOptionKey.characterEncoding: String.Encoding.utf8.rawValue
        ] as [NSAttributedString.DocumentReadingOptionKey : Any]
        
        try self.init(data: data, options: options, documentAttributes: nil)
    }
}
