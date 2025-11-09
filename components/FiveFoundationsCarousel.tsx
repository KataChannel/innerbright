"use client";

import { useState } from "react";
import { ChevronLeft, ChevronRight } from "lucide-react";

const foundations = [
  {
    id: 1,
    title: "KHAI PHÁ TIỀM NĂNG NÃO BỘ",
    description: "Thay vì chỉ truyền tải kiến thức một chiều, chúng tôi kích hoạt bộ não của bạn để việc học trở nên tự nhiên và hiệu quả. Các phương pháp giảng dạy được thiết kế dựa trên cách bộ não tiếp thu và xử lý thông tin, giúp bạn nắm bắt kiến thức một cách sâu sắc và ghi nhớ lâu dài, giảm thiểu sự phụ thuộc vào việc ghi chép thụ động.",
    bgColor: "bg-[#FFA500]",
  },
  {
    id: 2,
    title: "KHAI PHÁ TIỀM NĂNG NÃO BỘ",
    description: "Thay vì chỉ truyền tải kiến thức một chiều, chúng tôi kích hoạt bộ não của bạn để việc học trở nên tự nhiên và hiệu quả. Các phương pháp giảng dạy được thiết kế dựa trên cách bộ não tiếp thu và xử lý thông tin, giúp bạn nắm bắt kiến thức một cách sâu sắc và ghi nhớ lâu dài, giảm thiểu sự phụ thuộc vào việc ghi chép thụ động.",
    bgColor: "bg-blue-600",
  },
  {
    id: 3,
    title: "KHAI PHÁ TIỀM NĂNG NÃO BỘ",
    description: "Thay vì chỉ truyền tải kiến thức một chiều, chúng tôi kích hoạt bộ não của bạn để việc học trở nên tự nhiên và hiệu quả. Các phương pháp giảng dạy được thiết kế dựa trên cách bộ não tiếp thu và xử lý thông tin, giúp bạn nắm bắt kiến thức một cách sâu sắc và ghi nhớ lâu dài, giảm thiểu sự phụ thuộc vào việc ghi chép thụ động.",
    bgColor: "bg-[#FFA500]",
  },
  {
    id: 4,
    title: "KHAI PHÁ TIỀM NĂNG NÃO BỘ",
    description: "Thay vì chỉ truyền tải kiến thức một chiều, chúng tôi kích hoạt bộ não của bạn để việc học trở nên tự nhiên và hiệu quả. Các phương pháp giảng dạy được thiết kế dựa trên cách bộ não tiếp thu và xử lý thông tin, giúp bạn nắm bắt kiến thức một cách sâu sắc và ghi nhớ lâu dài, giảm thiểu sự phụ thuộc vào việc ghi chép thụ động.",
    bgColor: "bg-blue-600",
  },
  {
    id: 5,
    title: "KHAI PHÁ TIỀM NĂNG NÃO BỘ",
    description: "Thay vì chỉ truyền tải kiến thức một chiều, chúng tôi kích hoạt bộ não của bạn để việc học trở nên tự nhiên và hiệu quả. Các phương pháp giảng dạy được thiết kế dựa trên cách bộ não tiếp thu và xử lý thông tin, giúp bạn nắm bắt kiến thức một cách sâu sắc và ghi nhớ lâu dài, giảm thiểu sự phụ thuộc vào việc ghi chép thụ động.",
    bgColor: "bg-[#FFA500]",
  },
];

export default function FiveFoundationsCarousel() {
  const [currentIndex, setCurrentIndex] = useState(0);

  const nextSlide = () => {
    setCurrentIndex((prev) => (prev + 1) % foundations.length);
  };

  const prevSlide = () => {
    setCurrentIndex((prev) => (prev - 1 + foundations.length) % foundations.length);
  };

  // Get visible cards based on screen size
  const getVisibleCards = () => {
    const cards = [];
    for (let i = 0; i < 3; i++) {
      const index = (currentIndex + i) % foundations.length;
      cards.push(foundations[index]);
    }
    return cards;
  };

  return (
    <section className="py-20 bg-gray-50 relative overflow-hidden">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        {/* Title */}
        <div className="text-center mb-12">
          <h2 className="text-3xl md:text-4xl lg:text-5xl font-bold text-[#FFA500] mb-4">
            5 NỀN TẢNG TẠO NÊN SỰ KHÁC BIỆT
          </h2>
          <h3 className="text-2xl md:text-3xl lg:text-4xl font-bold text-blue-600">
            TRONG MỖI KHÓA HỌC TẠI INNERBRIGHT
          </h3>
        </div>

        {/* Carousel Container */}
        <div className="relative">
          {/* Navigation Buttons */}
          <button
            onClick={prevSlide}
            className="absolute left-0 top-1/2 -translate-y-1/2 -translate-x-4 lg:-translate-x-12 z-10 bg-white rounded-full p-3 shadow-lg hover:bg-gray-100 transition-colors"
            aria-label="Previous slide"
          >
            <ChevronLeft className="w-8 h-8 text-gray-600" />
          </button>

          <button
            onClick={nextSlide}
            className="absolute right-0 top-1/2 -translate-y-1/2 translate-x-4 lg:translate-x-12 z-10 bg-white rounded-full p-3 shadow-lg hover:bg-gray-100 transition-colors"
            aria-label="Next slide"
          >
            <ChevronRight className="w-8 h-8 text-gray-600" />
          </button>

          {/* Cards Grid */}
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 lg:gap-8">
            {getVisibleCards().map((foundation, idx) => (
              <div
                key={`${foundation.id}-${idx}`}
                className={`${foundation.bgColor} rounded-3xl p-8 text-white shadow-xl transform transition-all duration-300 hover:scale-105`}
              >
                {/* Number Badge */}
                <div className="flex items-center mb-6">
                  <div className="w-16 h-16 rounded-full bg-white flex items-center justify-center mr-4">
                    <span className="text-3xl font-bold text-gray-800">
                      {foundation.id}
                    </span>
                  </div>
                  <div className="flex-1">
                    <h4 className="text-xl md:text-2xl font-bold leading-tight">
                      {foundation.title}
                    </h4>
                  </div>
                </div>

                {/* Divider */}
                <div className="w-full h-0.5 bg-white opacity-30 mb-6"></div>

                {/* Description */}
                <p className="text-sm md:text-base leading-relaxed">
                  {foundation.description}
                </p>
              </div>
            ))}
          </div>
        </div>

        {/* Bottom Text */}
        <div className="mt-16 text-center">
          <h3 className="text-3xl md:text-4xl font-bold text-[#FFA500] mb-6">
            TẠI INNERBRIGHT
          </h3>
          <p className="text-gray-600 text-lg md:text-xl italic max-w-4xl mx-auto leading-relaxed">
            chúng tôi không chỉ trang bị cho bạn kiến thức NLP, chúng tôi dẫn dắt bạn thức sự thấu suốt bản chất của từng công cụ. Bạn sẽ hiểu tại sao chúng hoạt động, khi nào nên sử dụng và làm thế nào để tích hợp chúng một cách linh hoạt vào cuộc sống.
          </p>
        </div>
      </div>
    </section>
  );
}
