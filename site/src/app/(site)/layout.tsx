'use client'
import { usePathname } from 'next/navigation';

export default function Layout({ children }: { children: React.ReactNode }) {
  const pathname = usePathname();

  const navItems = [
    { label: "Về InnerBright", href: "/" },
    { label: "NLP", href: "/nlp" },
    { label: "Time Line Therapy", href: "/time-line-therapy" },
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
        <div className="container mx-auto px-4 py-4 flex items-center justify-center space-x-10">
          {/* Logo */}
          <div className="w-2/4 flex items-center">
            {/* Placeholder for InnerBright logo */}
            <img
              src="https://placehold.co/120x40/f0f0f0/333333"
              alt="InnerBright Logo"
              className="h-20 w-auto rounded-md"
            />
          </div>

          {/* Search and User Icon */}
          <div className="w-1/4 flex items-center space-x-4">
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
          <ul className="!w-full flex flex-row justify-center space-x-2 lg:space-x-2 text-sm font-medium">
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

      <main className="container mx-auto px-4 py-8 mt-6">
            {children}
      </main>
      <footer className="container mx-auto px-4 py-8 mt-6 bg-white rounded-xl shadow-lg">
        <div className="text-center text-gray-600 mb-4">
          <a href="#top" className="hover:underline text-gray-600 font-medium">
            Trở lại đầu trang
          </a>
        </div>
        <div className="border-y py-4 container mx-auto grid grid-cols-1 md:grid-cols-4 gap-8">
          {/* Logo and Contact Info */}
          <div className="col-span-1 md:col-span-1 flex flex-col items-center md:items-start text-center md:text-left">
            <img
              src="https://placehold.co/150x50/E0E0E0/333333" // Placeholder logo, replace with your actual logo path
              alt="InnerBright Logo"
              className="h-16 mb-4 rounded-md"
            />
            <div className="flex items-center mb-2 text-gray-700">
              <span className="mr-2 text-xl">📞</span>{" "}
              {/* Telephone receiver icon */}
              <span>090 837 09 68</span>
            </div>
            <div className="flex items-center text-gray-700">
              <span className="mr-2 text-xl">&#9993;</span>{" "}
              {/* Unicode email icon */}
              <a href="mailto:info@innerbright.vn" className="hover:underline">
                info@innerbright.vn
              </a>
            </div>
          </div>

          {/* INNER Navigation */}
          <div className="col-span-1 md:col-span-1 text-center md:text-left">
            <h3 className="font-bold text-lg mb-4 text-gray-800">INNENER</h3>
            <ul className="space-y-2 text-gray-700">
              <li>
                <a href="#" className="hover:underline">
                  Our Support
                </a>
              </li>
              <li>
                <a href="#" className="hover:underline">
                  Blog
                </a>
              </li>
              <li>
                <a href="#" className="hover:underline">
                  Contact us
                </a>
              </li>
              <li>
                <a href="#" className="hover:underline">
                  Write For Us
                </a>
              </li>
              <li>
                <a href="#" className="hover:underline">
                  Group
                </a>
              </li>
            </ul>
          </div>

          {/* OUR SERVICES Navigation */}
          <div className="col-span-1 md:col-span-1 text-center md:text-left">
            <h3 className="font-bold text-lg mb-4 text-gray-800">
              OUR SERVICES
            </h3>
            <ul className="space-y-2 text-gray-700">
              <li>
                <a href="#" className="hover:underline">
                  Đào tạo doanh nghiệp
                </a>
              </li>
              <li>
                <a href="#" className="hover:underline">
                  Khai vấn cá nhân
                </a>
              </li>
              <li>
                <a href="#" className="hover:underline">
                  Đào tạo doanh nghiệp
                </a>
              </li>
              <li>
                <a href="#" className="hover:underline">
                  Khai vấn cá nhân
                </a>
              </li>
              <li>
                <a href="#" className="hover:underline">
                  Đào tạo doanh nghiệp
                </a>
              </li>
            </ul>
          </div>

          <div className="col-span-1 md:col-span-1 flex justify-start md:justify-start items-start mt-4 md:mt-0">
            <div className="flex space-x-4 text-2xl">
              {/* Facebook Icon */}
              <a
                href="#"
                className="text-gray-600 hover:text-blue-600 transition-colors duration-200"
              >
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  width="24"
                  height="24"
                  viewBox="0 0 24 24"
                  fill="currentColor"
                >
                  <path d="M9 8h-3v4h3v12h5v-12h3.642l.358-4h-4v-1.667c0-.955.192-1.333 1.115-1.333h2.885v-5h-3.812c-3.235 0-4.188 1.501-4.188 4.004v2.996z" />
                </svg>
              </a>
              {/* Instagram Icon */}
              <a
                href="#"
                className="text-gray-600 hover:text-pink-600 transition-colors duration-200"
              >
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  width="24"
                  height="24"
                  viewBox="0 0 24 24"
                >
                  <path d="M 11.46875 5 C 7.917969 5 5 7.914063 5 11.46875 L 5 20.53125 C 5 24.082031 7.914063 27 11.46875 27 L 20.53125 27 C 24.082031 27 27 24.085938 27 20.53125 L 27 11.46875 C 27 7.917969 24.085938 5 20.53125 5 Z M 11.46875 7 L 20.53125 7 C 23.003906 7 25 8.996094 25 11.46875 L 25 20.53125 C 25 23.003906 23.003906 25 20.53125 25 L 11.46875 25 C 8.996094 25 7 23.003906 7 20.53125 L 7 11.46875 C 7 8.996094 8.996094 7 11.46875 7 Z M 21.90625 9.1875 C 21.402344 9.1875 21 9.589844 21 10.09375 C 21 10.597656 21.402344 11 21.90625 11 C 22.410156 11 22.8125 10.597656 22.8125 10.09375 C 22.8125 9.589844 22.410156 9.1875 21.90625 9.1875 Z M 16 10 C 12.699219 10 10 12.699219 10 16 C 10 19.300781 12.699219 22 16 22 C 19.300781 22 22 19.300781 22 16 C 22 12.699219 19.300781 10 16 10 Z M 16 12 C 18.222656 12 20 13.777344 20 16 C 20 18.222656 18.222656 20 16 20 C 13.777344 20 12 18.222656 12 16 C 12 13.777344 13.777344 12 16 12 Z"></path>
                </svg>
              </a>
              {/* Twitter Icon */}

              {/* YouTube Icon */}
              <a
                href="#"
                className="text-gray-600 hover:text-red-600 transition-colors duration-200"
              >
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  width="24"
                  height="24"
                  viewBox="0 0 24 24"
                >
                  <path d="M 12 4 C 12 4 5.7455469 3.9999687 4.1855469 4.4179688 C 3.3245469 4.6479688 2.6479687 5.3255469 2.4179688 6.1855469 C 1.9999687 7.7455469 2 12 2 12 C 2 12 1.9999687 16.254453 2.4179688 17.814453 C 2.6479687 18.675453 3.3255469 19.352031 4.1855469 19.582031 C 5.7455469 20.000031 12 20 12 20 C 12 20 18.254453 20.000031 19.814453 19.582031 C 20.674453 19.352031 21.352031 18.674453 21.582031 17.814453 C 22.000031 16.254453 22 12 22 12 C 22 12 22.000031 7.7455469 21.582031 6.1855469 C 21.352031 5.3255469 20.674453 4.6479688 19.814453 4.4179688 C 18.254453 3.9999687 12 4 12 4 z M 12 6 C 14.882 6 18.490875 6.1336094 19.296875 6.3496094 C 19.465875 6.3946094 19.604391 6.533125 19.650391 6.703125 C 19.891391 7.601125 20 10.342 20 12 C 20 13.658 19.891391 16.397875 19.650391 17.296875 C 19.605391 17.465875 19.466875 17.604391 19.296875 17.650391 C 18.491875 17.866391 14.882 18 12 18 C 9.119 18 5.510125 17.866391 4.703125 17.650391 C 4.534125 17.605391 4.3956094 17.466875 4.3496094 17.296875 C 4.1086094 16.398875 4 13.658 4 12 C 4 10.342 4.1086094 7.6011719 4.3496094 6.7011719 C 4.3946094 6.5331719 4.533125 6.3946094 4.703125 6.3496094 C 5.508125 6.1336094 9.118 6 12 6 z M 10 8.5351562 L 10 15.464844 L 16 12 L 10 8.5351562 z"></path>
                </svg>
              </a>
              {/* TikTok Icon (simplified) */}
              <a
                href="#"
                className="text-gray-600 hover:text-gray-900 transition-colors duration-200"
              >
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  width="24"
                  height="24"
                  viewBox="0 0 24 24"
                  fill="currentColor"
                >
                  <path d="M12 0c-6.627 0-12 5.373-12 12s5.373 12 12 12 12-5.373 12-12-5.373-12-12-12zm-3.5 16.5c0 .828-.672 1.5-1.5 1.5s-1.5-.672-1.5-1.5.672-1.5 1.5-1.5 1.5.672 1.5 1.5zm5-3c0 .828-.672 1.5-1.5 1.5s-1.5-.672-1.5-1.5.672-1.5 1.5-1.5 1.5.672 1.5 1.5zm-2.5-3c0 .828-.672 1.5-1.5 1.5s-1.5-.672-1.5-1.5.672-1.5 1.5-1.5 1.5.672 1.5 1.5zm5-3c0 .828-.672 1.5-1.5 1.5s-1.5-.672-1.5-1.5.672-1.5 1.5-1.5 1.5.672 1.5 1.5z" />
                </svg>
              </a>
            </div>
          </div>
        </div>
        <div className="text-start text-xs text-gray-500 mt-8">
          Bản quyền InnerBright 2025 Bảo lưu mọi quyền
        </div>
      </footer>
    </div>
  );
}
