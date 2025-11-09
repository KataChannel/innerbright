import HeroCarousel from "@/components/HeroCarousel";
import FiveFoundationsCarousel from "@/components/FiveFoundationsCarousel";
import TrainerCarousel from "@/components/TrainerCarousel";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Lightbulb, Clock, Building2 } from "lucide-react";

export default function Home() {
  return (
    <div className="min-h-screen bg-gray-50">
      {/* Hero Carousel */}
      <HeroCarousel />

      {/* Mission Section - Mạng Trong Mình Khát Vọng */}
      <section className="py-16 bg-white">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          {/* Title */}
          <div className="text-center mb-16">
            <h2 className="text-4xl md:text-5xl font-bold text-[#FFA500] mb-2">
              MẠNG TRONG MÌNH
            </h2>
            <h3 className="text-4xl md:text-5xl font-bold text-blue-600">
              KHÁT VỌNG
            </h3>
          </div>

          {/* Content Grid */}
          <div className="grid grid-cols-1 lg:grid-cols-3 gap-8 lg:gap-12 items-center">
            {/* Left Column - Sứ Mệnh */}
            <div className="space-y-8">
              <div>
                <h4 className="text-2xl md:text-3xl font-bold text-[#FFA500] mb-4">
                  SỨ MỆNH
                </h4>
                <div className="w-20 h-1 bg-blue-600 mb-4"></div>
                <p className="text-gray-700 leading-relaxed text-sm md:text-base">
                  Tạo dựng cuộc sống thịnh vượng hơn cho người người Việt Nam bằng việc khai phóng tiềm năng và giúp phát huy tối đa nội lực của mỗi cá nhân.
                </p>
              </div>

              <div>
                <h4 className="text-2xl md:text-3xl font-bold text-[#FFA500] mb-4">
                  TẦM NHÌN
                </h4>
                <div className="w-20 h-1 bg-blue-600 mb-4"></div>
                <p className="text-gray-700 leading-relaxed text-sm md:text-base">
                  Trang bị cho mỗi người Việt Nam đủ sở hữu tư duy phát triển bản thân dũng dẫn, hiểu quả và bền vững.
                </p>
              </div>
            </div>

            {/* Center Column - Target Diagram */}
            <div className="flex justify-center">
              <div className="relative w-full max-w-md aspect-square">
                {/* Target circles */}
                <div className="absolute inset-0 flex items-center justify-center">
                  <div className="relative w-full h-full">
                    {/* Outer circle */}
                    <div className="absolute inset-0 rounded-full border-[20px] border-blue-300 opacity-60"></div>
                    {/* Middle circle */}
                    <div className="absolute inset-[15%] rounded-full border-[20px] border-blue-400 opacity-70"></div>
                    {/* Inner circle */}
                    <div className="absolute inset-[30%] rounded-full border-[20px] border-blue-500 opacity-80"></div>
                    {/* Center circle */}
                    <div className="absolute inset-[45%] rounded-full bg-gradient-to-br from-blue-600 to-purple-600"></div>
                    
                    {/* Arrow pointing to center */}
                    <div className="absolute top-[10%] right-[10%] transform rotate-[-30deg]">
                      <svg width="120" height="120" viewBox="0 0 120 120" className="text-blue-600">
                        <defs>
                          <marker id="arrowhead" markerWidth="10" markerHeight="10" refX="9" refY="3" orient="auto">
                            <polygon points="0 0, 10 3, 0 6" fill="currentColor" />
                          </marker>
                        </defs>
                        <line x1="10" y1="10" x2="80" y2="80" stroke="currentColor" strokeWidth="3" markerEnd="url(#arrowhead)" />
                      </svg>
                      {/* Arrow decoration */}
                      <div className="absolute -top-2 -left-2">
                        <div className="flex space-x-1">
                          <div className="w-3 h-3 bg-blue-500 transform rotate-45"></div>
                          <div className="w-3 h-3 bg-blue-500 transform rotate-45"></div>
                          <div className="w-3 h-3 bg-blue-500 transform rotate-45"></div>
                        </div>
                      </div>
                    </div>

                    {/* Connection lines to text */}
                    <svg className="absolute inset-0 w-full h-full" style={{ pointerEvents: 'none' }}>
                      <line x1="20%" y1="30%" x2="5%" y2="15%" stroke="#3B82F6" strokeWidth="2" />
                      <line x1="50%" y1="10%" x2="50%" y2="0%" stroke="#3B82F6" strokeWidth="2" />
                      <line x1="80%" y1="50%" x2="95%" y2="50%" stroke="#3B82F6" strokeWidth="2" />
                    </svg>
                  </div>
                </div>
              </div>
            </div>

            {/* Right Column - Giá Trị Cốt Lõi */}
            <div>
              <h4 className="text-2xl md:text-3xl font-bold text-[#FFA500] mb-4">
                GIÁ TRỊ CỐT LÕI
              </h4>
              <div className="w-20 h-1 bg-blue-600 mb-6"></div>
              <ul className="space-y-3 text-gray-700">
                <li className="flex items-start text-sm md:text-base">
                  <span className="text-blue-600 mr-2 text-xl">•</span>
                  <span>Hệ thống</span>
                </li>
                <li className="flex items-start text-sm md:text-base">
                  <span className="text-blue-600 mr-2 text-xl">•</span>
                  <span>Hợp nhất</span>
                </li>
                <li className="flex items-start text-sm md:text-base">
                  <span className="text-blue-600 mr-2 text-xl">•</span>
                  <span>Từ tế</span>
                </li>
              </ul>
            </div>
          </div>
        </div>
      </section>

      {/* Personal Development Section - Phát Triển Bản Thân */}
      <section className="py-16 bg-gradient-to-r from-[#FFA500] to-[#FF8C00]">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-8 lg:gap-12 items-center">
            {/* Left Column - Text Content */}
            <div className="text-white space-y-6">
              <h2 className="text-4xl md:text-5xl font-bold leading-tight">
                PHÁT TRIỂN BẢN THÂN
              </h2>
              <h3 className="text-2xl md:text-3xl font-semibold">
                LÀ SỨC MẠNH ĐỂ THAY ĐỔI THỂ GIỚI
              </h3>
              
              <p className="text-base md:text-lg leading-relaxed">
                Thế giới của mỗi người chính là bê sinh trắc, nơi mỗi chúng ta sống và làm việc cùng các cộng đồng. Tại InnerBright, điều quan trọng không chỉ là được thành công cá nhân, mà còn là sử dụng sức mạnh này để tạo ra sự khác biệt và ảnh hưởng đến hệ sinh thái của riêng bạn. Bằng cách phát triển bản thân, chúng ta tự trở thành người cảm trich và sẽ thay đổi cả thế giới.
              </p>
              
              <p className="text-base md:text-lg font-semibold leading-relaxed">
                Chúng tôi - những con người tại InnerBright rất tự hào và sẵn sàng đồng hành cùng bạn trên hành trình này để khai phóng tiềm năng và giúp phát huy tối đa nội lực của riêng Bạn
              </p>
            </div>

            {/* Right Column - Image */}
            <div className="flex justify-center lg:justify-end">
              <div className="relative w-full max-w-md lg:max-w-lg">
                <div className="relative rounded-3xl overflow-hidden shadow-2xl bg-gray-900 aspect-[4/3]">
                  <img 
                    src="https://placehold.co/800x600/FFA500/white?text=Personal+Development" 
                    alt="Phát triển bản thân"
                    className="w-full h-full object-cover"
                  />
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Certification Section - Hệ Thống Chứng Nhận */}
      <section className="py-20 bg-white">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          {/* Title */}
          <div className="text-center mb-12">
            <h2 className="text-4xl md:text-5xl font-bold text-blue-600 mb-8">
              HỆ THỐNG CHỨNG NHẬN
            </h2>
          </div>

          <div className="grid grid-cols-1 lg:grid-cols-2 gap-12 items-start">
            {/* Left Column - 5 NĂM Badge and Description */}
            <div className="space-y-6">
              {/* Large 5 NĂM Badge */}
              <div className="flex justify-center lg:justify-start mb-8">
                <div className="relative">
                  <div className="text-[#FFA500] font-bold text-center">
                    <div className="text-[180px] md:text-[220px] leading-none" style={{ fontFamily: 'Arial, sans-serif' }}>
                      5
                    </div>
                    <div className="text-5xl md:text-6xl -mt-8">
                      NĂM
                    </div>
                  </div>
                  {/* Orange border outline */}
                  <div className="absolute inset-0 border-8 border-[#FFA500] rounded-3xl" style={{ margin: '-20px' }}></div>
                </div>
              </div>

              {/* Description Text */}
              <div className="space-y-4 text-gray-700 text-base md:text-lg leading-relaxed">
                <p>
                  <strong>InnerBright Training & Coaching</strong> tự hào là thành viên chính thức và uy tín của <strong>Hiệp Hội NLP Hoa Kỳ (ABNLP)</strong> trong hơn 5 năm liên tục.
                </p>
                <p>
                  <strong>ABNLP</strong>
                </p>
                <p>
                  với vai trò là tổ chức lớn nhất và lâu đời nhất về Lập Trình Ngôn Ngữ Tư Duy (NLP - Neuro Linguistic Programming) tại Hoa Kỳ, có chứng nhận sự chuyên nghiệp và chất lượng đào tạo của InnerBright.
                </p>
                <p>
                  Đặc biệt, InnerBright là đơn vị tiên phong tại Việt Nam được Ban Cố
                </p>
              </div>
            </div>

            {/* Right Column - Certificates */}
            <div className="space-y-8">
              {/* Certificate 1 - NLP Training */}
              <div className="bg-white rounded-2xl shadow-lg p-6 border border-gray-100">
                <div className="relative aspect-[4/3] bg-gray-100 rounded-xl overflow-hidden mb-4">
                  <img 
                    src="https://placehold.co/800x600/2563eb/white?text=ABNLP+Institute+Certificate" 
                    alt="Chứng nhận đào tạo NLP"
                    className="w-full h-full object-contain"
                  />
                </div>
                <div className="border-t-4 border-blue-600 pt-4">
                  <h3 className="text-xl md:text-2xl font-bold text-gray-900 text-center">
                    HỌC VIỆN ĐÀO TẠO NLP
                  </h3>
                </div>
              </div>

              {/* Certificate 2 - NLP Coaching */}
              <div className="bg-white rounded-2xl shadow-lg p-6 border border-gray-100">
                <div className="relative aspect-[4/3] bg-gray-100 rounded-xl overflow-hidden mb-4">
                  <img 
                    src="https://placehold.co/800x600/2563eb/white?text=ABNLP+Coaching+Certificate" 
                    alt="Chứng nhận đào tạo NLP Coaching"
                    className="w-full h-full object-contain"
                  />
                </div>
                <div className="border-t-4 border-blue-600 pt-4">
                  <h3 className="text-xl md:text-2xl font-bold text-gray-900 text-center">
                    HỌC VIỆN ĐÀO TẠO NLP COACHING
                  </h3>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Why InnerBright Section - Vì sao InnerBright */}
      <section className="relative py-16 bg-blue-600 overflow-hidden">
        {/* Decorative dots - left side */}
        <div className="absolute left-4 top-1/2 -translate-y-1/2 flex flex-col gap-3">
          {[...Array(6)].map((_, rowIndex) => (
            <div key={rowIndex} className="flex gap-3">
              {[...Array(3)].map((_, colIndex) => (
                <div key={colIndex} className="w-2 h-2 rounded-full bg-white opacity-30"></div>
              ))}
            </div>
          ))}
        </div>

        {/* Decorative dots - right side */}
        <div className="absolute right-4 top-1/4 flex flex-col gap-3">
          {[...Array(6)].map((_, rowIndex) => (
            <div key={rowIndex} className="flex gap-3">
              {[...Array(3)].map((_, colIndex) => (
                <div key={colIndex} className="w-2 h-2 rounded-full bg-white opacity-30"></div>
              ))}
            </div>
          ))}
        </div>

        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-8 lg:gap-12 items-center">
            {/* Left Column - Text Content */}
            <div className="text-white space-y-6 relative z-10">
              <h2 className="text-4xl md:text-5xl font-bold text-[#FFA500] leading-tight">
                Vì sao InnerBright
              </h2>
              <h3 className="text-2xl md:text-3xl text-white">
                là lựa chọn khác biệt?
              </h3>
              
              <div className="space-y-6 mt-8">
                <div>
                  <h4 className="text-2xl md:text-3xl font-bold mb-4">
                    NLP <span className="text-lg italic font-normal">(Neuro Linguistic Programming)</span>
                  </h4>
                  <p className="text-base md:text-lg leading-relaxed">
                    Lập trình ngôn ngữ tư duy, không chỉ là một tập hợp các kỹ thuật, mà là một hành trình khám phá sức mạnh nội tại để tạo ra sự chuyển hóa sâu sắc. Để ứng dụng NLP hiệu quả, sự thấu hiểu cội nguồn và nguyên lý hoạt động là then chốt.
                  </p>
                </div>
              </div>
            </div>

            {/* Right Column - Image with curved edge */}
            <div className="relative flex justify-center lg:justify-end">
              <div className="relative w-full max-w-md lg:max-w-lg">
                {/* Curved white background */}
                <div className="absolute inset-0 bg-white rounded-tl-[100px] rounded-bl-[100px] lg:rounded-tl-[150px] lg:rounded-bl-[150px]" style={{ clipPath: 'ellipse(80% 100% at 100% 50%)' }}></div>
                
                {/* Image */}
                <div className="relative z-10 pt-8 pr-8 lg:pt-12 lg:pr-12">
                  <img 
                    src="https://placehold.co/600x800/FFA500/white?text=Business+Woman" 
                    alt="Vì sao InnerBright"
                    className="w-full h-auto object-contain"
                  />
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Additional decorative dots - bottom right */}
        <div className="absolute right-8 bottom-1/4 flex flex-col gap-3">
          {[...Array(4)].map((_, rowIndex) => (
            <div key={rowIndex} className="flex gap-3">
              {[...Array(2)].map((_, colIndex) => (
                <div key={colIndex} className="w-2 h-2 rounded-full bg-white opacity-30"></div>
              ))}
            </div>
          ))}
        </div>
      </section>

      {/* Five Foundations Carousel Section */}
      <FiveFoundationsCarousel />

      {/* Trainer Carousel Section */}
      <TrainerCarousel />
    </div>
  );
}
