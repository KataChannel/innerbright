import React from 'react';
export default function HomePage() {

    return (
        <div className="flex flex-col items-center justify-center min-h-screen bg-gray-100">
            <div className="bg-white rounded-lg shadow-md p-6">
                <h2 className="text-2xl font-bold mb-4">Chào mừng đến với cửa hàng</h2>
                <p className="text-lg text-gray-700">
                    Khám phá bộ sưu tập sản phẩm chất lượng cao với giá tốt nhất
                </p>
            </div>
        </div>
    );
}