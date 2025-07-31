"use client";

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
  const features = [
    {
      icon: (
        <svg
          xmlns="http://www.w3.org/2000/svg"
          fill="none"
          viewBox="0 0 24 24"
          strokeWidth={1.5}
          stroke="currentColor"
          className="w-8 h-8 text-blue-600"
        >
          <path
            strokeLinecap="round"
            strokeLinejoin="round"
            d="M12 6v6h4.5m4.5 0a9 9 0 11-18 0 9 9 0 0118 0z"
          />
        </svg>
      ),
      title: "Hiệu quả nhanh chóng",
      description:
        "Hiệu quả nhanh chóng. Nhiều người trải nghiệm sự thay đổi đáng kể chỉ sau một vài buổi trị liệu.",
    },
    {
      icon: (
        <svg
          xmlns="http://www.w3.org/2000/svg"
          fill="none"
          viewBox="0 0 24 24"
          strokeWidth={1.5}
          stroke="currentColor"
          className="w-8 h-8 text-blue-600"
        >
          <path
            strokeLinecap="round"
            strokeLinejoin="round"
            d="M19.5 12h-15m0 0l6.75 6.75M4.5 12l6.75-6.75"
          />
        </svg>
      ),
      title: "Tác động sâu sắc",
      description:
        "TLT làm việc trực tiếp với gốc rễ của vấn đề, mang lại sự chuyển hóa bền vững.",
    },
    {
      icon: (
        <svg
          xmlns="http://www.w3.org/2000/svg"
          fill="none"
          viewBox="0 0 24 24"
          strokeWidth={1.5}
          stroke="currentColor"
          className="w-8 h-8 text-blue-600"
        >
          <path
            strokeLinecap="round"
            strokeLinejoin="round"
            d="M12 9v3.75m-9.303 3.376c-.866 1.5.217 3.374 1.948 3.374h14.71c1.73 0 2.813-1.874 1.948-3.374L13.949 3.378c-.866-1.5-3.032-1.5-3.898 0L2.697 16.126zM12 15.75h.007v.008H12v-.008z"
          />
        </svg>
      ),
      title: "Giải quyết các vấn đề tâm lý",
      description:
        "Hiệu quả trong giải tỏa cảm xúc tiêu cực, lo âu, trầm cảm, ám ảnh, rối loạn stress sau sang chấn, v.v.",
    },
    {
      icon: (
        <svg
          xmlns="http://www.w3.org/2000/svg"
          fill="none"
          viewBox="0 0 24 24"
          strokeWidth={1.5}
          stroke="currentColor"
          className="w-8 h-8 text-blue-600"
        >
          <path
            strokeLinecap="round"
            strokeLinejoin="round"
            d="M15.75 6a3.75 3.75 0 11-7.5 0 3.75 3.75 0 017.5 0zM4.501 20.118a7.5 7.5 0 0114.998 0A17.933 17.933 0 0112 21.75c-2.676 0-5.216-.584-7.499-1.632z"
          />
        </svg>
      ),
      title: "Nâng cao lòng tự trọng",
      description: "Giúp bạn tin tưởng vào bản thân và khả năng của mình.",
    },
    {
      icon: (
        <svg
          xmlns="http://www.w3.org/2000/svg"
          fill="none"
          viewBox="0 0 24 24"
          strokeWidth={1.5}
          stroke="currentColor"
          className="w-8 h-8 text-blue-600"
        >
          <path
            strokeLinecap="round"
            strokeLinejoin="round"
            d="M7.5 21L3 16.5m0 0L7.5 12M3 16.5h18m-12-9L21 7.5m0 0L16.5 12M21 7.5h-18"
          />
        </svg>
      ),
      title: "Cải thiện các mối quan hệ",
      description: "Tăng cường khả năng giao tiếp và thấu hiểu người khác.",
    },
    {
      icon: (
        <svg
          xmlns="http://www.w3.org/2000/svg"
          fill="none"
          viewBox="0 0 24 24"
          strokeWidth={1.5}
          stroke="currentColor"
          className="w-8 h-8 text-blue-600"
        >
          <path
            strokeLinecap="round"
            strokeLinejoin="round"
            d="M11.354 16.636A8.964 8.964 0 017.5 18c-1.559 0-3.059-.213-4.464-.614a1.05 1.05 0 01-.659-1.052 8.965 8.965 0 01.353-3.632 1.05 1.05 0 01.765-.812A12.19 12.19 0 0012 15.75c2.924 0 5.603-.92 7.77-2.478a1.05 1.05 0 01.765.812c.164 1.32.164 2.651 0 3.971a1.05 1.05 0 01-.659 1.052c-1.405.401-2.905.614-4.464.614a8.964 8.964 0 01-3.854-1.364zM12 10.5a3 3 0 100-6 3 3 0 000 6z"
          />
        </svg>
      ),
      title: "Đạt được mục tiêu",
      description: "Xác định mục tiêu và lập kế hoạch để đạt được chúng.",
    },
    {
      icon: (
        <svg
          xmlns="http://www.w3.org/2000/svg"
          fill="none"
          viewBox="0 0 24 24"
          strokeWidth={1.5}
          stroke="currentColor"
          className="w-8 h-8 text-blue-600"
        >
          <path
            strokeLinecap="round"
            strokeLinejoin="round"
            d="M15.75 17.25v-4.5m0 4.5h-4.5m4.5 0l6.09-6.09a2.25 2.25 0 000-3.182l-5.51-5.51a2.25 2.25 0 00-3.182 0L8.25 10.5m-3.75 0H7.5m-3.75 0H4.5m-3.75 0H.75"
          />
        </svg>
      ),
      title: "Tăng cường sức mạnh nội tại",
      description:
        "Giải phóng những rào cản giúp bạn kết nối với nguồn lực và tiềm năng bên trong.",
    },
  ];
  return (
    <div className="min-h-screen bg-gray-100">
      {/* <section
        id="section1"
        className="relative bg-white rounded-xl shadow-lg overflow-hidden mb-8"
      >

        <div className="relative h-80 lg:h-96">
          <img
            src="https://placehold.co/800x300/b0e0e6/000000?text=InnerBright+Team"
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
      </section> */}
      <section className="bg-white rounded-xl shadow-lg p-8 mb-8">
        <div className="text-center">
          {/* Title */}
          <h2 className="text-2xl sm:text-3xl font-semibold text-gray-800 mb-2">
            ỨNG DỤNG KỸ THUẬT
          </h2>

          {/* Time Line Therapy® */}
          <h1 className="text-4xl sm:text-6xl font-extrabold text-blue-800 mb-8">
            TIME LINE THERAPY
            <sup className="align-super text-xl sm:text-3xl">&reg;</sup>
          </h1>

          {/* Paragraph 1 */}
          <p className="text-base sm:text-lg text-gray-700 leading-relaxed mb-6 text-justify">
            Time Line Therapy® (TLT) là một phương pháp trị liệu và phát triển
            cá nhân độc đáo, được sáng lập bởi Tiến sĩ Tad James, năm 1980. Điểm
            đặc biệt của TLT nằm ở cách tiếp cận vấn đề thông qua dòng thời gian
            nội tại của mỗi người – cách thức mà chúng ta vô thức lưu trữ ký ức
            và trải nghiệm theo một trình tự thời gian trong tâm trí.
          </p>

          {/* Paragraph 2 */}
          <p className="text-base sm:text-lg text-gray-700 leading-relaxed text-justify">
            Thay vì tập trung vào việc phân tích chi tiết từng sự kiện gây ra
            vấn đề, TLT giúp bạn xác định và làm việc trực tiếp với gốc rễ của
            những cảm xúc tiêu cực, niềm tin giới hạn và các quyết định tiêu cực
            đã được hình thành trong quá khứ. Phương pháp này dựa trên tiền đề
            rằng, những trải nghiệm trong quá khứ, dù đã qua, vẫn tiếp tục ảnh
            hưởng đến suy nghĩ, cảm xúc và hành vi của chúng ta ở hiện tại thông
            qua cách chúng ta lưu trữ và phản ứng với chúng.
          </p>
        </div>
      </section>

      <section className="bg-white rounded-xl shadow-lg p-8 mb-8">
        <div className="min-h-screen bg-gray-50 font-sans">
          <div className="container mx-auto px-4 py-12 max-w-5xl">
            <div className="text-center mb-12">
              <h1 className="text-3xl md:text-4xl font-bold text-gray-800 mb-2">
                Cơ chế hoạt động chính của Time Line Therapy®
              </h1>
            </div>

            <section className="bg-white rounded-lg shadow-lg p-6 md:p-8 mb-12 flex flex-col lg:flex-row items-start lg:space-x-8">
              <div className="lg:w-1/2 w-full mb-8 lg:mb-0">
                <AccordionItem title="Xác định Dòng Thời Gian">
                  <p>Xác định Dòng Thời Gian</p>
                </AccordionItem>
                <AccordionItem title="Làm Chủ Từng Bước Thực Hành">
                  <p>Làm Chủ Từng Bước Thực Hành</p>
                </AccordionItem>
                <AccordionItem title="Học Qua Trải Nghiệm Sâu Sắc">
                  <p>Học Qua Trải Nghiệm Sâu Sắc</p>
                </AccordionItem>
                <AccordionItem title="Kiến Tạo Thói Quen Thay Đổi Bền Vững">
                  <p>Kiến Tạo Thói Quen Thay Đổi Bền Vững</p>
                </AccordionItem>
                <AccordionItem title="Đồng Hành Trên Hành Trình Chuyển Hóa">
                  <p>Đồng Hành Trên Hành Trình Chuyển Hóa</p>
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

            <div className="min-h-screen bg-gray-50 flex flex-col items-center py-10 px-4 sm:px-6 lg:px-8 font-sans">
              <div className="max-w-4xl mx-auto text-center">
                <h1 className="text-3xl sm:text-4xl font-bold text-gray-800 mb-8 rounded-lg p-2">
                  Giá trị nổi bật của Trị liệu dòng thời gian
                </h1>
              </div>

              <div className="grid grid-cols-1 gap-8 mt-10 w-full max-w-4xl">
                {features.map((feature, index) => (
                  <div
                    key={index}
                    className="flex items-start bg-white rounded-xl shadow-lg p-6 transform transition duration-300 hover:scale-105 hover:shadow-xl"
                  >
                    <div className="flex-shrink-0 p-3 bg-blue-100 rounded-full flex items-center justify-center">
                      {feature.icon}
                    </div>
                    <div className="ml-5">
                      <h2 className="text-xl font-semibold text-gray-900 mb-2">
                        {feature.title}
                      </h2>
                      <p className="text-gray-600 leading-relaxed">
                        {feature.description}
                      </p>
                    </div>
                  </div>
                ))}
              </div>
            </div>

            <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100 p-4 sm:p-6 lg:p-8 text-gray-800 flex flex-col items-center">
              {/* Main Title */}
              <h1 className="text-3xl sm:text-4xl lg:text-5xl font-extrabold text-indigo-800 mb-8 text-center leading-tight">
                CÁC KỸ THUẬT TRỊ LIỆU DÒNG THỜI GIAN
              </h1>

              {/* Techniques Section */}
              <div className="w-full max-w-6xl bg-white shadow-xl rounded-2xl p-6 sm:p-8 lg:p-10 mb-12 border border-indigo-200">
                <h2 className="text-2xl sm:text-3xl font-bold text-indigo-700 mb-6 text-center">
                  CÁC KỸ THUẬT CỦA{" "}
                  <span className="text-purple-600">Time Line Therapy®</span> -
                  Trị Liệu Dòng Thời Gian
                </h2>

                <div className="grid grid-cols-1 md:grid-cols-3 gap-6 sm:gap-8">
                  {/* Past Column */}
                  <div className="bg-gradient-to-br from-red-50 to-red-100 p-5 rounded-xl shadow-md border border-red-200">
                    <h3 className="text-xl sm:text-2xl font-semibold text-red-700 mb-4 pb-2 border-b-2 border-red-300">
                      <span role="img" aria-label="past" className="mr-2">
                        🕰️
                      </span>{" "}
                      Quá khứ
                    </h3>
                    <ul className="list-disc list-inside space-y-2 text-gray-700">
                      <li>Giải tỏa các đè nén từ ký ức cũ</li>
                      <li>Cảm xúc tiêu cực</li>
                      <li>Niềm tin giới hạn</li>
                      <li>Trải nghiệm bất lợi gây sang chấn tâm lý</li>
                    </ul>
                  </div>

                  {/* Present Column */}
                  <div className="bg-gradient-to-br from-green-50 to-green-100 p-5 rounded-xl shadow-md border border-green-200">
                    <h3 className="text-xl sm:text-2xl font-semibold text-green-700 mb-4 pb-2 border-b-2 border-green-300">
                      <span role="img" aria-label="present" className="mr-2">
                        ⏳
                      </span>{" "}
                      Hiện tại
                    </h3>
                    <ul className="list-disc list-inside space-y-2 text-gray-700">
                      <li>Cài đặt nguồn lực</li>
                      <li>Cơn đau thể lý mãn tính</li>
                      <li>Mẫu thuần nội tâm</li>
                      <li>Kết nối cảm xúc</li>
                      <li>Tháo gỡ ám ảnh</li>
                      <li>Tháo gỡ mẫu thuần nội tâm</li>
                    </ul>
                  </div>

                  {/* Future Column */}
                  <div className="bg-gradient-to-br from-blue-50 to-blue-100 p-5 rounded-xl shadow-md border border-blue-200">
                    <h3 className="text-xl sm:text-2xl font-semibold text-blue-700 mb-4 pb-2 border-b-2 border-blue-300">
                      <span role="img" aria-label="future" className="mr-2">
                        🚀
                      </span>{" "}
                      Tương lai
                    </h3>
                    <ul className="list-disc list-inside space-y-2 text-gray-700">
                      <li>Giải tỏa lo âu</li>
                      <li>Cài đặt mục tiêu</li>
                    </ul>
                  </div>
                </div>
              </div>

              {/* Time Line Therapy Description */}
              <div className="w-full max-w-6xl bg-white shadow-xl rounded-2xl p-6 sm:p-8 lg:p-10 mb-12 border border-purple-200">
                <p className="text-base sm:text-lg text-gray-700 leading-relaxed text-center">
                  <span className="font-bold text-purple-600">
                    Time Line Therapy®
                  </span>{" "}
                  là một hình thành hình thành thâm nhập map các nỗi sâu xa của
                  tiềm thức, nơi lưu những sự thật và rào cản vô hình được định
                  hình trong suốt quá trình sống. Bằng cách tiếp cận và giải
                  phóng những tầng sâu này, phương pháp mang đến sự chuyển hóa
                  tận gốc, kho không đóng chảy sức mạnh nội tại vốn có của bạn.
                </p>
              </div>

              {/* How it's done section */}
              <div className="w-full max-w-6xl bg-white shadow-xl rounded-2xl p-6 sm:p-8 lg:p-10 border border-teal-200">
                <h2 className="text-2xl sm:text-3xl font-bold text-teal-700 mb-6 text-center">
                  CÁCH THỨC CŨNG QUAN TRỌNG NHƯ NỘI DUNG
                </h2>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-6 sm:gap-8">
                  <p className="text-base sm:text-lg text-gray-700 leading-relaxed bg-teal-50 p-4 rounded-lg border border-teal-100">
                    Sự chia sẻ của giảng viên không phải là yếu tố chính trong
                    sự thành công của người học; đó là chất lượng tổ chức thực
                    hành và giám sát bởi những người có chuyên môn vĩnh viễn
                    nhiệm trong lĩnh vực của cùng mang lại cho học sinh năng lực
                    và tự tin.
                  </p>
                  <p className="text-base sm:text-lg text-gray-700 leading-relaxed bg-teal-50 p-4 rounded-lg border border-teal-100">
                    Chỉ có 30% thời gian trên lớp là trên bài giảng, thời gian
                    còn lại - học viên thực hành cùng với sự hướng dẫn và đồng
                    hành của các Coaching Assistants tại Innerlife. Đây là bí
                    quyết của chương trình trong việc đào tạo các học viên NLP
                    rất có năng lực.
                  </p>
                </div>
              </div>
            </div>
          </div>
         <div className="w-full flex justify-center items-center">
              <img
                src="https://placehold.co/1000x500/cccccc/333333"
                alt="InnerBright team and students"
                className="rounded-lg shadow-md"
              />
            </div>
        </div>
      </section>
    </div>
  );
}
