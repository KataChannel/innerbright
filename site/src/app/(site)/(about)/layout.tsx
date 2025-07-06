"use client";
import Image from "next/image";
import { useState } from "react";

const AccordionItem = ({
  title,
  children,
}: {
  title: string;
  children: React.ReactNode;
}) => {
  const [isOpen, setIsOpen] = useState(false); // State to manage accordion open/close

  return (
    <div className="border-b border-gray-200">
      <button
        className="flex justify-between items-center w-full py-4 text-left text-lg font-medium text-gray-700 hover:text-blue-600 focus:outline-none"
        onClick={() => setIsOpen(!isOpen)} // Toggle isOpen state on click
      >
        <span>{title}</span>
        {/* Chevron icon, rotates based on isOpen state */}
        <svg
          className={`w-5 h-5 transition-transform duration-300 ${isOpen ? "rotate-180" : ""}`}
          fill="none"
          stroke="currentColor"
          viewBox="0 0 24 24"
          xmlns="http://www.w3.org/2000/svg"
        >
          <path
            strokeLinecap="round"
            strokeLinejoin="round"
            strokeWidth="2"
            d="M19 9l-7 7-7-7"
          ></path>
        </svg>
      </button>
      {/* Content area, conditionally rendered based on isOpen state */}
      {isOpen && (
        <div className="pb-4 text-gray-600 text-sm md:text-base">
          {children}
        </div>
      )}
    </div>
  );
};

