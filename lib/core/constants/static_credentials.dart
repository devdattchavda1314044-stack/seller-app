enum SellerType {
  shop,
  services,
  startup,
}

/// Startup can operate as either a Shop or Services business.
enum StartupBusinessType {
  shop,
  services,
}

class StaticCredentials {
  /// Returns the [SellerType] if credentials match, or null if invalid.
  static SellerType? validateLogin(String input, String password, bool isPhone) {
    if (password != '1234') return null;

    if (isPhone) {
      if (input == '9876543210') return SellerType.shop;
      if (input == '1234567890') return SellerType.services;
    } else {
      if (input == 'shop@shop.com') return SellerType.shop;
      if (input == 'service@service.com') return SellerType.services;
      if (input == 'startup@startup.com') return SellerType.startup;
    }

    return null;
  }
}
