import Cocoa

class StatusItemView: NSView {
    let iconView: NSImageView
    let badgeLabel: NSTextField

    init(icon: NSImage, badge: String) {
        self.iconView = NSImageView(image: icon)
        self.badgeLabel = NSTextField(labelWithString: badge)

        super.init(frame: .zero)

        // Customize badgeLabel appearance
        self.badgeLabel.backgroundColor = NSColor.red
        self.badgeLabel.textColor = NSColor.white
        self.badgeLabel.isBordered = false
        self.badgeLabel.font = NSFont.systemFont(ofSize: 10)
        self.badgeLabel.alignment = .center

        // Add subviews
        self.addSubview(self.iconView)
        self.addSubview(self.badgeLabel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layout() {
        super.layout()

        // Position and size the icon and badge
        let badgeSize = self.badgeLabel.fittingSize
        self.iconView.frame = NSRect(x: 0, y: (self.bounds.height - self.iconView.image!.size.height) / 2, width: self.iconView.image!.size.width, height: self.iconView.image!.size.height)
        self.badgeLabel.frame = NSRect(x: self.iconView.frame.maxX - badgeSize.width / 2, y: self.iconView.frame.maxY - badgeSize.height / 2, width: badgeSize.width, height: badgeSize.height)
    }
}
