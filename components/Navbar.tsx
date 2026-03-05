"use client";

import Link from "next/link";
import { useState } from "react";

export default function Navbar() {
  const [isOpen, setIsOpen] = useState(false);

  const menuItems = [
    { name: "NLP", href: "/nlp" },
    { name: "Time Line Therapy®", href: "/time-line-therapy" },
    { name: "Đào tạo doanh nghiệp", href: "/dao-tao-doanh-nghiep" },
    { name: "Khai vấn cá nhân", href: "/khai-van-ca-nhan" },
    { name: "Bộ thẻ NLP", href: "/bo-the-nlp" },
    { name: "Thư viện", href: "/thu-vien" },
    { name: "Liên hệ", href: "/lien-he" },
    { name: "Khoá học", href: "/khoa-hoc" },
  ];

  return (
    <nav className="fixed top-0 left-0 right-0 z-50 bg-white/80 backdrop-blur-md border-b border-zinc-100 dark:bg-black/80 dark:border-zinc-800">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex justify-between h-20 items-center">
          <div className="flex-shrink-0 flex items-center">
            <Link href="/" className="text-2xl font-bold text-[#0047C6]">
              InnerBright
            </Link>
          </div>
          
          <div className="hidden lg:flex items-center space-x-1">
            {menuItems.map((item) => (
              <Link
                key={item.name}
                href={item.href}
                className="px-3 py-2 text-sm font-medium text-zinc-600 hover:text-[#0047C6] transition-colors dark:text-zinc-300"
              >
                {item.name}
              </Link>
            ))}
            <Link
              href="/ve-innerbright"
              className="ml-4 px-5 py-2.5 bg-[#0047C6] text-white rounded-full text-sm font-semibold hover:bg-[#003699] transition-all shadow-lg shadow-blue-500/20"
            >
              Về InnerBright
            </Link>
          </div>

          <div className="lg:hidden">
            <button
              onClick={() => setIsOpen(!isOpen)}
              className="p-2 rounded-md text-zinc-600 hover:text-[#0047C6] dark:text-zinc-300"
            >
              <svg className="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                {isOpen ? (
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                ) : (
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 6h16M4 12h16M4 18h16" />
                )}
              </svg>
            </button>
          </div>
        </div>
      </div>

      {/* Mobile menu */}
      {isOpen && (
        <div className="lg:hidden bg-white dark:bg-black border-b border-zinc-100 dark:border-zinc-800">
          <div className="px-2 pt-2 pb-3 space-y-1">
            {menuItems.map((item) => (
              <Link
                key={item.name}
                href={item.href}
                className="block px-3 py-2 text-base font-medium text-zinc-600 hover:text-[#0047C6] dark:text-zinc-300"
              >
                {item.name}
              </Link>
            ))}
            <Link
              href="/ve-innerbright"
              className="block px-3 py-2 text-base font-bold text-[#0047C6]"
            >
              Về InnerBright
            </Link>
          </div>
        </div>
      )}
    </nav>
  );
}
