"use client";

import { useState, useEffect } from "react";
import Image from "next/image";

interface Slide {
  id: number;
  title: string;
  subtitle: string;
  description: string;
  instructor: string;
  image: string;
}

const slides: Slide[] = [
  {
    id: 1,
    title: "CÂU CHUYỆN",
    subtitle: "Về INNERBRIGHT",
    description: "InnerBright Training & Coaching\nđược thành lập từ năm 2020",
    instructor: "Bởi nhà đào tạo\nCHLOE QUÝ CHÂU",
    image: "/slide1.svg"
  },
  {
    id: 2,
    title: "CHƯƠNG TRÌNH",
    subtitle: "ĐÀO TẠO NLP",
    description: "Khóa học NLP chuyên nghiệp\nvới chứng chỉ quốc tế",
    instructor: "Bởi nhà đào tạo\nCHLOE QUÝ CHÂU",
    image: "/slide2.svg"
  },
  {
    id: 3,
    title: "PHƯƠNG PHÁP",
    subtitle: "TIME LINE THERAPY®",
    description: "Trị liệu dòng thời gian\ngiải phóng cảm xúc tiêu cực",
    instructor: "Bởi nhà đào tạo\nCHLOE QUÝ CHÂU",
    image: "/slide3.svg"
  }
];

