import Footer from "@/app/components/common/Footer";
import Header from "@/app/components/common/Header";
export const metadata = {
  title: "Kata Offical",
};
export default function Layout({ children }: { children: React.ReactNode }) {
  return (
    <div className="root-layout space-y-4">
          <div className="min-h-screen bg-gray-100 font-inter">
      {/* Tailwind CSS CDN for demonstration. In a Next.js project, Tailwind would be configured. */}
      <script src="https://cdn.tailwindcss.com"></script>
      {/* Google Fonts - Inter */}
      <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet" />

      {/* Header Section */}
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
            {[
              "Về InnerBright",
              "NLP",
              "Time Line Therapy",
              "Đào tạo doanh nghiệp",
              "Khai vấn cá nhân",
              "Khoá học",
              "Bộ thẻ NLP",
              "Thư viện",
              "Liên hệ",
            ].map((item) => (
              <li key={item}>
                <a
                  href="#"
                  className="block py-2 px-3 rounded-md text-gray-700 hover:bg-blue-500 hover:text-white transition-colors duration-200 ease-in-out"
                >
                  {item}
                </a>
              </li>
            ))}
          </ul>
        </div>
      </nav>

      {/* Hero Section */}
      <main className="container mx-auto px-4 py-8 mt-6">
        <div className="relative bg-white rounded-xl shadow-lg overflow-hidden flex flex-col lg:flex-row items-center lg:items-stretch">
          {/* Text Content */}
          <div className="p-8 lg:p-12 flex flex-col justify-center lg:w-1/2 z-10">
            <h1 className="text-3xl lg:text-4xl font-bold text-gray-800 mb-4 leading-tight">
              CÂU CHUYỆN VỀ InnerBright
            </h1>
            <p className="text-lg lg:text-xl text-gray-600">
              InnerBright Training & Coaching được thành lập từ năm 2020 bởi nhà đào tạo Chloe Quý Châu
            </p>
          </div>

          {/* Image Section */}
          <div className="lg:w-1/2 h-64 lg:h-auto overflow-hidden rounded-b-xl lg:rounded-l-none lg:rounded-r-xl">
            <img
              src="https://placehold.co/800x600/b0e0e6/000000?text=InnerBright+Team" // Placeholder image
              alt="InnerBright Team"
              className="w-full h-full object-cover object-center"
              onError={(e:any) => {
                e.target.onerror = null;
                e.target.src = "https://placehold.co/800x600/cccccc/333333?text=Image+Not+Found";
              }}
            />
          </div>
        </div>
      </main>

      {/* Optional: Footer or other sections could go here */}
    </div>

      <header className="sticky top-0 z-50">
        <Header />
      </header>
      <main>{children}</main>
      <Footer />
    </div>
  );
}
