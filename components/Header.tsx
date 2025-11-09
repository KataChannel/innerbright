"use client";

import Image from "next/image";
import Link from "next/link";
import { useState } from "react";

export default function Header() {
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);

  const menuItems = [
    { href: "/about", label: "Về InnerBright", isHighlighted: true },
    { href: "/nlp", label: "NLP" },
    { href: "/time-line-therapy", label: "Time Line Therapy®" },
    { href: "/business-training", label: "Đào tạo doanh nghiệp" },
    { href: "/consultation", label: "Khai vấn cá nhân" },
    { href: "/courses", label: "Khóa học" },
    { href: "/nlp-certification", label: "Bộ thẻ NLP" },
    { href: "/library", label: "Thư viện" },
    { href: "/contact", label: "Liên hệ" },
  ];

  return (
    <header className="bg-white shadow-sm">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        {/* Top Row - Logo, Search, User */}
        <div className="flex items-center justify-between py-4">
          {/* Logo */}
          <Link href="/" className="flex items-center">
            <div className="relative w-56 h-16">
              <Image
                src="/innerbright-logo.svg"
                alt="InnerBright Training & Coaching"
                fill
                className="object-contain object-left"
                priority
              />
            </div>
          </Link>

          {/* Search and User */}
          <div className="flex items-center gap-4">
            {/* Search Box */}
            <div className="relative hidden md:block">
              <input
                type="text"
                placeholder="Tìm kiếm ..."
                className="w-80 lg:w-96 px-4 py-2.5 bg-white border border-gray-300 rounded-lg text-sm placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
              />
              <div className="absolute right-3 top-1/2 transform -translate-y-1/2">
                <svg className="w-5 h-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
                </svg>
              </div>
            </div>

            {/* User Profile */}
            <div className="w-11 h-11 bg-gray-300 rounded-full flex items-center justify-center cursor-pointer hover:bg-gray-400 transition-colors">
              <svg className="w-6 h-6 text-gray-600" fill="currentColor" viewBox="0 0 24 24">
                <path d="M12 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm0 2c-2.67 0-8 1.34-8 4v2h16v-2c0-2.66-5.33-4-8-4z"/>
              </svg>
            </div>

            {/* Mobile menu button */}
            <button 
              className="lg:hidden p-2 rounded-md text-gray-600 hover:text-gray-800 hover:bg-gray-100"
              onClick={() => setIsMobileMenuOpen(!isMobileMenuOpen)}
            >
              <span className="sr-only">Open menu</span>
              {isMobileMenuOpen ? (
                <svg className="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                </svg>
              ) : (
                <svg className="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 6h16M4 12h16M4 18h16" />
                </svg>
              )}
            </button>
          </div>
        </div>

        {/* Bottom Row - Navigation Menu */}
        <nav className="hidden lg:flex items-center gap-1 border-t border-gray-100">
          {menuItems.map((item) => (
            <Link 
              key={item.href}
              href={item.href}
              className={
                item.isHighlighted
                  ? "bg-blue-600 text-white px-5 py-3 text-sm font-medium hover:bg-blue-700 transition-colors whitespace-nowrap rounded-md"
                  : "text-gray-700 hover:text-blue-600 px-5 py-3 text-sm font-medium transition-colors whitespace-nowrap"
              }
            >
              {item.label}
            </Link>
          ))}
        </nav>

        {/* Mobile menu */}
        {isMobileMenuOpen && (
          <div className="lg:hidden">
            <div className="px-2 pt-2 pb-3 space-y-1 bg-white border-t border-gray-100">
              {/* Mobile Search */}
              <div className="relative mb-4">
                <input
                  type="text"
                  placeholder="Tìm kiếm ..."
                  className="w-full px-4 py-2.5 bg-gray-50 border border-gray-200 rounded-lg text-sm placeholder-gray-500 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                />
                <div className="absolute right-3 top-1/2 transform -translate-y-1/2">
                  <svg className="w-5 h-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
                  </svg>
                </div>
              </div>

              {/* Mobile Menu Items */}
              {menuItems.map((item) => (
                <Link
                  key={item.href}
                  href={item.href}
                  className={
                    item.isHighlighted
                      ? "bg-blue-600 text-white block px-4 py-3 rounded-lg text-base font-medium"
                      : "text-blue-600 hover:text-blue-800 hover:bg-blue-50 block px-4 py-3 rounded-lg text-base font-medium"
                  }
                  onClick={() => setIsMobileMenuOpen(false)}
                >
                  {item.label}
                </Link>
              ))}
            </div>
          </div>
        )}
      </div>
    </header>
  );
}