export default function HeroCarousel() {
  const [currentSlide, setCurrentSlide] = useState(0);
  const [isAutoPlaying, setIsAutoPlaying] = useState(true);

  useEffect(() => {
    if (!isAutoPlaying) return;

    const interval = setInterval(() => {
      setCurrentSlide((prev) => (prev + 1) % slides.length);
    }, 5000);

    return () => clearInterval(interval);
  }, [isAutoPlaying]);

  const goToSlide = (index: number) => {
    setCurrentSlide(index);
    setIsAutoPlaying(false);
    setTimeout(() => setIsAutoPlaying(true), 10000);
  };

  return (
    <section className="relative w-full h-[500px] md:h-[600px] overflow-hidden bg-[#1e3a8a]">
      {/* Blue gradient overlay */}
      <div className="absolute inset-0 bg-gradient-to-r from-[#1e3a8a] via-[#2563eb] to-[#1e40af]" />
      
      {/* Animated Background Particles */}
      <div className="absolute inset-0 overflow-hidden opacity-60">
        <div className="particles-container">
          {[...Array(80)].map((_, i) => (
            <div
              key={i}
              className="particle"
              style={{
                left: `${Math.random() * 100}%`,
                top: `${Math.random() * 100}%`,
                animationDelay: `${Math.random() * 5}s`,
                animationDuration: `${5 + Math.random() * 10}s`
              }}
            />
          ))}
        </div>
        {/* Dotted pattern on left and right */}
        <div className="absolute left-0 top-0 bottom-0 w-1/4 opacity-30">
          <div className="grid grid-cols-12 gap-1 h-full">
            {[...Array(200)].map((_, i) => (
              <div key={i} className="w-1 h-1 bg-cyan-400 rounded-full" />
            ))}
          </div>
        </div>
        <div className="absolute right-0 top-0 bottom-0 w-1/4 opacity-30">
          <div className="grid grid-cols-12 gap-1 h-full">
            {[...Array(200)].map((_, i) => (
              <div key={i} className="w-1 h-1 bg-cyan-400 rounded-full" />
            ))}
          </div>
        </div>
      </div>

      {/* Carousel Container */}
      <div className="relative max-w-7xl mx-auto h-full px-4 sm:px-6 lg:px-8">
        <div className="flex flex-col md:flex-row items-center justify-between h-full gap-8 py-8 md:py-0">
          {/* Left Content */}
          <div className="flex-1 z-10 w-full md:w-auto md:max-w-2xl">
            <div className="space-y-3 md:space-y-5">
              {/* Title with Arrow */}
              <div className="flex items-center space-x-2 md:space-x-3">
                <h2 className="text-[#FFA500] text-2xl sm:text-3xl md:text-4xl lg:text-5xl font-bold tracking-wide">
                  {slides[currentSlide].title}
                </h2>
                <div className="flex items-center">
                  {/* Decorative arrows */}
                  <svg className="w-6 h-6 md:w-8 md:h-8 text-white opacity-70" viewBox="0 0 24 24" fill="currentColor">
                    <path d="M8.59 16.59L13.17 12 8.59 7.41 10 6l6 6-6 6-1.41-1.41z"/>
                    <path d="M2.59 16.59L7.17 12 2.59 7.41 4 6l6 6-6 6-1.41-1.41z"/>
                  </svg>
                </div>
              </div>

              {/* Subtitle */}
              <h3 className="text-white text-3xl sm:text-4xl md:text-5xl lg:text-6xl font-bold leading-tight">
                {slides[currentSlide].subtitle}
              </h3>

              {/* Divider Line */}
              <div className="w-32 md:w-40 h-1 bg-[#FFA500]" />

              {/* Description */}
              <p className="text-white text-sm sm:text-base md:text-lg lg:text-xl font-light whitespace-pre-line leading-relaxed">
                {slides[currentSlide].description}
              </p>

              {/* Instructor Badge */}
              <div className="inline-block mt-4 md:mt-6">
                <div className="bg-[#60a5fa]/40 backdrop-blur-sm px-6 md:px-10 py-3 md:py-4 rounded-2xl border border-white/10 shadow-lg">
                  <p className="text-white text-base md:text-xl font-bold whitespace-pre-line text-center leading-snug">
                    {slides[currentSlide].instructor}
                  </p>
                </div>
              </div>
            </div>
          </div>

          {/* Right Image */}
          <div className="flex-1 flex items-center justify-center md:justify-end z-10">
            <div className="relative w-[280px] h-[280px] sm:w-[350px] sm:h-[350px] md:w-[450px] md:h-[450px] lg:w-[550px] lg:h-[550px]">
              <div className="absolute inset-0 bg-white/5 rounded-full blur-3xl" />
              <Image
                src={slides[currentSlide].image}
                alt={slides[currentSlide].instructor}
                fill
                className="object-contain drop-shadow-2xl transition-all duration-700"
                priority
                unoptimized
              />
            </div>
          </div>
        </div>
      </div>

      {/* Carousel Indicators */}
      <div className="absolute bottom-6 md:bottom-10 left-1/2 transform -translate-x-1/2 flex space-x-2 md:space-x-3 z-20">
        {slides.map((_, index) => (
          <button
            key={index}
            onClick={() => goToSlide(index)}
            className={`rounded-full transition-all duration-300 ${
              currentSlide === index
                ? "bg-white w-3 h-3 md:w-3.5 md:h-3.5"
                : "bg-white/50 hover:bg-white/70 w-2.5 h-2.5 md:w-3 md:h-3"
            }`}
            aria-label={`Go to slide ${index + 1}`}
          />
        ))}
      </div>

      <style jsx>{`
        .particles-container {
          position: absolute;
          width: 100%;
          height: 100%;
        }

        .particle {
          position: absolute;
          width: 3px;
          height: 3px;
          background: rgba(96, 165, 250, 0.8);
          border-radius: 50%;
          animation: float linear infinite;
          box-shadow: 0 0 8px rgba(96, 165, 250, 0.6);
        }

        @keyframes float {
          0% {
            transform: translateY(0) translateX(0) scale(1);
            opacity: 0;
          }
          10% {
            opacity: 1;
          }
          50% {
            opacity: 0.8;
            transform: translateY(-50vh) translateX(30px) scale(1.2);
          }
          90% {
            opacity: 0.5;
          }
          100% {
            transform: translateY(-100vh) translateX(60px) scale(0.8);
            opacity: 0;
          }
        }

        @media (max-width: 768px) {
          .particle {
            width: 2px;
            height: 2px;
          }
        }
      `}</style>
    </section>
  );
}