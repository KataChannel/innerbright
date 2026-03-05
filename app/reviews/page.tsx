"use client";

import Navbar from "@/components/Navbar";
import { useState } from "react";

export default function ReviewsPage() {
  const reviews = [
    {
      name: "Nguyễn Văn A",
      role: "Học viên khóa NLP Practitioner",
      content: "Khóa học thực sự đã thay đổi tư duy của tôi. Chloe truyền tải kiến thức rất dễ hiểu và thực tiễn.",
      rating: 5
    },
    {
      name: "Trần Thị B",
      role: "Doanh nhân",
      content: "Các kỹ thuật Time Line Therapy giúp tôi giải tỏa được nhiều rào cản tâm lý trong kinh doanh.",
      rating: 5
    },
    {
      name: "Lê Văn C",
      role: "Quản lý cấp cao",
      content: "Chương trình đào tạo doanh nghiệp của InnerBright rất bài bản và mang lại hiệu quả tức thì.",
      rating: 4
    }
  ];

  return (
    <div className="min-h-screen bg-white dark:bg-black font-sans">
      <Navbar />
      
      <main className="pt-32 pb-24">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center mb-20">
            <h1 className="text-4xl font-extrabold text-zinc-900 dark:text-white sm:text-5xl">
              Cảm nhận từ <span className="text-[#0047C6]">Học viên</span>
            </h1>
            <p className="mt-4 text-xl text-zinc-600 dark:text-zinc-400">
              Những câu chuyện thành công và sự thay đổi tích cực từ cộng đồng InnerBright
            </p>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
            {reviews.map((review, i) => (
              <div key={i} className="bg-zinc-50 p-8 rounded-3xl border border-zinc-100 relative dark:bg-zinc-900 dark:border-zinc-800">
                <div className="flex gap-1 mb-6">
                  {Array.from({ length: 5 }).map((_, starI) => (
                    <svg
                      key={starI}
                      className={`h-5 w-5 ${starI < review.rating ? 'text-[#FFB03E]' : 'text-zinc-300'}`}
                      fill="currentColor"
                      viewBox="0 0 20 20"
                    >
                      <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z" />
                    </svg>
                  ))}
                </div>
                <p className="text-lg text-zinc-700 leading-relaxed mb-8 dark:text-zinc-300">
                  "{review.content}"
                </p>
                <div className="flex items-center gap-4">
                  <div className="h-12 w-12 rounded-full bg-[#0047C6]/10 flex items-center justify-center text-[#0047C6] font-bold">
                    {review.name[0]}
                  </div>
                  <div>
                    <h4 className="font-bold text-zinc-900 dark:text-white">{review.name}</h4>
                    <p className="text-sm text-zinc-500">{review.role}</p>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>
      </main>

      <footer className="bg-zinc-900 py-12 text-white text-center">
        <p className="text-zinc-500 text-sm">© 2026 InnerBright Training & Coaching</p>
      </footer>
    </div>
  );
}
