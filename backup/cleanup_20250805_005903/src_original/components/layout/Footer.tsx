import Link from 'next/link';
import { siteConfig } from '@/lib/config/site';

export function Footer() {
  const currentYear = new Date().getFullYear();

  return (
    <footer className="bg-gray-50 border-t mt-16">
      <div className="container mx-auto px-4 py-12">
        <div className="grid grid-cols-1 md:grid-cols-4 gap-8">
          {/* Company Info */}
          <div className="md:col-span-2">
            <Link href="/" className="flex items-center mb-4">
              <img
                src="/images/logo.png"
                alt="InnerBright Logo"
                className="h-10 w-auto"
              />
            </Link>
            <p className="text-gray-600 mb-4 max-w-md">
              Khai phóng tiềm năng và phát huy tối đa nội lực của mỗi cá nhân thông qua 
              NLP và Time Line Therapy.
            </p>
            <div className="flex space-x-4">
              <a href={siteConfig.social?.facebook} className="text-blue-600 hover:text-blue-800">
                <svg className="h-6 w-6" fill="currentColor" viewBox="0 0 24 24">
                  <path d="M24 12.073c0-6.627-5.373-12-12-12s-12 5.373-12 12c0 5.99 4.388 10.954 10.125 11.854v-8.385H7.078v-3.47h3.047V9.43c0-3.007 1.792-4.669 4.533-4.669 1.312 0 2.686.235 2.686.235v2.953H15.83c-1.491 0-1.956.925-1.956 1.874v2.25h3.328l-.532 3.47h-2.796v8.385C19.612 23.027 24 18.062 24 12.073z"/>
                </svg>
              </a>
              <a href={siteConfig.social?.youtube} className="text-red-600 hover:text-red-800">
                <svg className="h-6 w-6" fill="currentColor" viewBox="0 0 24 24">
                  <path d="M23.498 6.186a3.016 3.016 0 0 0-2.122-2.136C19.505 3.545 12 3.545 12 3.545s-7.505 0-9.377.505A3.017 3.017 0 0 0 .502 6.186C0 8.07 0 12 0 12s0 3.93.502 5.814a3.016 3.016 0 0 0 2.122 2.136c1.871.505 9.376.505 9.376.505s7.505 0 9.377-.505a3.015 3.015 0 0 0 2.122-2.136C24 15.93 24 12 24 12s0-3.93-.502-5.814zM9.545 15.568V8.432L15.818 12l-6.273 3.568z"/>
                </svg>
              </a>
              <a href={siteConfig.social?.instagram} className="text-pink-600 hover:text-pink-800">
                <svg className="h-6 w-6" fill="currentColor" viewBox="0 0 24 24">
                  <path d="M12.017 0C5.396 0 .029 5.367.029 11.987c0 6.62 5.367 11.987 11.988 11.987c6.62 0 11.987-5.367 11.987-11.987C24.014 5.367 18.637.001 12.017.001zM15.47 8.987c.83 0 1.507.676 1.507 1.507c0 .83-.676 1.507-1.507 1.507c-.83 0-1.507-.676-1.507-1.507c0-.83.676-1.507 1.507-1.507z"/>
                </svg>
              </a>
            </div>
          </div>

          {/* Quick Links */}
          <div>
            <h3 className="font-bold text-lg mb-4 text-gray-800">Liên kết nhanh</h3>
            <ul className="space-y-2 text-gray-600">
              <li><Link href="/about" className="hover:text-blue-600">Về InnerBright</Link></li>
              <li><Link href="/nlp" className="hover:text-blue-600">NLP</Link></li>
              <li><Link href="/courses" className="hover:text-blue-600">Khoá học</Link></li>
              <li><Link href="/contact" className="hover:text-blue-600">Liên hệ</Link></li>
            </ul>
          </div>

          {/* Contact Info */}
          <div>
            <h3 className="font-bold text-lg mb-4 text-gray-800">Liên hệ</h3>
            <div className="space-y-2 text-gray-600">
              <p>Email: {siteConfig.contact?.email}</p>
              <p>Phone: {siteConfig.contact?.phone}</p>
              <p>{siteConfig.contact?.address}</p>
            </div>
          </div>
        </div>

        <div className="border-t mt-8 pt-8 text-center text-gray-500">
          <p>&copy; {currentYear} InnerBright Training & Coaching. Bảo lưu mọi quyền.</p>
        </div>
      </div>
    </footer>
  );
}
