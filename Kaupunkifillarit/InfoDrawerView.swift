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
    let shareButton = UIImageView(image: UIImage(named: "share-icon.png"))
    var delegate: InfoDrawerViewDelegate? = nil

    convenience init() {
        self.init(frame: CGRectZero)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        didLoad()
    }

    func didLoad() {
        self.backgroundColor = UIColor(red: 251.0 / 255.0, green: 188.0 / 255.0, blue: 26.0 / 255.0, alpha: 1.0)
        let image = UIImageView(image: UIImage(named: "kaupunkifillarit-logo.png"))
        self.addSubview(image)

        image.contentMode = .ScaleAspectFit
        image.clipsToBounds = true

        image.translatesAutoresizingMaskIntoConstraints = false
        image.topAnchor.constraintEqualToAnchor(self.topAnchor, constant: 20).active = true
        image.leftAnchor.constraintEqualToAnchor(self.leftAnchor, constant: 30).active = true
        image.rightAnchor.constraintEqualToAnchor(self.rightAnchor, constant: -30).active = true
        image.heightAnchor.constraintEqualToAnchor(image.widthAnchor).active = true

        let title = UILabel()
        title.text = "KAUPUNKI-\nFILLARIT.FI"
        title.numberOfLines = 0
        title.font = UIFont(name: "Arial-BoldMT", size: 32.0)
        title.textColor = UIColor(red: 51.0 / 255.0, green: 51.0 / 255.0, blue: 51.0 / 255.0, alpha: 1.0)

        self.addSubview(title)

        title.translatesAutoresizingMaskIntoConstraints = false
        title.topAnchor.constraintEqualToAnchor(image.bottomAnchor).active = true
        title.leftAnchor.constraintEqualToAnchor(self.leftAnchor, constant: 30).active = true
        title.rightAnchor.constraintEqualToAnchor(self.rightAnchor, constant: -30).active = true

        shareButton.userInteractionEnabled = true
        shareButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.shareSelected)))

        self.addSubview(shareButton)
        shareButton.translatesAutoresizingMaskIntoConstraints = false

        shareButton.bottomAnchor.constraintEqualToAnchor(self.bottomAnchor, constant: -20).active = true
        shareButton.leftAnchor.constraintEqualToAnchor(self.leftAnchor, constant: 30).active = true
        shareButton.widthAnchor.constraintEqualToConstant(30).active = true
        shareButton.heightAnchor.constraintEqualToAnchor(shareButton.widthAnchor).active = true

        let html = textAsHtml
        infoText.attributedText = try? NSAttributedString(html:html)
        infoText.scrollEnabled = true
        infoText.selectable = true
        infoText.editable = false
        infoText.linkTextAttributes = [ NSForegroundColorAttributeName: title.textColor ]

        infoText.textColor = title.textColor
        infoText.backgroundColor = UIColor.clearColor()
        infoText.font = UIFont(name: "Arial", size: 12.0)

        self.addSubview(infoText)

        infoText.translatesAutoresizingMaskIntoConstraints = false

        infoText.topAnchor.constraintEqualToAnchor(title.bottomAnchor).active = true
        infoText.leftAnchor.constraintEqualToAnchor(self.leftAnchor, constant: 30).active = true
        infoText.rightAnchor.constraintEqualToAnchor(self.rightAnchor, constant: -30).active = true
        infoText.bottomAnchor.constraintEqualToAnchor(shareButton.topAnchor, constant: -20).active = true
    }

    func shareSelected() {
        delegate?.onInfoViewShareSelected()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        infoText.setContentOffset(CGPointZero, animated: false)
    }

    func didFinishAnimating() {
        infoText.setContentOffset(CGPointZero, animated: false)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        didLoad()
    }

    private let textAsHtml = "<style type=\"text/css\">a { color: #333333; }</style>" +
        "<p>Polkupyöräily lisää kaupunkilaisten onnea. Innostuimme <a href=\"http://reaktor.fi/careers/?utm_source=kaupunkifillarit&amp;utm_medium=referral&amp;utm_campaign=kaupunkifillarit_2016\" target=\"_blank\" title=\"Reaktor careers\">Reaktorilla</a> maan mainioista Helsingin kaupunkipyöristä.</p>" +
        "<p>Kaupunkifillareiden ainoa ongelma on niiden kova suosio. Siispä me kaupunkipyöräilijät, <a href=\"https://twitter.com/sampsakuronen\" target=\"_blank\" title=\"Sampsa Kuronen Twitter\">Sampsa Kuronen</a>, <a href=\"https://twitter.com/albrto\" target=\"_blank\">Antero Päärni</a>, <a href=\"https://twitter.com/lauripiispanen\" target=\"_blank\">Lauri Piispanen</a> ja <a href=\"https://twitter.com/hleinone\" target=\"_blank\">Hannu Leinonen</a>, päätimme vapaa-ajallamme avittaa muita kaupunkilaisia.</p>" +
        "<p>Pyöriä käyttämään pääsee tosi helposti: <a href=\"https://www.hsl.fi/kaupunkipy%C3%B6r%C3%A4t\" target=\"_blank\">hsl.fi/kaupunkipyörät</a></p>" +
        "<p><a href=\"https://www.dropbox.com/sh/ni5lq7nu0waqprs/AAD5hdNUydglidjCfhM27zyDa?dl=0\" target=\"_blank\" title=\"Kaupunkifillarit.fi lehdistömateriaalit\">Press kit löytyy täältä.</a></p>" +
    "<p>Tiedot ovat HSL:n tarjoamaa avointa dataa.</p>"

}

protocol InfoDrawerViewDelegate {

    func onInfoViewShareSelected()

}

private extension NSAttributedString {
    convenience init(html:String) throws {
        guard let data = html.dataUsingEncoding(NSUTF8StringEncoding) else {
            throw NSError(domain: "Invalid HTML", code: -500, userInfo: nil)
        }

        let options = [NSDocumentTypeDocumentAttribute : NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: NSNumber(unsignedInteger:NSUTF8StringEncoding)]
        try self.init(data: data, options: options, documentAttributes: nil)
    }
}