export default function Layout({ children }: { children: React.ReactNode }) {
  return (
    <div className="min-h-screen bg-gray-100 font-inter">
      <section
        id="section1"
        className="relative bg-white rounded-xl shadow-lg overflow-hidden mb-8"
      >
        <div className="relative h-80 lg:h-96">
          <img
            src="https://placehold.co/800x300/b0e0e6/000000"
            alt="InnerBright Team"
            className="w-full h-full object-cover object-center"
          />
          <div className="absolute inset-0 bg-gradient-to-r from-black/60 to-transparent" />

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

      <section className="bg-white rounded-xl shadow-lg p-8 mb-8">
        <h2 className="text-center text-3xl font-bold text-blue-700 mb-8">
          MANG TRONG MÌNH KHÁT VỌNG
        </h2>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
          <div className="relative bg-white rounded-xl shadow-lg overflow-hidden">
            <div className="relative h-48 lg:h-56">
              <img
                src="https://placehold.co/400x200/a0c4ff/ffffff"
                alt="Mission"
                className="w-full h-full object-cover object-center"
              />

              <div className="absolute inset-0 bg-gradient-to-r from-black/60 to-transparent" />

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

          <div className="relative bg-white rounded-xl shadow-lg overflow-hidden">
            <div className="relative h-48 lg:h-56">
              <img
                src="https://placehold.co/400x200/a0c4ff/ffffff"
                alt="Vision"
                className="w-full h-full object-cover object-center"
              />

              <div className="absolute inset-0 bg-gradient-to-r from-black/60 to-transparent" />

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

          <div className="relative bg-white rounded-xl shadow-lg overflow-hidden">
            <div className="relative h-48 lg:h-56">
              <img
                src="https://placehold.co/400x200/a0c4ff/ffffff"
                alt="Values"
                className="w-full h-full object-cover object-center"
              />

              <div className="absolute inset-0 bg-gradient-to-r from-black/60 to-transparent" />

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

      <section className="bg-white rounded-xl shadow-lg p-8 mb-8">
        <h2 className="text-center text-3xl font-bold text-blue-700 mb-8">
          HỆ THỐNG CHỨNG NHẬN
        </h2>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
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
              src="https://placehold.co/200x100/e0e0e0/333333"
              alt="ABNLP Logo"
              className="w-full h-auto rounded-md"
            />
            <p className="text-sm text-gray-500 mt-2">
              Institute of Neuro Linguistic Programming
            </p>
          </div>

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
              src="https://placehold.co/200x100/e0e0e0/333333"
              alt="NLP Coaching Logo"
              className="w-full h-auto rounded-md"
            />
          </div>
        </div>
      </section>

      <section className="bg-white rounded-xl shadow-lg p-8 mb-8">
        <h1 className="text-center text-3xl md:text-4xl font-bold text-gray-800 mb-12">
          Vì sao InnerBright là lựa chọn khác biệt?
        </h1>
        <div className="relative h-80 lg:h-96">
          <img
            src="https://placehold.co/800x300/b0e0e6/000000"
            alt="Laptop showing NLP concepts"
            className="w-full h-full object-cover object-center"
          />
          <div className="absolute inset-0 bg-gradient-to-r from-black/60 to-transparent" />

          <div className="absolute inset-0 flex items-center">
            <div className="container mx-auto px-8 lg:px-12">
              <div className="max-w-2xl">
                <h2 className="text-5xl font-bold text-white mb-2">NLP</h2>
                <h3 className="text-xl lg:text-2xl font-semibold text-white mb-4">
                  Neuro Linguistic Programming
                </h3>
                <p className="text-lg lg:text-xl text-white/90 leading-relaxed">
                  Lập trình ngôn ngữ tư duy, không chỉ là một tập hợp các kỹ
                  thuật, mà là một hành trình khám phá sức mạnh nội tại để tạo
                  ra sự chuyển hóa sâu sắc. Để ứng dụng NLP hiệu quả, sự thấu
                  hiểu cội nguồn và nguyên lý hoạt động là then chốt.
                </p>
              </div>
            </div>
          </div>
        </div>
      </section>

      <section className="mx-auto container bg-white rounded-xl shadow-lg p-8 mb-8 gap-8 max-w-4xl">
        <div className="flex gap-8 justify-center">
          <div className="relative w-full max-w-xs md:max-w-none aspect-square">
            <img
              src="https://placehold.co/300x300/cccccc/333333"
              alt="Woman speaking at InnerBright"
              style={{ objectFit: "cover" }}
              className="rounded-full shadow-lg"
            />
          </div>
          <div className="text-gray-700">
            <h2 className="text-end text-3xl md:text-4xl font-bold text-gray-800 mb-4">
              Tại InnerBright
            </h2>
            <p className="text-sm md:text-base leading-relaxed mb-4">
              chúng tôi không chỉ trang bị cho bạn kiến thức NLP; chúng tôi dẫn
              dắt bạn thực sự thấu suốt bản chất của từng công cụ. Bạn sẽ hiểu
              tại sao chúng hoạt động, khi nào nên sử dụng và làm thế nào để
              tích hợp chúng một cách linh hoạt vào cuộc sống.
            </p>
          </div>
        </div>
        <div className="bg-white mt-16">
          <p className="mb-4">
            Với tâm huyết truyền tải tinh thần chính trực của NLP, InnerBright
            không đơn thuần mang đến một hệ thống bài bản. Chúng tôi kiến tạo
            một hành trình phát triển bản thân toàn diện, hấp nhất sức mạnh nội
            tại của bạn với sự trưởng thành ở cả bốn khía cạnh then chốt: trí
            tuệ lý trí (mental intelligence), trí tuệ cảm xúc (emotional
            intelligence), trí tuệ thể chất (physical intelligence) và trí tuệ
            tâm linh (spiritual intelligence).
          </p>
          <p>
            Chúng tôi nuôi dưỡng những giá trị cốt lõi của bạn, tạo nên một hệ
            sinh thái nội tại vụng mạnh và bền vững, giúp bạn phát triển toàn
            diện và sống một cuộc đời trọn vẹn.
          </p>
        </div>
      </section>
      <section className="bg-white rounded-xl shadow-lg p-8 mb-8">
        <div className="min-h-screen bg-gray-50 font-sans">
          <div className="container mx-auto px-4 py-12 max-w-5xl">
            <div className="text-center mb-12">
              <h1 className="text-3xl md:text-4xl font-bold text-gray-800 mb-2">
                5 Nền Tảng
              </h1>
              <p className="text-xl md:text-2xl text-gray-600">
                Tạo Nên Sự Khác Biệt Trong Mỗi Khóa Học tại InnerBright
              </p>
            </div>

            <section className="bg-white rounded-lg shadow-lg p-6 md:p-8 mb-12 flex flex-col lg:flex-row items-start lg:space-x-8">
              <div className="lg:w-1/2 w-full mb-8 lg:mb-0">
                <AccordionItem title="Khai Phá Tiềm Năng Não Bộ">
                  <p>Nội dung chi tiết về việc khai phá tiềm năng não bộ.</p>
                </AccordionItem>
                <AccordionItem title="Làm Chủ Từng Bước Thực Hành">
                  <p>Nội dung chi tiết về các bước thực hành hiệu quả.</p>
                </AccordionItem>
                <AccordionItem title="Học Qua Trải Nghiệm Sâu Sắc">
                  <p>Nội dung chi tiết về phương pháp học qua trải nghiệm.</p>
                </AccordionItem>
                <AccordionItem title="Kiến Tạo Thói Quen Thay Đổi Bền Vững">
                  <p>
                    Nội dung chi tiết về việc hình thành thói quen tích cực.
                  </p>
                </AccordionItem>
                <AccordionItem title="Đồng Hành Trên Hành Trình Chuyển Hóa">
                  <p>
                    Nội dung chi tiết về sự hỗ trợ đồng hành trong quá trình
                    chuyển hóa.
                  </p>
                </AccordionItem>
              </div>

              <div className="lg:w-1/2 w-full flex justify-center items-center">
                <img
                  src="https://placehold.co/500x350/cccccc/333333"
                  alt="InnerBright team and students"
                  width={500}
                  height={350}
                  className="rounded-lg shadow-md"
                />
              </div>
            </section>

            <section className="mb-12">
              <h2 className="text-center text-2xl md:text-3xl font-bold text-gray-800 mb-8">
                ĐỘI NGŨ CHUYÊN GIA
              </h2>
              <div className="bg-white rounded-lg shadow-lg p-6 md:p-8 flex flex-col md:flex-row items-center md:items-start space-y-6 md:space-y-0 md:space-x-8">
                <div className="md:w-1/3 flex justify-center">
                  <div className="relative w-48 h-48 md:w-64 md:h-64 rounded-full overflow-hidden shadow-lg">
                    <img
                      src="https://placehold.co/200x200/cccccc/333333"
                      alt="Chloe Quý Châu"
                      style={{ objectFit: "cover" }}
                    />
                  </div>
                </div>
                <div className="md:w-2/3 text-gray-700">
                  <h3 className="text-2xl font-bold text-gray-800 mb-2">
                    Chloe Quý Châu
                  </h3>
                  <p className="text-sm md:text-base leading-relaxed">
                    Trong quá trình học tập và huấn luyện tại Việt Nam, Chloe
                    Quý Châu là chuyên gia nguyên vật liệu, kiến trúc ABNLP
                    Coaching Division cấp phép đào tạo NLP Master Coach. Chloe
                    tập trung truyền tải nguyên bản công cụ NLP để học viên hiểu
                    rõ, đúng, đủ và ứng dụng linh hoạt vào cuộc sống.
                  </p>
                  <p className="text-sm md:text-base leading-relaxed mt-2">
                    Chloe cũng là một trong số ít người Việt đầu tiên được chứng
                    nhận đào tạo Time Line Therapy® trực tiếp từ hiệp hội, một
                    phương pháp mạnh mẽ giúp xử lý sâu sắc các cảm xúc tiêu cực
                    và niềm tin giới hạn.
                  </p>
                </div>
              </div>
            </section>

            <section className="text-center mb-12">
              <p className="text-gray-700 text-sm md:text-base leading-relaxed mb-8">
                Hành trình chuyên nghiệp của Chloe được xây dựng trên nền tảng
                kinh nghiệm khai vấn (coaching) được chứng nhận bởi hàng loạt
                các tổ chức uy tín trên thế giới, bao gồm:
              </p>
              <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
                <div className="bg-white rounded-lg shadow-md p-6 flex flex-col items-center text-center">
                  <div className="w-16 h-16 bg-blue-100 rounded-full flex items-center justify-center mb-4">
                    <span className="text-blue-600 text-3xl">💡</span>
                  </div>
                  <h4 className="font-semibold text-lg text-gray-800 mb-2">
                    Hội hợp ABNLP
                  </h4>
                  <p className="text-gray-600 text-sm">
                    Chứng nhận năng lực khai vấn bằng công cụ NLP.
                  </p>
                </div>

                <div className="bg-white rounded-lg shadow-md p-6 flex flex-col items-center text-center">
                  <div className="w-16 h-16 bg-green-100 rounded-full flex items-center justify-center mb-4">
                    <span className="text-green-600 text-3xl">📈</span>
                  </div>
                  <h4 className="font-semibold text-lg text-gray-800 mb-2">
                    Tổ chức huấn luyện doanh nghiệp ActionCoach
                  </h4>
                  <p className="text-gray-600 text-sm">
                    Chứng nhận khả năng huấn luyện và phát triển doanh nghiệp.
                  </p>
                </div>

                <div className="bg-white rounded-lg shadow-md p-6 flex flex-col items-center text-center">
                  <div className="w-16 h-16 bg-purple-100 rounded-full flex items-center justify-center mb-4">
                    <span className="text-purple-600 text-3xl">⏳</span>
                  </div>
                  <h4 className="font-semibold text-lg text-gray-800 mb-2">
                    Hội hội Time Line Therapy®
                  </h4>
                  <p className="text-gray-600 text-sm">
                    Chứng nhận năng lực trị liệu và khai vấn bằng kỹ thuật Time
                    Line Therapy.
                  </p>
                </div>

                <div className="bg-white rounded-lg shadow-md p-6 flex flex-col items-center text-center">
                  <div className="w-16 h-16 bg-yellow-100 rounded-full flex items-center justify-center mb-4">
                    <span className="text-yellow-600 text-3xl">👁️</span>
                  </div>
                  <h4 className="font-semibold text-lg text-gray-800 mb-2">
                    Tư vấn hình ảnh First Impressions Image (International
                    Education)
                  </h4>
                  <p className="text-gray-600 text-sm"></p>
                  <h4 className="font-semibold text-lg text-gray-800 mb-2">
                    Tổ chức huấn luyện doanh nghiệp ActionCoach
                  </h4>
                  <p className="text-gray-600 text-sm">
                    Chứng nhận khả năng huấn luyện và phát triển doanh nghiệp.
                  </p>
                </div>
              </div>
            </section>
          </div>
        </div>
      </section>

      <section className="bg-[#1A2A44] rounded-xl shadow-lg p-8 mb-8">
        {/* Header Section */}
        <div className="text-white text-center text-2xl font-bold">
          CHIA SẺ CỦA HỌC VIÊN VỀ INNERBRIGHT
        </div>

        {/* Main Content Section */}
        <main className="container mx-auto p-4 md:p-8">
          <div className="bg-white rounded-lg shadow-xl flex flex-col md:flex-row overflow-hidden">
            {/* Image Section */}
            <div className="md:w-1/2 flex items-center justify-center p-4">
              <img
                src="https://placehold.co/600x400/E0E0E0/333333" // Placeholder image, replace with your actual image path
                alt="InnerBright Students"
                className="w-full h-auto object-cover rounded-md shadow-inner"
              />
            </div>

            {/* Text Content Section */}
            <div className="md:w-1/2 p-6 md:p-8 flex flex-col justify-center">
              <h2 className="text-3xl font-semibold mb-4 text-gray-800">
                Tên học viên
              </h2>
              <p className="text-gray-600 italic leading-relaxed">
                "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do
                eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut
                enim ad minim veniam, quis nostrud exercitation ullamco laboris
                nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor
                in reprehenderit in voluptate velit esse cillum dolore eu fugiat
                nulla pariatur. Excepteur sint occaecat cupidatat non proident,
                sunt in culpa qui officia deserunt mollit anim id est laborum."
              </p>
            </div>
          </div>
        </main>
      </section>

    </div>
  );
}
