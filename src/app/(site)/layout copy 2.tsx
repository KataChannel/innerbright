'use client'
import { usePathname } from 'next/navigation';

export default function Layout({ children }: { children: React.ReactNode }) {
  const pathname = usePathname();

  const navItems = [
    { label: "Về InnerBright", href: "/" },
    { label: "NLP", href: "/nlp" },
    { label: "Time Line Therapy", href: "/timeline-therapy" },
    { label: "Đào tạo doanh nghiệp", href: "/corporate-training" },
    { label: "Khai vấn cá nhân", href: "/personal-consultation" },
    { label: "Khoá học", href: "/courses" },
    { label: "Bộ thẻ NLP", href: "/nlp-cards" },
    { label: "Thư viện", href: "/library" },
    { label: "Liên hệ", href: "/contact" },
  ];

  return (
    <div className="min-h-screen bg-gray-100 font-inter">
      <header className="bg-white shadow-sm">
        <div className="container mx-auto px-4 py-4 flex items-center justify-between">
          {/* Logo */}
          <div className="flex items-center">
            {/* Placeholder for InnerBright logo */}
            <img
              src="https://placehold.co/120x40/f0f0f0/333333?text=InnerBright"
              alt="InnerBright Logo"
              className="h-10 w-auto rounded-md"
            />
          </div>

          {/* Search and User Icon */}
          <div className="flex items-center space-x-4">
            <div className="relative">
              <input
                type="text"
                placeholder="Tìm kiếm..."
                className="pl-10 pr-4 py-2 rounded-full border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-500 text-sm w-48"
              />
              {/* Search Icon */}
              <svg
                className="absolute left-3 top-1/2 transform -translate-y-1/2 h-4 w-4 text-gray-400"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
                xmlns="http://www.w3.org/2000/svg"
              >
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth="2"
                  d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"
                ></path>
              </svg>
            </div>
            {/* User Icon */}
            <div className="p-2 rounded-full bg-gray-200 cursor-pointer hover:bg-gray-300 transition-colors">
              <svg
                className="h-6 w-6 text-gray-600"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
                xmlns="http://www.w3.org/2000/svg"
              >
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth="2"
                  d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"
                ></path>
              </svg>
            </div>
          </div>
        </div>
      </header>

      {/* Navigation Bar */}
      <nav className="bg-white shadow-md mt-0">
        <div className="container mx-auto px-4 py-3">
          <ul className="flex flex-wrap justify-center lg:justify-start space-x-4 lg:space-x-8 text-sm font-medium">
            {navItems.map((item) => {
              const isActive = pathname === item.href;
              return (
                <li key={item.label}>
                  <a
                    href={item.href}
                    className={`block py-2 px-3 rounded-md transition-colors duration-200 ease-in-out ${
                      isActive
                        ? 'bg-blue-500 text-white'
                        : 'text-gray-700 hover:bg-blue-500 hover:text-white'
                    }`}
                  >
                    {item.label}
                  </a>
                </li>
              );
            })}
          </ul>
        </div>
      </nav>

      {/* Hero Section */}
      <main className="container mx-auto px-4 py-8 mt-6">
        {children}
      </main>
    </div>
  );
}
