import Link from "next/link";
import Image from "next/image";
import { Phone, Mail, Facebook, Instagram, Youtube } from "lucide-react";

export default function Footer() {
  return (
    <footer className="bg-white border-t border-gray-200">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
        <div className="grid grid-cols-1 md:grid-cols-4 gap-8 lg:gap-12">
          {/* Column 1 - Logo and Contact */}
          <div className="space-y-6">
            {/* Logo */}
            <Link href="/" className="inline-block">
              <Image
                src="/innerbright-logo.svg"
                alt="InnerBright Training & Coaching"
                width={200}
                height={60}
                className="h-16 w-auto"
              />
            </Link>

            {/* Contact Info */}
            <div className="space-y-3">
              <a
                href="tel:0908370968"
                className="flex items-center gap-3 text-gray-700 hover:text-blue-600 transition-colors group"
              >
                <div className="w-10 h-10 rounded-full bg-gray-100 flex items-center justify-center group-hover:bg-blue-50 transition-colors">
                  <Phone className="w-5 h-5" />
                </div>
                <span className="text-lg font-medium">090 837 09 68</span>
              </a>

              <a
                href="mailto:info@innerbright.vn"
                className="flex items-center gap-3 text-gray-700 hover:text-blue-600 transition-colors group"
              >
                <div className="w-10 h-10 rounded-full bg-gray-100 flex items-center justify-center group-hover:bg-blue-50 transition-colors">
                  <Mail className="w-5 h-5" />
                </div>
                <span className="text-lg font-medium">info@innerbright.vn</span>
              </a>
            </div>
          </div>

          {/* Column 2 - INNNER Links */}
          <div>
            <h3 className="text-xl font-bold text-gray-900 mb-4">INNNER</h3>
            <ul className="space-y-3">
              <li>
                <Link href="/support" className="text-gray-600 hover:text-blue-600 transition-colors">
                  Our Support
                </Link>
              </li>
              <li>
                <Link href="/blog" className="text-gray-600 hover:text-blue-600 transition-colors">
                  Blog
                </Link>
              </li>
              <li>
                <Link href="/contact" className="text-gray-600 hover:text-blue-600 transition-colors">
                  Contact us
                </Link>
              </li>
              <li>
                <Link href="/write" className="text-gray-600 hover:text-blue-600 transition-colors">
                  Write For Us
                </Link>
              </li>
              <li>
                <Link href="/group" className="text-gray-600 hover:text-blue-600 transition-colors">
                  Group
                </Link>
              </li>
            </ul>
          </div>

          {/* Column 3 - OUR SERVICES */}
          <div>
            <h3 className="text-xl font-bold text-gray-900 mb-4">OUR SERVICES</h3>
            <ul className="space-y-3">
              <li>
                <Link href="/dao-tao-doanh-nghiep" className="text-gray-600 hover:text-blue-600 transition-colors">
                  Đào tạo doanh nghiệp
                </Link>
              </li>
              <li>
                <Link href="/khai-van-ca-nhan" className="text-gray-600 hover:text-blue-600 transition-colors">
                  Khai vấn cá nhân
                </Link>
              </li>
              <li>
                <Link href="/dao-tao-doanh-nghiep-2" className="text-gray-600 hover:text-blue-600 transition-colors">
                  Đào tạo doanh nghiệp
                </Link>
              </li>
              <li>
                <Link href="/khai-van-ca-nhan-2" className="text-gray-600 hover:text-blue-600 transition-colors">
                  Khai vấn cá nhân
                </Link>
              </li>
              <li>
                <Link href="/dao-tao-doanh-nghiep-3" className="text-gray-600 hover:text-blue-600 transition-colors">
                  Đào tạo doanh nghiệp
                </Link>
              </li>
            </ul>
          </div>

          {/* Column 4 - Social Media */}
          <div>
            <h3 className="text-xl font-bold text-gray-900 mb-4 invisible">Social</h3>
            <div className="flex gap-4">
              <a
                href="https://facebook.com/innerbright"
                target="_blank"
                rel="noopener noreferrer"
                className="w-12 h-12 rounded-full bg-gray-100 hover:bg-blue-600 flex items-center justify-center transition-colors group"
                aria-label="Facebook"
              >
                <Facebook className="w-6 h-6 text-gray-700 group-hover:text-white" />
              </a>
              <a
                href="https://instagram.com/innerbright"
                target="_blank"
                rel="noopener noreferrer"
                className="w-12 h-12 rounded-full bg-gray-100 hover:bg-pink-600 flex items-center justify-center transition-colors group"
                aria-label="Instagram"
              >
                <Instagram className="w-6 h-6 text-gray-700 group-hover:text-white" />
              </a>
              <a
                href="https://tiktok.com/@innerbright"
                target="_blank"
                rel="noopener noreferrer"
                className="w-12 h-12 rounded-full bg-gray-100 hover:bg-black flex items-center justify-center transition-colors group"
                aria-label="TikTok"
              >
                <svg className="w-6 h-6 text-gray-700 group-hover:text-white" fill="currentColor" viewBox="0 0 24 24">
                  <path d="M19.59 6.69a4.83 4.83 0 01-3.77-4.25V2h-3.45v13.67a2.89 2.89 0 01-5.2 1.74 2.89 2.89 0 012.31-4.64 2.93 2.93 0 01.88.13V9.4a6.84 6.84 0 00-1-.05A6.33 6.33 0 005 20.1a6.34 6.34 0 0010.86-4.43v-7a8.16 8.16 0 004.77 1.52v-3.4a4.85 4.85 0 01-1-.1z"/>
                </svg>
              </a>
              <a
                href="https://youtube.com/@innerbright"
                target="_blank"
                rel="noopener noreferrer"
                className="w-12 h-12 rounded-full bg-gray-100 hover:bg-red-600 flex items-center justify-center transition-colors group"
                aria-label="YouTube"
              >
                <Youtube className="w-6 h-6 text-gray-700 group-hover:text-white" />
              </a>
            </div>
          </div>
        </div>
      </div>

      {/* Bottom Copyright */}
      <div className="border-t border-gray-200">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
          <p className="text-center text-gray-500 text-sm italic">
            Bản quyền InnerBright 2025 Bảo lưu mọi quyền
          </p>
        </div>
      </div>
    </footer>
  );
}
