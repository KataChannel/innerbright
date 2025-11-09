"use client";

import { useState } from "react";
import { ChevronLeft, ChevronRight } from "lucide-react";
import Image from "next/image";

const trainers = [
  {
    id: 1,
    name: "Chloe Quý Châu",
    title: "CHUYÊN GIA ĐÀO TẠO",
    credentials: [
      "NLP Coach Trainer",
      "ABNLP I Time Line Therapy ®"
    ],
    bio: [
      "Trong quá trình học tập và huấn luyện tại Việt Nam, Chloe Quý Châu là chuyên gia nguyên vật liệu, kiêm trúc ABNLP Coaching Division cấp phép đào tạo NLP Master Coach. Chloe tập trung truyền tải nguyên bản công cụ NLP để học viên hiểu rõ, dùng, dụ và ứng dụng linh hoạt vào cuộc sống.",
      "Chloe cũng là một trong số ít người Việt đầu tiên được chứng nhận đào tạo Time Line Therapy® trực tiếp từ Hiệp Hội, một phương pháp mạnh mẽ giúp xử lý sâu sắc các cảm xúc"
    ],
    description: "Với tâm huyết truyền tải tinh thần chính trực của NLP, InnerBright không đơn thuần mang đến một hệ thống bài bản. Chúng tôi kiên tạo một hành trình phát triển bản thân toàn diện, hấp nhất sức mạnh nội tại của bạn với sự trưởng thành ở cả bốn khía cạnh then chốt: Trí tuệ lý trí (mental intelligence), Trí tuệ cảm xúc (emotional intelligence), Trí tuệ thể chất (physical intelligence) và trí tuệ tâm linh (spiritual intelligence).",
    description2: "Chúng tôi nuôi dưỡng những giá trị cốt lõi bạn can, tạo nên một hệ sinh thái nội tại vững mạnh và bền vững, giúp bạn phát triển toàn diện và sống một cuộc đời trọn vẹn.",
    image: "https://placehold.co/600x400/2563eb/white?text=Chloe+Quy+Chau",
    groupImage: "https://placehold.co/500x400/FFA500/white?text=InnerBright+Team",
    certificates: [
      {
        title: "Chứng nhận năng lực khả năng cũng của NLP",
        image: "https://placehold.co/200x200/333/white?text=ABNLP",
        subtitle: "Hiệp Hội ABNLP"
      },
      {
        title: "Chứng nhận đạt năng lực về huấn luyện và phát triển doanh nghiệp",
        image: "https://placehold.co/200x200/e74c3c/white?text=Action+Coach",
        subtitle: "Action Coach"
      },
      {
        title: "Chứng nhận năng lực trị liệu với khảo sát đường kỷ tương TimeLine Therapy®",
        image: "https://placehold.co/200x200/333/white?text=TLT",
        subtitle: "Time Line Therapy®"
      },
      {
        title: "Hội viên chuyên về chuyên môn, hệ thế và phát triển kiến thức nền về phần sự được hy nghiệp",
        image: "https://placehold.co/200x200/333/white?text=ABNLP+Member",
        subtitle: "International Organization"
      }
    ]
  }
];

