'use client'

import { ReactNode } from 'react';
import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { 
  Home, 
  FileText, 
  Folder, 
  Tag, 
  Plus,
  Layout,
  Eye,
  Settings,
  Edit3
} from 'lucide-react';

interface AdminLayoutProps {
    children: ReactNode;
}

interface NavItem {
  name: string;
  href: string;
  icon: React.ComponentType<{ className?: string }>;
  description?: string;
}

interface NavSection {
  title: string;
  items: NavItem[];
}

export default function AdminLayout({ children }: AdminLayoutProps) {
    const pathname = usePathname();

    const navigation: NavSection[] = [
        {
            title: "Tổng quan",
            items: [
                {
                    name: "Dashboard",
                    href: "/admin",
                    icon: Home,
                    description: "Trang chủ admin"
                }
            ]
        },
        {
            title: "Quản lý nội dung",
            items: [
                {
                    name: "Bài viết",
                    href: "/admin/posts",
                    icon: FileText,
                    description: "Quản lý tất cả bài viết"
                },
                {
                    name: "Tạo bài viết",
                    href: "/admin/posts/new",
                    icon: Plus,
                    description: "Viết bài mới với WebBuilder"
                },
                {
                    name: "Trang",
                    href: "/admin/pages",
                    icon: Layout,
                    description: "Quản lý trang tĩnh"
                },
                {
                    name: "Danh mục",
                    href: "/admin/categories",
                    icon: Folder,
                    description: "Quản lý danh mục bài viết"
                },
                {
                    name: "Thẻ",
                    href: "/admin/tags",
                    icon: Tag,
                    description: "Quản lý thẻ bài viết"
                }
            ]
        },
        {
            title: "Công cụ",
            items: [
                {
                    name: "WebBuilder",
                    href: "/admin/web-builder",
                    icon: Edit3,
                    description: "Trình soạn thảo nội dung"
                },
                {
                    name: "Xem Blog",
                    href: "/posts",
                    icon: Eye,
                    description: "Xem trang blog công khai"
                }
            ]
        },
        {
            title: "Cài đặt",
            items: [
                {
                    name: "Cấu hình",
                    href: "/admin/settings",
                    icon: Settings,
                    description: "Cài đặt hệ thống"
                }
            ]
        }
    ];

    const isActiveLink = (href: string) => {
        if (href === "/admin") {
            return pathname === "/admin";
        }
        return pathname.startsWith(href);
    };

    return (
        <div className="min-h-screen bg-gray-100 flex">
            {/* Sidebar */}
            <div className="w-72 bg-white shadow-lg border-r border-gray-200">
                <div className="p-6 border-b border-gray-200">
                    <div className="flex items-center">
                        <div className="w-10 h-10 bg-primary hover:bg-primary-hover rounded-lg flex items-center justify-center transition-colors">
                            <Edit3 className="w-6 h-6 text-white" />
                        </div>
                        <div className="ml-3">
                            <h1 className="text-xl font-bold text-gray-900">Admin Panel</h1>
                            <p className="text-sm text-gray-500">Blog Management</p>
                        </div>
                    </div>
                </div>
                
                <nav className="mt-6 px-4 pb-6">
                    {navigation.map((section) => (
                        <div key={section.title} className="mb-8">
                            <h3 className="px-3 text-xs font-semibold text-gray-500 uppercase tracking-wider mb-3">
                                {section.title}
                            </h3>
                            <div className="space-y-1">
                                {section.items.map((item) => {
                                    const isActive = isActiveLink(item.href);
                                    return (
                                        <Link
                                            key={item.name}
                                            href={item.href}
                                            className={`group flex items-center px-3 py-2 text-sm font-medium rounded-lg transition-colors ${
                                                isActive
                                                    ? 'bg-primary/10 text-primary border-r-2 border-primary'
                                                    : 'text-gray-700 hover:bg-primary/5 hover:text-primary'
                                            }`}
                                        >
                                            <item.icon
                                                className={`mr-3 h-5 w-5 ${
                                                    isActive 
                                                        ? 'text-primary' 
                                                        : 'text-gray-400 group-hover:text-primary'
                                                }`}
                                            />
                                            <div className="flex-1">
                                                <div className="flex items-center justify-between">
                                                    <span>{item.name}</span>
                                                    {isActive && (
                                                        <div className="w-2 h-2 bg-primary rounded-full"></div>
                                                    )}
                                                </div>
                                                {item.description && (
                                                    <p className="text-xs text-gray-500 mt-0.5">
                                                        {item.description}
                                                    </p>
                                                )}
                                            </div>
                                        </Link>
                                    );
                                })}
                            </div>
                        </div>
                    ))}
                </nav>

                {/* Quick Stats */}
                <div className="bottom-0 left-0 right-0 p-4 bg-gray-50 border-t border-gray-200">
                    <div className="text-center">
                        <p className="text-xs text-gray-500">
                            Blog Management System
                        </p>
                        <p className="text-xs text-gray-400 mt-1">
                            v1.0.0 - Aug 2025
                        </p>
                    </div>
                </div>
            </div>

            {/* Main Content */}
            <div className="flex-1 p-8">
                {children}
            </div>
        </div>
    );
}