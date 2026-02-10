class NavItem {
  final String title;
  final int index;
  NavItem(this.title, this.index);
}

final List<NavItem> navItems = [
  NavItem('Home', 0),
  NavItem('About Us', 1),
  NavItem('Events', 3),
  NavItem('Members', 4),
  NavItem('Student Body', 5),
  NavItem('OurInitiatives', 6),
  NavItem('Contact',7 ),
];

class ProductSubItem {
  final String title;
  final int sectionIndex;
  final String iconPath;

  ProductSubItem(this.title, this.sectionIndex, this.iconPath);
}

const int kSectionCount = 8;

int sectionIndexForNav(int navIndex) {
  switch (navIndex) {
    case 0:
      return 0;
    case 1:
      return 1;
    case 2:
      return 3;
    case 3:
      return 4;
    case 4:
      return 5;
    case 5:
      return 6;
      case 6:
      return 7;
      case 7:
      return 8;
    default:
      return 0;
  }
}

int navIndexForSection(int sectionIndex) {
  if (sectionIndex == 0) return 0;
  if (sectionIndex == 1) return 1;
  if (sectionIndex == 2) return 2;
  if (sectionIndex == 3) return 3;
  if (sectionIndex == 4) return 4;
  if (sectionIndex == 5) return 5;
    if (sectionIndex == 6) return 6;
      if (sectionIndex == 7) return 7;


  return 0;
}
