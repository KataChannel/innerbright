export default function AdminPage() {
    return (
        <div className="space-y-6">
            <div className="bg-white rounded-lg shadow p-6">
                <h1 className="text-2xl font-bold text-gray-800 mb-4">
                    Dashboard Quản Trị
                </h1>
                <p className="text-gray-600 mb-6">
                    Chào mừng bạn đến với trang quản trị InnerBright
                </p>
                
                {/* Quick Stats */}
                <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mb-6">
                    <div className="bg-blue-50 p-4 rounded-lg">
                        <h3 className="text-lg font-semibold text-blue-800">Tổng bài viết</h3>
                        <p className="text-2xl font-bold text-blue-900">
                            {typeof window !== 'undefined' ? 
                                JSON.parse(localStorage.getItem('posts') || '[]').length : 0}
                        </p>
                    </div>
                    <div className="bg-green-50 p-4 rounded-lg">
                        <h3 className="text-lg font-semibold text-green-800">Danh mục</h3>
                        <p className="text-2xl font-bold text-green-900">5</p>
                    </div>
                    <div className="bg-purple-50 p-4 rounded-lg">
                        <h3 className="text-lg font-semibold text-purple-800">Người dùng</h3>
                        <p className="text-2xl font-bold text-purple-900">12</p>
                    </div>
                </div>

                {/* Quick Actions */}
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div className="border border-gray-200 p-4 rounded-lg">
                        <h3 className="font-semibold text-gray-800 mb-2">Quản lý nội dung</h3>
                        <p className="text-gray-600 text-sm mb-3">
                            Tạo, chỉnh sửa và quản lý bài viết
                        </p>
                        <a 
                            href="/admin/baiviet" 
                            className="inline-block bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700 transition-colors"
                        >
                            Quản lý bài viết
                        </a>
                    </div>
                    
                    <div className="border border-gray-200 p-4 rounded-lg">
                        <h3 className="font-semibold text-gray-800 mb-2">Cài đặt hệ thống</h3>
                        <p className="text-gray-600 text-sm mb-3">
                            Cấu hình và quản lý danh mục
                        </p>
                        <a 
                            href="/admin/categories" 
                            className="inline-block bg-green-600 text-white px-4 py-2 rounded hover:bg-green-700 transition-colors"
                        >
                            Quản lý danh mục
                        </a>
                    </div>
                </div>
            </div>
        </div>
    );
}