export default function TrainerCarousel() {
  const [currentIndex, setCurrentIndex] = useState(0);

  const nextSlide = () => {
    setCurrentIndex((prev) => (prev + 1) % trainers.length);
  };

  const prevSlide = () => {
    setCurrentIndex((prev) => (prev - 1 + trainers.length) % trainers.length);
  };

  const trainer = trainers[currentIndex];

  return (
    <section className="py-20 bg-white relative">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        {/* Navigation Buttons - Only show if multiple trainers */}
        {trainers.length > 1 && (
          <>
            <button
              onClick={prevSlide}
              className="absolute left-4 top-1/2 -translate-y-1/2 z-10 bg-white rounded-full p-3 shadow-lg hover:bg-gray-100 transition-colors"
              aria-label="Previous trainer"
            >
              <ChevronLeft className="w-6 h-6 text-gray-600" />
            </button>

            <button
              onClick={nextSlide}
              className="absolute right-4 top-1/2 -translate-y-1/2 z-10 bg-white rounded-full p-3 shadow-lg hover:bg-gray-100 transition-colors"
              aria-label="Next trainer"
            >
              <ChevronRight className="w-6 h-6 text-gray-600" />
            </button>
          </>
        )}

        <div className="grid grid-cols-1 lg:grid-cols-2 gap-12 items-start mb-16">
          {/* Left Column - Images and Description */}
          <div className="space-y-6">
            {/* Group Image with Orange Border */}
            <div className="relative">
              <div className="absolute -top-3 left-0 w-32 h-1 bg-[#FFA500]"></div>
              <div className="bg-white rounded-2xl overflow-hidden shadow-lg border-4 border-gray-100 mt-4">
                <img
                  src={trainer.groupImage}
                  alt="InnerBright Team"
                  className="w-full h-auto object-cover"
                />
              </div>
            </div>

            {/* Description Text */}
            <div className="space-y-4 text-gray-600 text-sm md:text-base leading-relaxed">
              <p>{trainer.description}</p>
              <p>{trainer.description2}</p>
            </div>
          </div>

          {/* Right Column - Trainer Info */}
          <div className="space-y-6">
            {/* Trainer Title */}
            <div>
              <h3 className="text-[#FFA500] text-lg md:text-xl font-semibold mb-2">
                {trainer.title}
              </h3>
              <h2 className="text-3xl md:text-4xl lg:text-5xl font-bold text-[#FFA500]">
                {trainer.name}
              </h2>
            </div>

            {/* Credentials */}
            <div className="space-y-1">
              {trainer.credentials.map((cred, index) => (
                <p key={index} className="text-gray-700 font-medium">
                  •{cred}
                </p>
              ))}
            </div>

            {/* Bio */}
            <div className="space-y-4 text-gray-600 text-sm md:text-base leading-relaxed">
              {trainer.bio.map((paragraph, index) => (
                <p key={index}>{paragraph}</p>
              ))}
            </div>

            {/* Trainer Image - Circular with Orange/Blue Border */}
            <div className="flex justify-center lg:justify-end">
              <div className="relative">
                <div className="w-64 h-64 md:w-80 md:h-80 rounded-full overflow-hidden border-8 border-[#FFA500] shadow-xl">
                  <img
                    src={trainer.image}
                    alt={trainer.name}
                    className="w-full h-full object-cover"
                  />
                </div>
                {/* Blue accent on border */}
                <div className="absolute bottom-0 right-0 w-32 h-32 border-8 border-blue-600 rounded-full" style={{ clipPath: 'polygon(50% 50%, 100% 0, 100% 100%)' }}></div>
              </div>
            </div>
          </div>
        </div>

        {/* Certificates Section */}
        <div className="mt-16">
          {/* Journey Description */}
          <p className="text-center text-gray-500 italic text-sm md:text-base mb-8 max-w-4xl mx-auto">
            Hành trình chuyên nghiệp của Chloe được xây dựng trên nền tảng kinh nghiệm khôi vía (coaching) được chứng nhận bởi hàng loạt các tổ chức uy tín trên thế giới, bao gồm:
          </p>

          {/* Certificates Grid */}
          <div className="grid grid-cols-2 md:grid-cols-4 gap-6 md:gap-8">
            {trainer.certificates.map((cert, index) => (
              <div key={index} className="flex flex-col items-center text-center">
                <div className="w-32 h-32 md:w-40 md:h-40 mb-4 flex items-center justify-center">
                  <img
                    src={cert.image}
                    alt={cert.title}
                    className="w-full h-full object-contain"
                  />
                </div>
                <p className="text-xs md:text-sm text-gray-600 leading-tight">
                  {cert.title}
                </p>
              </div>
            ))}
          </div>

          {/* Bottom Note */}
          <p className="text-center text-gray-400 text-xs md:text-sm mt-8 italic">
            Rất nhiều điều trong
          </p>
        </div>
      </div>
    </section>
  );
}
