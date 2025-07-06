import React from 'react';
import { Metadata } from 'next';

export const metadata: Metadata = {
    title: 'Footer - Your E-commerce',
    description: 'Footer section for Your E-commerce.',
};

export default function FooterPage() {
    return (
        <footer className="bg-gray-900 text-white py-12">
            <div className="max-w-7xl mx-auto px-4">
                <div className="grid grid-cols-1 md:grid-cols-4 gap-8">
                    {/* Company Info */}
                    <div className="space-y-4">
                        <h3 className="text-xl font-bold">Innerbright</h3>
                        <p className="text-gray-400">
                            Cửa hàng trực tuyến hàng đầu với sản phẩm chất lượng cao
                        </p>
                        <div className="flex space-x-4">
                            <a href="#" className="text-gray-400 hover:text-white">
                                <span className="sr-only">Facebook</span>
                                📘
                            </a>
                            <a href="#" className="text-gray-400 hover:text-white">
                                <span className="sr-only">Instagram</span>
                                📷
                            </a>
                            <a href="#" className="text-gray-400 hover:text-white">
                                <span className="sr-only">Twitter</span>
                                🐦
                            </a>
                        </div>
                    </div>

                    {/* Quick Links */}
                    <div className="space-y-4">
                        <h3 className="text-xl font-bold">Liên kết nhanh</h3>
                        <ul className="space-y-2 text-gray-400">
                            <li><a href="/" className="hover:text-white">Trang chủ</a></li>
                            <li><a href="/products" className="hover:text-white">Sản phẩm</a></li>
                            <li><a href="/about" className="hover:text-white">Về chúng tôi</a></li>
                            <li><a href="/contact" className="hover:text-white">Liên hệ</a></li>
                        </ul>
                    </div>

                    {/* Customer Service */}
                    <div className="space-y-4">
                        <h3 className="text-xl font-bold">Hỗ trợ khách hàng</h3>
                        <ul className="space-y-2 text-gray-400">
                            <li><a href="/help" className="hover:text-white">Trung tâm hỗ trợ</a></li>
                            <li><a href="/shipping" className="hover:text-white">Vận chuyển</a></li>
                            <li><a href="/returns" className="hover:text-white">Đổi trả</a></li>
                            <li><a href="/warranty" className="hover:text-white">Bảo hành</a></li>
                        </ul>
                    </div>

                    {/* Contact Info */}
                    <div className="space-y-4">
                        <h3 className="text-xl font-bold">Thông tin liên hệ</h3>
                        <div className="text-gray-400 space-y-2">
                            <p>📍 123 Đường ABC, Quận 1, TP.HCM</p>
                            <p>📞 0123 456 789</p>
                            <p>✉️ info@innerbright.com</p>
                            <p>🕒 8:00 - 22:00 (Thứ 2 - Chủ nhật)</p>
                        </div>
                    </div>
                </div>

                {/* Bottom Section */}
                <div className="border-t border-gray-800 mt-8 pt-8 text-center text-gray-400">
                    <p>&copy; 2025 Innerbright. Tất cả quyền được bảo lưu.</p>
                </div>
            </div>
        </footer>
    );
}
