import { ReactNode } from 'react';
import Link from 'next/link';

interface AdminLayoutProps {
    children: ReactNode;
}

export default function AdminLayout({ children }: AdminLayoutProps) {
    return (
        <div className="min-h-screen bg-gray-100 flex">
            {/* Sidebar */}
            <div className="w-64 bg-white shadow-lg">
                <div className="p-6">
                    <h1 className="text-xl font-bold text-gray-800">Admin Panel</h1>
                </div>
                <nav className="mt-6">
                    <div className="px-6 py-2">
                        <Link 
                            href="/admin" 
                            className="flex items-center px-4 py-2 text-gray-700 hover:bg-gray-100 rounded-lg"
                        >
                            <span>Dashboard</span>
                        </Link>
                    </div>
                    <div className="px-6 py-2">
                        <Link 
                            href="/admin/baiviet" 
                            className="flex items-center px-4 py-2 text-gray-700 hover:bg-gray-100 rounded-lg"
                        >
                            <span>Bài viết</span>
                        </Link>
                    </div>
                    <div className="px-6 py-2">
                        <Link 
                            href="/admin/categories" 
                            className="flex items-center px-4 py-2 text-gray-700 hover:bg-gray-100 rounded-lg"
                        >
                            <span>Danh mục</span>
                        </Link>
                    </div>
                </nav>
            </div>

            {/* Main Content */}
            <div className="flex-1 p-8">
                {children}
            </div>
        </div>
    );
}