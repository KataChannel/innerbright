"use client"
import { useState } from "react";
import { Menu, X, Search, ChevronDown } from "lucide-react";

export default function Navbar() {
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);
  const [isDropdownOpen, setIsDropdownOpen] = useState(false);

  const navigationItems = [
    { name: "Trang chủ", href: "/" },
    {
      name: "Dịch vụ",
      href: "/services",
      hasDropdown: true,
      dropdownItems: [
        { name: "Phát triển Web", href: "/services/web-development" },
        { name: "Ứng dụng di động", href: "/services/mobile-app" },
        { name: "Thiết kế UI/UX", href: "/services/ui-ux" },
        { name: "Tư vấn IT", href: "/services/consulting" },
        { name: "Bảo trì & Hỗ trợ", href: "/services/support" },
      ],
    },
    { name: "Về chúng tôi", href: "/about" },
    { name: "Dự án", href: "/projects" },
    { name: "Blog", href: "/blog" },
    { name: "Liên hệ", href: "/contact" },
  ];

  return (
    <nav className="bg-gray-100 dark:bg-gray-900 shadow sticky top-0 z-50 border-b border-gray-200 dark:border-gray-700">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex justify-between items-center h-16">
          {/* Desktop Navigation */}
          <div className="hidden lg:flex items-center space-x-8">
            {navigationItems.map((item) => (
              <div key={item.name} className="relative">
                {item.hasDropdown ? (
                  <div className="relative">
                    <button
                      onClick={() => setIsDropdownOpen(!isDropdownOpen)}
                      className="flex items-center space-x-1 text-gray-800 dark:text-gray-200 hover:text-black dark:hover:text-white px-3 py-2 text-sm font-medium transition-colors duration-200"
                    >
                      <span>{item.name}</span>
                      <ChevronDown
                        className={`h-4 w-4 transition-transform duration-200 ${
                          isDropdownOpen ? "rotate-180" : ""
                        }`}
                      />
                    </button>
                    {isDropdownOpen && (
                      <div className="absolute top-full left-0 mt-1 w-56 bg-gray-100 dark:bg-gray-800 rounded-md shadow border border-gray-200 dark:border-gray-700 py-1">
                        {item.dropdownItems.map((dropdownItem) => (
                          <a
                            key={dropdownItem.name}
                            href={dropdownItem.href}
                            className="block px-4 py-2 text-sm text-gray-800 dark:text-gray-200 hover:bg-gray-200 dark:hover:bg-gray-700 transition-colors duration-200"
                          >
                            {dropdownItem.name}
                          </a>
                        ))}
                      </div>
                    )}
                  </div>
                ) : (
                  <a
                    href={item.href}
                    className="text-gray-800 dark:text-gray-200 hover:text-black dark:hover:text-white px-3 py-2 text-sm font-medium transition-colors duration-200"
                  >
                    {item.name}
                  </a>
                )}
              </div>
            ))}
          </div>         
           {/* Mobile Menu Button */}
          <button
            onClick={() => setIsMobileMenuOpen(!isMobileMenuOpen)}
            className="lg:hidden p-2 rounded-md text-gray-800 dark:text-gray-200 hover:bg-gray-200 dark:hover:bg-gray-700 focus:outline-none focus:ring-2 focus:ring-gray-500"
          >
            {isMobileMenuOpen ? (
              <X className="h-6 w-6" />
            ) : (
              <Menu className="h-6 w-6" />
            )}
          </button>
        </div>
      </div>

      {/* Mobile Menu */}
      {isMobileMenuOpen && (
        <div className="lg:hidden border-t border-gray-200 dark:border-gray-700">
          <div className="px-2 pt-2 pb-3 space-y-1 bg-gray-100 dark:bg-gray-900">
            {/* Mobile Search */}
            <div className="px-3 py-2">
              <div className="relative">
                <input
                  type="text"
                  placeholder="Tìm kiếm..."
                  className="w-full pl-10 pr-4 py-2 border border-gray-300 dark:border-gray-700 rounded-lg bg-gray-100 dark:bg-gray-800 text-gray-900 dark:text-gray-100 focus:outline-none focus:ring-2 focus:ring-gray-500"
                />
                <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 h-4 w-4 text-gray-500 dark:text-gray-300" />
              </div>
            </div>

            {navigationItems.map((item) => (
              <div key={item.name}>
                {item.hasDropdown ? (
                  <div>
                    <button
                      onClick={() => setIsDropdownOpen(!isDropdownOpen)}
                      className="flex items-center justify-between w-full px-3 py-2 text-base font-medium text-gray-800 dark:text-gray-200 hover:text-black dark:hover:text-white hover:bg-gray-200 dark:hover:bg-gray-700 transition-colors duration-200"
                    >
                      <span>{item.name}</span>
                      <ChevronDown
                        className={`h-4 w-4 transition-transform duration-200 ${
                          isDropdownOpen ? "rotate-180" : ""
                        }`}
                      />
                    </button>
                    {isDropdownOpen && (
                      <div className="pl-6 space-y-1">
                        {item.dropdownItems.map((dropdownItem) => (
                          <a
                            key={dropdownItem.name}
                            href={dropdownItem.href}
                            className="block px-3 py-2 text-sm text-gray-800 dark:text-gray-200 hover:bg-gray-200 dark:hover:bg-gray-700 transition-colors duration-200"
                          >
                            {dropdownItem.name}
                          </a>
                        ))}
                      </div>
                    )}
                  </div>
                ) : (
                  <a
                    href={item.href}
                    className="block px-3 py-2 text-base font-medium text-gray-800 dark:text-gray-200 hover:bg-gray-200 dark:hover:bg-gray-700 transition-colors duration-200"
                  >
                    {item.name}
                  </a>
                )}
              </div>
            ))}
          </div>
        </div>
      )}
    </nav>
  );
}
