"use client";

export default function NLPCertificationPage() {
  return (
    <div className="min-h-screen bg-gray-50">
      {/* Hero Section - Bộ thẻ Ứng Dụng NLP */}
      <section className="relative w-full min-h-[500px] md:min-h-[600px] overflow-hidden bg-[#1e3a8a]">
        {/* Blue gradient overlay */}
        <div className="absolute inset-0 bg-gradient-to-r from-[#1e3a8a] via-[#2563eb] to-[#1e40af]" />
        
        {/* Large NLP Background Text */}
        <div className="absolute inset-0 flex items-center justify-start overflow-hidden opacity-10">
          <div className="text-white font-bold" style={{ fontSize: '20rem', lineHeight: '1', letterSpacing: '-0.05em' }}>
            NLP
          </div>
        </div>

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
        </div>

        {/* Content Container */}
        <div className="relative max-w-7xl mx-auto h-full px-4 sm:px-6 lg:px-8 py-12 md:py-16">
          <div className="flex flex-col md:flex-row items-center justify-between gap-8">
            {/* Left Content */}
            <div className="flex-1 z-10 w-full md:max-w-2xl">
              <div className="space-y-4 md:space-y-6">
                {/* Title */}
                <h2 className="text-white text-3xl sm:text-4xl md:text-5xl font-normal">
                  Bộ thẻ
                </h2>

                {/* Main Title */}
                <h1 className="text-white text-5xl sm:text-6xl md:text-7xl lg:text-8xl font-bold leading-tight">
                  ỨNG DỤNG NLP
                </h1>

                {/* Subtitle */}
                <h3 className="text-[#FFA500] text-2xl sm:text-3xl md:text-4xl font-bold">
                  Neuro - Linguistic Programming
                </h3>

                {/* Description */}
                <p className="text-white text-base sm:text-lg md:text-xl leading-relaxed max-w-2xl">
                  Cuộc sống của Bạn là do chính Bạn tạo ra và Lập Trình Ngôn Ngữ Tư Duy - NLP (Neuro Linguistic Programming) là chìa khóa giúp Bạn khai phá sức mạnh của bản thân để hiện thực hoá những kết quả mà Bạn mong muốn.
                </p>
              </div>
            </div>

            {/* Right Cards */}
            <div className="flex-1 flex items-center justify-center md:justify-end z-10">
              <div className="relative flex gap-4 md:gap-6 perspective-1000">
                {/* Card 1 - Left (Green/Teal) */}
                <div className="relative w-[100px] h-[140px] sm:w-[120px] sm:h-[170px] md:w-[150px] md:h-[220px] lg:w-[180px] lg:h-[260px] transform -rotate-12 translate-y-8 hover:rotate-0 transition-all duration-500">
                  <div className="absolute inset-0 bg-gradient-to-br from-teal-400 to-teal-600 rounded-2xl md:rounded-3xl shadow-2xl overflow-hidden border-4 md:border-6 border-white">
                    <div className="p-3 md:p-5 text-white">
                      <div className="text-[10px] md:text-xs font-bold mb-2 opacity-90">InnerBright</div>
                      <div className="text-xs md:text-sm lg:text-base font-bold leading-tight mb-1">Hà Sinh Thái NLP</div>
                      <div className="text-[8px] md:text-[10px] opacity-80">Neuro-Linguistic<br/>Programming</div>
                    </div>
                    <div className="absolute bottom-0 left-0 right-0 h-1/3 bg-white/20 backdrop-blur-sm flex items-center justify-center">
                      <div className="w-12 h-12 md:w-16 md:h-16 lg:w-20 lg:h-20 bg-white rounded-full flex items-center justify-center">
                        <svg className="w-6 h-6 md:w-8 md:h-8 lg:w-10 lg:h-10 text-teal-600" viewBox="0 0 24 24" fill="currentColor">
                          <path d="M12 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm0 2c-2.67 0-8 1.34-8 4v2h16v-2c0-2.66-5.33-4-8-4z"/>
                        </svg>
                      </div>
                    </div>
                    <div className="absolute bottom-3 left-3 right-3 text-[8px] md:text-[10px] text-white text-center">
                      01
                    </div>
                  </div>
                </div>

                {/* Card 2 - Center (Orange) - Featured */}
                <div className="relative w-[140px] h-[190px] sm:w-[170px] sm:h-[230px] md:w-[220px] md:h-[300px] lg:w-[260px] lg:h-[360px] transform hover:scale-105 transition-all duration-500 z-10">
                  <div className="absolute inset-0 bg-gradient-to-br from-orange-400 via-orange-500 to-orange-600 rounded-2xl md:rounded-3xl shadow-2xl overflow-hidden border-4 md:border-6 border-white">
                    <div className="p-4 md:p-6 lg:p-8 text-white">
                      <div className="text-xs md:text-sm font-bold mb-3 opacity-90">InnerBright</div>
                      <div className="text-lg sm:text-xl md:text-3xl lg:text-4xl font-bold leading-tight mb-3">
                        BỘ THẺ<br/>ỨNG DỤNG
                      </div>
                      <div className="text-xs md:text-sm lg:text-base opacity-90">
                        Neuro-Linguistic<br/>Programming
                      </div>
                    </div>
                    <div className="absolute bottom-0 left-0 right-0 bg-white/20 backdrop-blur-sm p-4 md:p-6">
                      <div className="text-white text-[10px] md:text-xs leading-relaxed">
                        Lập trình ngôn ngữ tư duy
                      </div>
                    </div>
                    {/* Large N watermark */}
                    <div className="absolute top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2 opacity-20">
                      <div className="text-white text-7xl md:text-9xl lg:text-[12rem] font-bold">N</div>
                    </div>
                  </div>
                </div>

                {/* Card 3 - Right (Blue) */}
                <div className="relative w-[100px] h-[140px] sm:w-[120px] sm:h-[170px] md:w-[150px] md:h-[220px] lg:w-[180px] lg:h-[260px] transform rotate-12 translate-y-8 hover:rotate-0 transition-all duration-500">
                  <div className="absolute inset-0 bg-gradient-to-br from-blue-500 to-blue-700 rounded-2xl md:rounded-3xl shadow-2xl overflow-hidden border-4 md:border-6 border-white">
                    <div className="p-3 md:p-5 text-white">
                      <div className="text-[10px] md:text-xs font-bold mb-2 opacity-90">InnerBright</div>
                      <div className="text-xs md:text-sm lg:text-base font-bold leading-tight mb-2">
                        Chuyên gia<br/>đào tạo NLP<br/>cấp quốc tế
                      </div>
                    </div>
                    <div className="absolute bottom-0 left-0 right-0 p-3 md:p-4 bg-white/20 backdrop-blur-sm">
                      <div className="text-[10px] md:text-xs text-white font-medium">
                        Chloe Quý Châu
                      </div>
                      <div className="text-[8px] md:text-[10px] text-white opacity-80 mt-1">
                        NLP Master Coach
                      </div>
                    </div>
                    <div className="absolute top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2 opacity-10">
                      <div className="text-white text-6xl md:text-7xl font-bold">33</div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
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

          .perspective-1000 {
            perspective: 1000px;
          }
        `}</style>
      </section>

      {/* Additional content sections can be added here */}
    </div>
  );
}
