"use client";
export default function Layout({ children }: { children: React.ReactNode }) {
  return (
    <div className="min-h-screen bg-gray-100 font-inter">
      <section
        id="section1"
        className="relative bg-white rounded-xl shadow-lg overflow-hidden mb-8"
      >
        {/* Background Image with Overlay */}
        <div className="relative h-80 lg:h-96">
          <img
            src="https://placehold.co/800x300/b0e0e6/000000?text=InnerBright+Team"
            alt="InnerBright Team"
            className="w-full h-full object-cover object-center"
          />

          {/* Gradient Overlay for Better Text Readability */}
          <div className="absolute inset-0 bg-gradient-to-r from-black/60 to-transparent" />

          {/* Content Container */}
          <div className="absolute inset-0 flex items-center">
            <div className="container mx-auto px-8 lg:px-12">
              <div className="max-w-2xl">
                <h1 className="text-3xl lg:text-5xl font-bold text-white mb-6 leading-tight">
                  CÂU CHUYỆN VỀ InnerBright
                </h1>
                <p className="text-lg lg:text-xl text-white/90 leading-relaxed">
                  InnerBright Training & Coaching được thành lập từ năm 2020 bởi
                  nhà đào tạo Chloe Quý Châu
                </p>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* New Section: MANG TRONG MÌNH KHÁT VỌNG */}
      <section className="bg-white rounded-xl shadow-lg p-8 mb-8">
        <h2 className="text-center text-3xl font-bold text-blue-700 mb-8">
          MANG TRONG MÌNH KHÁT VỌNG
        </h2>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
          {/* SỨ MỆNH */}
          <div className="relative bg-white rounded-xl shadow-lg overflow-hidden">
            {/* Background Image with Overlay */}
            <div className="relative h-48 lg:h-56">
              <img
                src="https://placehold.co/400x200/a0c4ff/ffffff?text=Mission"
                alt="Mission"
                className="w-full h-full object-cover object-center"
              />

              {/* Gradient Overlay for Better Text Readability */}
              <div className="absolute inset-0 bg-gradient-to-r from-black/60 to-transparent" />

              {/* Content Container */}
              <div className="absolute inset-0 flex items-center">
                <div className="container mx-auto px-8 lg:px-12">
                  <div className="max-w-2xl">
                    <h3 className="text-xl lg:text-2xl font-bold text-white mb-4 leading-tight">
                      SỨ MỆNH
                    </h3>
                    <p className="text-sm lg:text-base text-white/90 leading-relaxed">
                      Tạo dựng cuộc sống thịnh vượng hơn cho người người Việt
                      Nam bằng việc khai phóng tiềm năng và giúp phát huy tối đa
                      nội lực của mỗi cá nhân.
                    </p>
                  </div>
                </div>
              </div>
            </div>
          </div>

          {/* TẦM NHÌN */}
          <div className="relative bg-white rounded-xl shadow-lg overflow-hidden">
            {/* Background Image with Overlay */}
            <div className="relative h-48 lg:h-56">
              <img
                src="https://placehold.co/400x200/a0c4ff/ffffff?text=Vision"
                alt="Vision"
                className="w-full h-full object-cover object-center"
              />

              {/* Gradient Overlay for Better Text Readability */}
              <div className="absolute inset-0 bg-gradient-to-r from-black/60 to-transparent" />

              {/* Content Container */}
              <div className="absolute inset-0 flex items-center">
                <div className="container mx-auto px-8 lg:px-12">
                  <div className="max-w-2xl">
                    <h3 className="text-xl lg:text-2xl font-bold text-white mb-4 leading-tight">
                      TẦM NHÌN
                    </h3>
                    <p className="text-sm lg:text-base text-white/90 leading-relaxed">
                      Trang bị cho mỗi người Việt Nam đủ sở hữu tư duy phát
                      triển bản thân đúng đắn, hiệu quả và bền vững.
                    </p>
                  </div>
                </div>
              </div>
            </div>
          </div>

          {/* GIÁ TRỊ CỐT LÕI */}
          <div className="relative bg-white rounded-xl shadow-lg overflow-hidden">
            {/* Background Image with Overlay */}
            <div className="relative h-48 lg:h-56">
              <img
                src="https://placehold.co/400x200/a0c4ff/ffffff?text=Values"
                alt="Values"
                className="w-full h-full object-cover object-center"
              />

              {/* Gradient Overlay for Better Text Readability */}
              <div className="absolute inset-0 bg-gradient-to-r from-black/60 to-transparent" />

              {/* Content Container */}
              <div className="absolute inset-0 flex items-center">
                <div className="container mx-auto px-8 lg:px-12">
                  <div className="max-w-2xl">
                    <h3 className="text-xl lg:text-2xl font-bold text-white mb-4 leading-tight">
                      GIÁ TRỊ CỐT LÕI
                    </h3>
                    <ul className="text-sm lg:text-base text-white/90 leading-relaxed">
                      <li>• Hệ thống</li>
                      <li>• Hợp nhất</li>
                      <li>• Tử tế</li>
                    </ul>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* New Section: PHÁT TRIỂN BẢN THÂN */}
      <section className="bg-white rounded-xl shadow-lg p-8 mb-8 text-center">
        <h2 className="text-2xl font-bold text-gray-800 mb-4">
          PHÁT TRIỂN BẢN THÂN
        </h2>
        <p className="text-xl font-semibold text-blue-600 mb-6">
          là sức mạnh để thay đổi thế giới
        </p>
        <p className="text-gray-700 mb-4">
          Thế giới của mỗi người chính là bề sinh trắc, nơi mỗi chúng ta sống và
          làm việc cùng các cộng đồng. Tại InnerBright, điều quan trọng không
          chỉ là được thành công cá nhân, mà còn là sử dụng sức mạnh này để tạo
          ra sự khác biệt và ảnh hưởng đến hệ sinh thái của riêng bạn. Bằng cách
          phát triển bản thân, chúng ta tự trở thành người cầm trịch và sẽ thay
          đổi cả thế giới.
        </p>
        <p className="text-gray-700 font-semibold">
          Chúng tôi - những con người tại InnerBright rất tự hào và sẵn sàng
          đồng hành cùng bạn trên hành trình này để khai phóng tiềm năng và giúp
          phát huy tối đa nội lực của riêng Bạn
        </p>
      </section>

      {/* New Section: HỆ THỐNG CHỨNG NHẬN */}
      <section className="bg-white rounded-xl shadow-lg p-8 mb-8">
        <h2 className="text-center text-3xl font-bold text-blue-700 mb-8">
          HỆ THỐNG CHỨNG NHẬN
        </h2>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
          {/* Certification 1 */}
          <div className="p-6 bg-gray-50 rounded-lg shadow-md">
            <p className="text-gray-700 mb-4">
              InnerBright Training & Coaching tự hào là thành viên chính thức và
              uy tín của Hiệp Hội NLP Hoa Kỳ (ABNLP) trong hơn 5 năm liên tục.
              ABNLP với vai trò là tổ chức lớn nhất và lâu đời nhất về Lập Trình
              Ngôn Ngữ Tư Duy (NLP - Neuro Linguistic Programming) tại Hoa Kỳ,
              có chứng nhận sự chuyên nghiệp và chất lượng đào tạo của
              InnerBright.
            </p>
            <h3 className="text-xl font-semibold text-gray-800 mb-2">
              HỌC VIỆN ĐÀO TẠO NLP
            </h3>
            <img
              src="https://placehold.co/200x100/e0e0e0/333333?text=ABNLP+Logo"
              alt="ABNLP Logo"
              className="w-full h-auto rounded-md"
            />
          </div>

          {/* Certification 2 */}
          <div className="p-6 bg-gray-50 rounded-lg shadow-md">
            <p className="text-gray-700 mb-4">
              Đặc biệt, InnerBright là đơn vị tiên phong tại Việt Nam được Ban
              Cố Vấn (Board of Advisors) của Hiệp Hội ABNLP chứng thực bằng
              chương trình NLP Master Coach Quốc Tế. Điều này đảm bảo rằng không
              chỉ về kiến thức chuyên môn, mà còn về đạo đức nghề nghiệp,
              InnerBright mang đến chương trình đào tạo NLP Coaching chuẩn quốc
              tế tại Việt Nam.
            </p>
            <h3 className="text-xl font-semibold text-gray-800 mb-2">
              HỌC VIỆN ĐÀO TẠO NLP COACHING
            </h3>
            <img
              src="https://placehold.co/200x100/e0e0e0/333333?text=NLP+Coaching+Logo"
              alt="NLP Coaching Logo"
              className="w-full h-auto rounded-md"
            />
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer className="bg-gray-800 text-white py-12">
        <div className="container mx-auto px-8 lg:px-12">
          <div className="grid grid-cols-1 md:grid-cols-4 gap-8">
            {/* Company Info */}
            <div className="col-span-1 md:col-span-2">
              <h3 className="text-2xl font-bold mb-4">InnerBright</h3>
              <p className="text-gray-300 mb-4">
                Training & Coaching được thành lập từ năm 2020 bởi nhà đào tạo Chloe Quý Châu
              </p>
              <p className="text-gray-300">
                Khai phóng tiềm năng và giúp phát huy tối đa nội lực của mỗi cá nhân
              </p>
            </div>

            {/* Contact Info */}
            <div>
              <h4 className="text-lg font-semibold mb-4">Liên Hệ</h4>
              <div className="space-y-2 text-gray-300">
                <p>📧 info@innerbright.vn</p>
                <p>📞 (+84) 123 456 789</p>
                <p>📍 Hồ Chí Minh, Việt Nam</p>
              </div>
            </div>

            {/* Quick Links */}
            <div>
              <h4 className="text-lg font-semibold mb-4">Liên Kết</h4>
              <div className="space-y-2 text-gray-300">
                <a href="#" className="block hover:text-white transition-colors">Về Chúng Tôi</a>
                <a href="#" className="block hover:text-white transition-colors">Khóa Học</a>
                <a href="#" className="block hover:text-white transition-colors">Coaching</a>
                <a href="#" className="block hover:text-white transition-colors">Liên Hệ</a>
              </div>
            </div>
          </div>

          {/* Footer Bottom */}
          <div className="border-t border-gray-700 mt-8 pt-8 text-center text-gray-400">
            <p>&copy; 2024 InnerBright Training & Coaching. Tất cả quyền được bảo lưu.</p>
          </div>
        </div>
      </footer>

      {children}
    </div>
  );
}
