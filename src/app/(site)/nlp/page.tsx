"use client";
import Section from "@/components/Section";
import { useState } from "react";
import {
  PageTransition,
  ScrollAnimation,
  StaggerContainer,
  StaggerItem,
  FadeIn,
  ScaleIn,
  SlideIn,
} from "@/components/animations/PageAnimations";
export default function NLPPage() {
  const ListImage = [
    {
      id: 1,
      src: "/images/NLP/NLP_Section 1.png",
      alt: "NLP Background",
    },
    {
      id: 2,
      src: "/images/NLP/NLP_Section 3.1.png",
      alt: "NLP Background",
    },
    {
      id: 3,
      src: "/images/NLP/NLP_Section 3.2.png",
      alt: "NLP Background",
    },
    {
      id: 4,
      src: "/images/NLP/NLP_Section 3.3.png",
      alt: "NLP Background",
    },
    {
      id: 5,
      src: "/images/NLP/NLP_Section 3.4.png",
      alt: "NLP Background",
    },
    {
      id: 6,
      src: "/images/NLP/NLP_Section 6.png",
      alt: "NLP Background",
    },
    {
      id: 7,
      src: "/images/NLP/NLP_Section 7.1.png",
      alt: "NLP Background",
    },
    {
      id: 8,
      src: "/images/NLP/NLP_Section 7.2.png",
      alt: "NLP Background",
    },
    {
      id: 9,
      src: "/images/NLP/NLP_Section 7.3.png",
      alt: "NLP Background",
    },
    {
      id: 10,
      src: "/images/NLP/NLP_Section 7.4.png",
      alt: "NLP Background",
    },
    {
      id: 11,
      src: "/images/NLP/NLP_Section 8.png",
      alt: "NLP Background",
    },
    {
      id: 12,
      src: "/images/NLP/NLP_Section 9.png",
      alt: "NLP Background",
    },
    {
      id: 13,
      src: "/images/NLP/NLP_Section 11.1.png",
      alt: "NLP Background",
    },
    {
      id: 14,
      src: "/images/NLP/NLP_Section 11.2.png",
      alt: "NLP Background",
    },
    {
      id: 15,
      src: "/images/NLP/NLP_Section 11.3.png",
      alt: "NLP Background",
    },
    {
      id: 16,
      src: "/images/NLP/NLP_Section 12.png",
      alt: "NLP Background",
    },
    {
      id: 17,
      src: "/images/NLP/NLP_Section 13.1.png",
      alt: "NLP Background",
    },
    {
      id: 18,
      src: "/images/NLP/NLP_Section 13.2.png",
      alt: "NLP Background",
    },
    {
      id: 19,
      src: "/images/NLP/NLP_Section 13.3.png",
      alt: "NLP Background",
    },
    {
      id: 20,
      src: "/images/NLP/NLP_Section 14.png",
      alt: "NLP Background",
    },
    {
      id: 21,
      src: "/images/NLP/NLP_Section 15.png",
      alt: "NLP Background",
    },
  ];
  return (
    <PageTransition>
      <div className="min-h-screen bg-gray-100 font-sans antialiased">
        <FadeIn>
          <section
            id="section2"
            className="relative bg-white rounded-xl shadow-lg overflow-hidden mb-8"
          >
            <div className="relative h-80 lg:h-96">
              <img
                src={ListImage[0].src}
                alt={ListImage[0].alt}
                className="w-full h-full object-cover object-center"
              />
              <div className="absolute inset-0 bg-gradient-to-r from-black/60 to-transparent" />

              <div className="absolute inset-0 flex items-center">
                <div className="container mx-auto px-8 lg:px-12">
                  <div className="max-w-2xl">
                    <h1 className="text-3xl lg:text-5xl font-bold text-white mb-6 leading-tight">
                      NLP
                    </h1>
                    <p className="text-lg lg:text-xl text-white/90 leading-relaxed">
                      LẬP TRÌNH NGÔN NGỮ TƯ DUY
                    </p>
                  </div>
                </div>
              </div>
            </div>
          </section>

          <section className="container mx-auto px-4 py-8 md:py-12">
            <div className="bg-white p-6 md:p-10 rounded-lg shadow-xl mb-10">
              <h2 className="text-3xl md:text-4xl font-bold text-center text-gray-800 mb-6">
                CHÌA KHÓA MỞ RA CÁNH CỬA CUỘC SỐNG VƯỢT TRỘI
              </h2>
              <p className="text-lg md:text-xl text-gray-700 leading-relaxed mb-4">
                <span className="font-semibold">
                  Lập Trình Ngôn Ngữ Tư Duy NLP
                </span>{" "}
                (Neuro Linguistic Programming) là chìa khóa giúp khai phá sức
                mạnh của bản thân. Các nhà khoa học đã công nhận tầm quan trọng
                của phương pháp NLP. Nếu hiểu rõ về NLP, bạn sẽ có cơ hội phát
                triển bản thân lên tầm cao mới. Vậy phương pháp NLP là gì?
              </p>
              <p className="text-lg md:text-xl text-gray-700 leading-relaxed">
                NLP được khởi nguồn tại Mỹ, bởi John Grinder (nhà ngôn ngữ học)
                và Richard Bandler (nhà toán học và liệu pháp tâm lý Gestalt)
                với mục đích tạo ra các mô hình học tập rõ ràng về sự xuất sắc
                của con người.
              </p>
            </div>

            <div className=" p-6 md:p-10 rounded-lg shadow-xl bg-white mb-10">
              <h2 className="text-3xl md:text-4xl font-bold text-center mb-8">
                3 CÂU HỎI MUỐN THUÊ:
              </h2>
              <p className="text-xl md:text-2xl text-center mb-8">
                Mỗi ngày, chúng ta đều trăn trở về những câu hỏi sâu sắc về cuộc
                sống:
              </p>
              <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
                <div className="relative p-6 rounded-lg shadow-md hover:shadow-xl transition-shadow duration-300 overflow-hidden">
                  {/* <div
                    className="absolute inset-0 bg-cover bg-center w-full h-full"
                    style={{
                      backgroundImage: `url('${ListImage[1].src}')`,
                    }}
                  /> */}
                  <img
                    src={ListImage[1].src}
                    className="absolute inset-0 bg-cover bg-center"
                  />
                  <div className="absolute inset-0" />
                  <div className="relative flex flex-col items-center text-center">
                    <div className="w-16 h-16 md:w-20 md:h-20 text-blue-100 rounded-full flex items-center justify-center text-4xl md:text-5xl font-extrabold mb-4">
                      1
                    </div>
                    <p className="text-lg md:text-xl font-medium text-white">
                      Tại sao tôi trở thành con người mà tôi đang là?
                    </p>
                  </div>
                </div>

                <div className="relative p-6 rounded-lg shadow-md hover:shadow-xl transition-shadow duration-300 overflow-hidden">
                  <img
                    src={ListImage[1].src}
                    className="absolute inset-0 bg-cover bg-center"
                  />
                  <div className="absolute inset-0" />
                  <div className="relative flex flex-col items-center text-center">
                    <div className="w-16 h-16 md:w-20 md:h-20 text-blue-100 rounded-full flex items-center justify-center text-4xl md:text-5xl font-extrabold mb-4">
                      2
                    </div>
                    <p className="text-lg md:text-xl font-medium text-white">
                      Tôi thực sự mong muốn điều gì trong cuộc đời?
                    </p>
                  </div>
                </div>

                <div className="relative p-6 rounded-lg shadow-md hover:shadow-xl transition-shadow duration-300 overflow-hidden">
                  <img
                    src={ListImage[1].src}
                    className="absolute inset-0 bg-cover bg-center"
                  />
                  <div className="absolute inset-0" />
                  <div className="relative flex flex-col items-center text-center">
                    <div className="w-16 h-16 md:w-20 md:h-20 text-blue-100 rounded-full flex items-center justify-center text-4xl md:text-5xl font-extrabold mb-4">
                      3
                    </div>
                    <p className="text-lg md:text-xl font-medium text-white">
                      Làm thế nào để tôi vượt qua những rào cản và đạt được điều
                      mình mong muốn?
                    </p>
                  </div>
                </div>
              </div>
            </div>

            <div className="bg-white p-6 md:p-10 rounded-lg shadow-xl mb-10">
              <p className="text-lg md:text-xl text-gray-700 leading-relaxed mb-6">
                Bạn chính là tác giả của cuộc đời mình, là đạo diễn của vở kịch
                mang tên "Cuộc sống" mà bạn đóng vai chính. Mỗi người sinh ra
                đều sở hữu tiềm năng to lớn bên trong để kiến tạo cuộc sống như
                mong muốn. Tuy nhiên, thay vì nắm chặt tay chèo dẫn dắt con
                thuyền cuộc đời mình đến mục tiêu, nhiều người lại mặc một
                phương hướng vô không biết tiếp tục bước đi như thế nào. Những
                nỗi lo âu đã vô tình đặt cản đường xuất hiện, khiến nhiều người
                lựa chọn dừng lại.
              </p>
              <h2 className="text-3xl md:text-4xl font-bold text-center text-blue-600 mb-6">
                Nhưng bạn sẽ không nằm trong số đó!
              </h2>
              <h3 className="text-2xl md:text-3xl font-semibold text-center text-gray-800 mb-4">
                NLP - Nguồn lực mạnh mẽ giúp bạn làm chủ cuộc đời
              </h3>
              <p className="text-lg md:text-xl text-gray-700 leading-relaxed">
                Một trong những nguồn lực tuyệt vời nhất mà mỗi người sở hữu
                chính là khả năng học cách làm chủ tâm trí và hiện diện - sống
                trọn vẹn với thực tại. Cách chúng ta phản ứng với cuộc sống,
                những suy nghĩ, cảm xúc, hành động, niềm tin và giá trị theo
                đuổi đóng vai trò vô cùng quan trọng, tác động trực tiếp đến mọi
                kết quả trong cuộc đời. Và NLP chính là công cụ giúp bạn làm chủ
                những yếu tố then chốt này.
              </p>
            </div>
          </section>
          <section className="py-16 px-4 sm:px-6 lg:px-8">
            <div className="max-w-4xl mx-auto py-8">
              <div className="text-center text-4xl sm:text-5xl font-extrabold text-blue-700 mb-4 leading-tight">
                NLP là gì?
              </div>
              <p className="text-lg sm:text-xl text-gray-700 leading-relaxed">
                Một cách đơn giản, thuật ngữ "Lập trình ngôn ngữ tư duy" đề cập
                đến những chương trình chạy ngầm trong tiềm thức, dẫn dắt hành
                vi và tạo ra kết quả trong cuộc sống của chúng ta.
              </p>
            </div>

            <div className="max-w-6xl mx-auto grid grid-cols-1 md:grid-cols-3 gap-8">
              <div className="relative bg-white p-6 rounded-lg shadow-md">
                <img
                  src={ListImage[1].src}
                  className="absolute inset-0 bg-cover bg-center w-full h-full rounded-lg"
                />
                <h2 className="relative text-2xl font-bold text-white mb-3">
                  Neuro - Tư duy
                </h2>
                <p className="relative text-white leading-relaxed">
                  Hệ thống nơ-ron bộ và mạng lưới thần kinh sinh tồn. Trong con
                  người có trung bình dao động từ 80 đến 100 tỷ nơ-ron và 100 tỷ
                  tế bào nơ-ron thần kinh, hoạt động chính của nó là giúp chúng
                  ta có thể tiếp nhận, xử lý thông tin. Sau đó bộ não sẽ tạo ra
                  các thiết lập và hệ thống phản hồi làm việc một cách hiệu quả
                  hơn trong cuộc sống.
                </p>
              </div>
              <div className="relative bg-white p-6 rounded-lg shadow-md">
                <img
                  src={ListImage[1].src}
                  className="absolute inset-0 bg-cover bg-center w-full h-full rounded-lg"
                />
                <h2 className="relative text-2xl font-bold text-white mb-3">
                  Linguistic - Ngôn ngữ
                </h2>
                <p className="relative text-white leading-relaxed">
                  Cách chúng ta sử dụng ngôn từ không chỉ đơn thuần diễn đạt ý
                  định của chúng ta mà còn thể hiện niềm tin và thái độ của mỗi
                  người. Một lời nói có thể mang năng lượng tích cực, có thể
                  mang năng lượng tiêu cực. Một lời nói có thể mang năng lượng
                  tiêu cực, một lời nói có thể mang năng lượng tiêu cực. Một lời
                  nói có thể mang năng lượng tiêu cực. Một lời nói có thể mang
                  năng lượng tiêu cực. Một lời nói có thể mang năng lượng tiêu
                  cực. Một lời nói có thể mang năng lượng tiêu cực. Một lời nói
                  có thể mang năng lượng tiêu cực.
                </p>
              </div>
              <div className="relative bg-white p-6 rounded-lg shadow-md">
                <img
                  src={ListImage[1].src}
                  className="absolute inset-0 bg-cover bg-center w-full h-full rounded-lg"
                />
                <h2 className="relative text-2xl font-bold text-white mb-3">
                  Programming - Lập trình
                </h2>
                <p className="relative text-white leading-relaxed">
                  Tương tự như hệ điều hành máy tính, lập trình ngôn ngữ tư duy
                  là dòng hóa các phản ứng thông tin và hành vi. Nó là một tập
                  hợp các nguyên tắc giúp điều chỉnh các kiểu tiết niệu và hành
                  vi không mong muốn, đồng thời hay mới lạ. Có thể hóa số chương
                  trình tư duy và hành vi để đạt được hiệu quả hơn.
                </p>
              </div>
            </div>
          </section>

          <section className="relative py-20 px-4 sm:px-6 lg:px-8 bg-cover bg-center rounded-lg mx-4 sm:mx-6 lg:mx-8 shadow-lg">
            <img
              src={ListImage[5]?.src}
              className="absolute inset-0 bg-cover bg-center w-full h-full rounded-lg bg-black/60"
            />
            <div className="relative max-w-4xl bg-gray-50/50 rounded-lg p-6 mx-auto text-center">
              <h2 className="text-3xl sm:text-4xl font-bold leading-tight text-[#011d56]">
                NLP - Tái cấu trúc hệ điều hành cuộc đời bạn
              </h2>
              <p className="leading-relaxed text-black p-2">
                NLP dựa trên cơ sở bộ não của chúng ta có thể được tái cấu trúc
                để biến chúng ta thành những thực thể mới. Hay nói cách khác, bộ
                não là hệ điều hành của cuộc sống. NLP giúp thay đổi cách chúng
                ta nghĩ về bản thân, về người khác, về thế giới và thay thế bằng
                những điều hữu ích cho cuộc sống. NLP giúp tái cấu trúc những
                chương trình chạy ngầm bên trong, từ đó thay đổi tư duy và hành
                vi để đạt được hiệu quả.
              </p>
            </div>
          </section>

          <section className="py-16 px-4 sm:px-6 lg:px-8">
            <div className="max-w-6xl mx-auto text-center mb-12">
              <h2 className="text-3xl sm:text-4xl font-bold text-blue-700 mb-3">
                NLP - Hộp công cụ cuộc sống đa năng
              </h2>
              <p className="text-xl sm:text-2xl text-gray-700">
                NLP là một tập hợp gồm nhiều công cụ và kỹ thuật hữu ích trang
                bị cho bạn khả năng
              </p>
            </div>

            <div className="relative max-w-6xl mx-auto grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-2 gap-8 p-16">
              <div className="relative bg-white rounded-lg shadow-md overflow-hidden">
                <img
                  src={ListImage[6].src}
                  className="w-full object-cover inset-0 bg-gradient-to-t from-black/60 to-transparent"
                />
                <div className="absolute inset-0 bg-gradient-to-t from-black/60 to-transparent" />
                <div className="absolute top-0 p-6 text-center">
                  <h2 className="text-2xl font-bold text-white mb-3">
                  Hiểu rõ bản thân
                  </h2>
                  <p className="text-white leading-relaxed">
                  Hiểu rõ hơn về giá trị, mục tiêu, niềm tin và khả năng của
                  bản thân để phát triển tiềm năng cá nhân.
                  </p>
                </div>
              </div>

              <div className="relative bg-white rounded-lg shadow-md overflow-hidden">
                <img
                  src={ListImage[7].src}
                  className="w-full object-cover inset-0 bg-gradient-to-t from-black/60 to-transparent"
                />
                <div className="absolute inset-0 bg-gradient-to-t from-black/60 to-transparent" />
                <div className="absolute top-0 p-6 text-center">
                  <h2 className="text-2xl font-bold text-white mb-3">
                    Hiểu rõ người khác
                  </h2>
                  <p className="text-white leading-relaxed">
                    Nâng cao kỹ năng giao tiếp, tạo ra mối quan hệ tốt đẹp và
                    ảnh hưởng tích cực đến những người xung quanh.
                  </p>
                </div>
              </div>

              <div className="relative bg-white rounded-lg shadow-md overflow-hidden">
                <img
                  src={ListImage[8].src}
                  className="w-full object-cover inset-0 bg-gradient-to-t from-black/60 to-transparent"
                />
                <div className="absolute inset-0 bg-gradient-to-t from-black/60 to-transparent" />
                <div className="absolute top-0 p-6 text-center">
                  <h2 className="text-2xl font-bold text-white mb-3">
                    Làm chủ cuộc sống
                  </h2>
                  <p className="text-white leading-relaxed">
                    Phát triển khả năng tự quản lý cảm xúc, giải quyết vấn đề và
                    đạt được mục tiêu cuộc sống.
                  </p>
                </div>
              </div>
              <div className="relative bg-white rounded-lg shadow-md overflow-hidden">
                <img
                  src={ListImage[9].src}
                  className="w-full object-cover inset-0 bg-gradient-to-t from-black/60 to-transparent"
                />
                <div className="absolute inset-0 bg-gradient-to-t from-black/60 to-transparent" />
                <div className="absolute top-0 p-6 text-center">
                  <h2 className="text-2xl font-bold text-white mb-3">
                    Làm chủ cuộc sống
                  </h2>
                  <p className="text-white leading-relaxed">
                    Phát triển khả năng tự quản lý cảm xúc, giải quyết vấn đề và
                    đạt được mục tiêu cuộc sống.
                  </p>
                </div>
              </div>
            </div>
          </section>

          <section className="max-w-6xl mx-auto grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-2 gap-8">
            <div className="relative p-8 max-w-4xl mx-auto text-center justify-center">
              <h2 className="text-3xl text-[#011d56] sm:text-4xl font-bold mb-4 leading-tight whitespace-nowrap">
                Tham gia chương trình đào tạo NLP
              </h2>
              <p className="text-justify text-lg sm:text-xl leading-relaxed">
                Bạn đang tham gia vào hành trình thấu hiểu bản thân, tìm thấy
                mục tiêu cuộc sống và làm chủ chính mình. Đây cũng là hành trình
                giúp Bạn chữa lành những tổn thương bên trong từ gốc rễ ở quá
                khứ, từ đó giúp kết nối mối quan hệ với bản thân, loại bỏ rào
                cản hoài nghi năng lực cá nhân, cải thiện khả năng tương tác
                thấu cảm với người khác; cung cấp cho bạn một loạt các chiến
                lược gia tăng hiệu suất cá nhân lâu dài, và một hành trình phát
                triển bản thân đúng đắn và toàn diện. 
                <br/>
                <br/>
                Đến nay, NLP đã phát triển
                các công cụ và kỹ năng rất mạnh mẽ và tạo thay đổi trong nhiều
                lĩnh vực chuyên môn bao gồm: tư vấn, tâm lý trị liệu, giáo dục,
                sức khỏe, sáng tạo, luật, quản lý, bán hàng, lãnh đạo và nuôi
                dạy con cái.
              </p>
            </div>
            <div className="p-16">
              <img
                src={ListImage[10].src}
                alt="NLP Background"
                className="object-cover object-center rounded-4xl"
              />
            </div>
          </section>
          <Section className="!bg-[#011d56] !p-8">
            <h1 className="text-center text-3xl md:text-4xl font-bold text-white mb-4">
              LƯỢC SỬ NLP
            </h1>
            <div className="relative h-80 lg:h-[500px]">
              <img
                src={ListImage[11].src}
                alt="Laptop showing NLP concepts"
                className="mx-auto w-[800px] h-[500px] object-cover object-center rounded-lg"
              />
            </div>
          </Section>

          <Section>
            <div className="w-full bg-white shadow-lg rounded-xl p-6 sm:p-8 lg:p-10">
              {/* Tiêu đề chính của trang */}
              <h1 className="text-4xl sm:text-5xl lg:text-6xl font-extrabold text-center text-gray-900 mb-8 leading-tight">
                Khởi nguồn từ đam mê
              </h1>

              {/* Đoạn giới thiệu */}
              <p className="text-base sm:text-lg lg:text-xl text-gray-700 text-center mb-12 max-w-3xl mx-auto leading-relaxed">
                Câu chuyện về NLP - Lập Trình Ngôn Ngữ Tư Duy bắt đầu từ niềm
                đam mê mãnh liệt của hai nhà nghiên cứu tiên phong: Richard
                Bandler và John Grinder. Họ trăn trở về một câu hỏi mang tính
                then chốt: "Yếu tố nào tạo nên sự khác biệt giữa một cá nhân
                bình thường và một cá nhân xuất sắc trong cùng một lĩnh vực?".
                Khao khát tìm kiếm câu trả lời đã thôi thúc họ dấn thân vào hành
                trình nghiên cứu đầy say mê về cách con người sử dụng ngôn ngữ
                để phản ánh và ảnh hưởng đến tư duy của chính họ.
              </p>

              {/* Tiêu đề phụ cho phần các nhà tiên phong */}
              <h2 className="text-3xl sm:text-4xl lg:text-5xl font-bold text-center text-gray-800 mb-10 mt-16 leading-tight">
                NHỮNG NHÀ TIÊN PHONG TRUYỀN CẢM HỨNG
              </h2>

              {/* Phần chứa các thẻ thông tin về các nhà tiên phong */}
              <div className="grid grid-cols-1 md:grid-cols-3 gap-8 sm:gap-10 lg:gap-12">
                {/* Thẻ thông tin về Milton Erickson */}
                <div className="bg-white border border-gray-200 rounded-lg shadow-md p-6 flex flex-col items-center text-center transition-transform transform hover:scale-105 duration-300">
                  {/* Hình ảnh của Milton Erickson */}
                  <img
                    src={ListImage[12].src}
                    alt="Hình ảnh Milton Erickson"
                    className="w-32 h-32 sm:w-36 sm:h-36 rounded-full object-cover mb-4 border-4 border-blue-500 shadow-md"
                  />
                  <h3 className="text-xl sm:text-2xl font-semibold text-gray-900 mb-2">
                    Milton Erickson (1901-80)
                  </h3>
                  <p className="text-sm sm:text-base text-gray-600 leading-relaxed">
                    là một bác sĩ tâm thần, nhà trị liệu thôi miên rất thành
                    công. NLP dựa trên cách mà Milton Erickson sử dụng ngôn ngữ
                    thôi miên trị liệu để tạo nên các mẫu ngôn ngữ mang tên Mô
                    hình Milton. Bất kể bạn đang ở bất cảnh nào, vai trò của bạn
                    là gì thì những mẫu ngôn ngữ này sẽ giúp cho bạn có thể gia
                    tăng khả năng giao tiếp với tầng tiềm thức của người nghe,
                    thúc đẩy động lực, gây sự ảnh hưởng và tạo ra sự thay đổi
                    lâu dài mang tính tích cực.
                  </p>
                </div>

                {/* Thẻ thông tin về Fritz Perls */}
                <div className="bg-white border border-gray-200 rounded-lg shadow-md p-6 flex flex-col items-center text-center transition-transform transform hover:scale-105 duration-300">
                  {/* Hình ảnh của Fritz Perls */}
                  <img
                    src={ListImage[13].src}
                    alt="Hình ảnh Fritz Perls"
                    className="w-32 h-32 sm:w-36 sm:h-36 rounded-full object-cover mb-4 border-4 border-blue-500 shadow-md"
                  />
                  <h3 className="text-xl sm:text-2xl font-semibold text-gray-900 mb-2">
                    Fritz Perls (1893-70)
                  </h3>
                  <p className="text-sm sm:text-base text-gray-600 leading-relaxed">
                    là một bác sĩ phẫu thuật thần kinh người Đức và nhà phân tâm
                    học gốc Do Thái. Ông cũng là người người sáng lập ra liệu
                    pháp Gestalt. Ông được đóng góp phát triển thành một công cụ
                    trị liệu để phân tích tâm lý.
                  </p>
                </div>

                {/* Thẻ thông tin về Virginia Satir */}
                <div className="bg-white border border-gray-200 rounded-lg shadow-md p-6 flex flex-col items-center text-center transition-transform transform hover:scale-105 duration-300">
                  {/* Hình ảnh của Virginia Satir */}
                  <img
                    src={ListImage[14].src}
                    alt="Hình ảnh Virginia Satir"
                    className="w-32 h-32 sm:w-36 sm:h-36 rounded-full object-cover mb-4 border-4 border-blue-500 shadow-md"
                  />
                  <h3 className="text-xl sm:text-2xl font-semibold text-gray-900 mb-2">
                    Virginia Satir (1916-88)
                  </h3>
                  <p className="text-sm sm:text-base text-gray-600 leading-relaxed">
                    được xem là bậc thầy về Liệu pháp gia đình. Virginia Satir
                    tin rằng vai trò mà chúng ta đảm nhận trong gia đình, nơi
                    chúng ta tồn tại là hạt giống có phản ánh hướng rất lớn đến
                    quá trình trưởng thành. Bà tin rằng yếu tố gia đình đã góp
                    phần tạo nên tính cách của mỗi con người. Bandler và Grinder
                    đã sử dụng Mô hình trị liệu của Satir để tạo ra Mô hình Meta
                    với các mẫu câu hỏi giúp tạo ra sự rõ ràng và sáng tỏ trong
                    các vấn đề.
                  </p>
                </div>
              </div>
            </div>
          </Section>
          <Section>
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
                      <p>
                        Nội dung chi tiết về việc khai phá tiềm năng não bộ.
                      </p>
                    </AccordionItem>
                    <AccordionItem title="Làm Chủ Từng Bước Thực Hành">
                      <p>Nội dung chi tiết về các bước thực hành hiệu quả.</p>
                    </AccordionItem>
                    <AccordionItem title="Học Qua Trải Nghiệm Sâu Sắc">
                      <p>
                        Nội dung chi tiết về phương pháp học qua trải nghiệm.
                      </p>
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
                      src={ListImage[15].src}
                      alt="InnerBright team and students"
                      width={500}
                      height={350}
                      className="rounded-lg shadow-md"
                    />
                  </div>
                </section>
              </div>
            </div>
          </Section>
          <Section>
            <div className="w-full bg-white shadow-lg rounded-xl p-6 sm:p-8 lg:p-10">
              {/* Tiêu đề chính của trang */}
              <h1 className="text-4xl sm:text-5xl lg:text-6xl font-extrabold text-center text-gray-900 mb-8 leading-tight">
                Khởi nguồn từ đam mê
              </h1>

              {/* Đoạn giới thiệu */}
              <p className="text-base sm:text-lg lg:text-xl text-gray-700 text-center mb-12 max-w-3xl mx-auto leading-relaxed">
                Câu chuyện về NLP - Lập Trình Ngôn Ngữ Tư Duy bắt đầu từ niềm
                đam mê mãnh liệt của hai nhà nghiên cứu tiên phong: Richard
                Bandler và John Grinder. Họ trăn trở về một câu hỏi mang tính
                then chốt: "Yếu tố nào tạo nên sự khác biệt giữa một cá nhân
                bình thường và một cá nhân xuất sắc trong cùng một lĩnh vực?".
                Khao khát tìm kiếm câu trả lời đã thôi thúc họ dấn thân vào hành
                trình nghiên cứu đầy say mê về cách con người sử dụng ngôn ngữ
                để phản ánh và ảnh hưởng đến tư duy của chính họ.
              </p>

              {/* Tiêu đề phụ cho phần các nhà tiên phong */}
              <h2 className="text-3xl sm:text-4xl lg:text-5xl font-bold text-center text-gray-800 mb-10 mt-16 leading-tight">
                NHỮNG NHÀ TIÊN PHONG TRUYỀN CẢM HỨNG
              </h2>

              {/* Phần chứa các thẻ thông tin về các nhà tiên phong */}
              <div className="grid grid-cols-1 md:grid-cols-3 gap-8 sm:gap-10 lg:gap-12">
                {/* Thẻ thông tin về Milton Erickson */}
                <div className="bg-white border border-gray-200 rounded-lg shadow-md p-6 flex flex-col items-center text-center transition-transform transform hover:scale-105 duration-300">
                  {/* Hình ảnh của Milton Erickson */}
                  <img
                    src={ListImage[16].src}
                    alt="Hình ảnh Milton Erickson"
                    className="w-32 h-32 sm:w-36 sm:h-36 rounded-full object-cover mb-4 border-4 border-blue-500 shadow-md"
                  />
                  <h3 className="text-xl sm:text-2xl font-semibold text-gray-900 mb-2">
                    Milton Erickson (1901-80)
                  </h3>
                  <p className="text-sm sm:text-base text-gray-600 leading-relaxed">
                    là một bác sĩ tâm thần, nhà trị liệu thôi miên rất thành
                    công. NLP dựa trên cách mà Milton Erickson sử dụng ngôn ngữ
                    thôi miên trị liệu để tạo nên các mẫu ngôn ngữ mang tên Mô
                    hình Milton. Bất kể bạn đang ở bất cảnh nào, vai trò của bạn
                    là gì thì những mẫu ngôn ngữ này sẽ giúp cho bạn có thể gia
                    tăng khả năng giao tiếp với tầng tiềm thức của người nghe,
                    thúc đẩy động lực, gây sự ảnh hưởng và tạo ra sự thay đổi
                    lâu dài mang tính tích cực.
                  </p>
                </div>

                {/* Thẻ thông tin về Fritz Perls */}
                <div className="bg-white border border-gray-200 rounded-lg shadow-md p-6 flex flex-col items-center text-center transition-transform transform hover:scale-105 duration-300">
                  {/* Hình ảnh của Fritz Perls */}
                  <img
                    src={ListImage[17].src}
                    alt="Hình ảnh Fritz Perls"
                    className="w-32 h-32 sm:w-36 sm:h-36 rounded-full object-cover mb-4 border-4 border-blue-500 shadow-md"
                  />
                  <h3 className="text-xl sm:text-2xl font-semibold text-gray-900 mb-2">
                    Fritz Perls (1893-70)
                  </h3>
                  <p className="text-sm sm:text-base text-gray-600 leading-relaxed">
                    là một bác sĩ phẫu thuật thần kinh người Đức và nhà phân tâm
                    học gốc Do Thái. Ông cũng là người người sáng lập ra liệu
                    pháp Gestalt. Ông được đóng góp phát triển thành một công cụ
                    trị liệu để phân tích tâm lý.
                  </p>
                </div>

                {/* Thẻ thông tin về Virginia Satir */}
                <div className="bg-white border border-gray-200 rounded-lg shadow-md p-6 flex flex-col items-center text-center transition-transform transform hover:scale-105 duration-300">
                  {/* Hình ảnh của Virginia Satir */}
                  <img
                    src={ListImage[18].src}
                    alt="Hình ảnh Virginia Satir"
                    className="w-32 h-32 sm:w-36 sm:h-36 rounded-full object-cover mb-4 border-4 border-blue-500 shadow-md"
                  />
                  <h3 className="text-xl sm:text-2xl font-semibold text-gray-900 mb-2">
                    Virginia Satir (1916-88)
                  </h3>
                  <p className="text-sm sm:text-base text-gray-600 leading-relaxed">
                    được xem là bậc thầy về Liệu pháp gia đình. Virginia Satir
                    tin rằng vai trò mà chúng ta đảm nhận trong gia đình, nơi
                    chúng ta tồn tại là hạt giống có phản ánh hướng rất lớn đến
                    quá trình trưởng thành. Bà tin rằng yếu tố gia đình đã góp
                    phần tạo nên tính cách của mỗi con người. Bandler và Grinder
                    đã sử dụng Mô hình trị liệu của Satir để tạo ra Mô hình Meta
                    với các mẫu câu hỏi giúp tạo ra sự rõ ràng và sáng tỏ trong
                    các vấn đề.
                  </p>
                </div>
              </div>

              {/* Phần mới: Những người tiếp nối và phát triển NLP */}
              <h2 className="text-3xl sm:text-4xl lg:text-5xl font-bold text-center text-gray-800 mb-10 mt-16 leading-tight">
                NHỮNG NGƯỜI TIẾP NỐI VÀ PHÁT TRIỂN NLP: CHẮP CÁNH CHO MỘT LĨNH
                VỰC MANG TẦM ẢNH HƯỞNG TO LỚN
              </h2>

              <p className="text-base sm:text-lg lg:text-xl text-gray-700 text-center mb-12 max-w-3xl mx-auto leading-relaxed">
                Kể từ khi được Richard Bandler và John Grinder giới thiệu vào
                những năm 1970, NLP đã trải qua quá trình phát triển mạnh mẽ với
                sự đóng góp của nhiều nhà nghiên cứu và thực hành xuất sắc. Họ
                đã tiếp nối và phát triển NLP thành những công cụ thực tiễn, dễ
                ứng dụng, mang lại lợi ích to lớn cho con người trong nhiều lĩnh
                vực. Dưới đây là một số nhân vật tiêu biểu:
              </p>

              <div className="grid grid-cols-1 md:grid-cols-3 gap-8 sm:gap-10 lg:gap-12">
                {/* Thẻ thông tin về Tad James */}
                <div className="bg-white border border-gray-200 rounded-lg shadow-md p-6 flex flex-col items-center text-center transition-transform transform hover:scale-105 duration-300">
                  <img
                    src="https://placehold.co/150x150/E0E0E0/333333"
                    alt="Hình ảnh Tad James"
                    className="w-32 h-32 sm:w-36 sm:h-36 rounded-full object-cover mb-4 border-4 border-blue-500 shadow-md"
                  />
                  <h3 className="text-xl sm:text-2xl font-semibold text-gray-900 mb-2">
                    TAD JAMES
                  </h3>
                  <p className="text-sm sm:text-base text-gray-600 leading-relaxed">
                    Nhà tiên phong trong lĩnh vực trị liệu dòng thời gian
                  </p>
                </div>

                {/* Thẻ thông tin về Robert Dilts */}
                <div className="bg-white border border-gray-200 rounded-lg shadow-md p-6 flex flex-col items-center text-center transition-transform transform hover:scale-105 duration-300">
                  <img
                    src="https://placehold.co/150x150/E0E0E0/333333"
                    alt="Hình ảnh Robert Dilts"
                    className="w-32 h-32 sm:w-36 sm:h-36 rounded-full object-cover mb-4 border-4 border-blue-500 shadow-md"
                  />
                  <h3 className="text-xl sm:text-2xl font-semibold text-gray-900 mb-2">
                    ROBERT DILTS
                  </h3>
                  <p className="text-sm sm:text-base text-gray-600 leading-relaxed">
                    Nhà nghiên cứu và phát triển đa tài
                  </p>
                </div>

                {/* Thẻ thông tin về Anthony Robbins */}
                <div className="bg-white border border-gray-200 rounded-lg shadow-md p-6 flex flex-col items-center text-center transition-transform transform hover:scale-105 duration-300">
                  <img
                    src="https://placehold.co/150x150/E0E0E0/333333"
                    alt="Hình ảnh Anthony Robbins"
                    className="w-32 h-32 sm:w-36 sm:h-36 rounded-full object-cover mb-4 border-4 border-blue-500 shadow-md"
                  />
                  <h3 className="text-xl sm:text-2xl font-semibold text-gray-900 mb-2">
                    ANTHONY ROBBINS
                  </h3>
                  <p className="text-sm sm:text-base text-gray-600 leading-relaxed">
                    "Gương mặt đại diện" cho NLP
                  </p>
                </div>
              </div>

              {/* Phần mới: Hành trình phát triển năng lực cùng hệ thống ABNLP */}
              <h2 className="text-3xl sm:text-4xl lg:text-5xl font-bold text-center text-gray-800 mb-10 mt-16 leading-tight">
                HÀNH TRÌNH PHÁT TRIỂN NĂNG LỰC CÙNG HỆ THỐNG ABNLP
              </h2>

              {/* Hình ảnh của hành trình phát triển năng lực */}
              <div className="flex justify-center mb-12">
                <img
                  src="https://placehold.co/800x450/E0E0E0/333333"
                  alt="Hành trình phát triển năng lực cùng hệ thống ABNLP"
                  className="w-full max-w-4xl rounded-lg shadow-lg"
                />
              </div>
            </div>
          </Section>
        </FadeIn>
      </div>
    </PageTransition>
  );
}

const ToolCard = ({
  title,
  description,
  imageUrl,
}: {
  title: string;
  description: string;
  imageUrl: string;
}) => {
  return (
    <div className="bg-white rounded-lg shadow-lg overflow-hidden border border-gray-200">
      <img
        src={imageUrl}
        alt={title}
        className="w-full h-48 object-cover"
        onError={(e) => {
          const target = e.target as HTMLImageElement;
          target.onerror = null;
          target.src = "https://placehold.co/300x200/E0E0E0/666666";
        }}
      />
      <div className="p-6">
        <h3 className="text-xl font-semibold text-blue-600 mb-2">{title}</h3>
        <p className="text-gray-700 text-base leading-relaxed">{description}</p>
      </div>
    </div>
  );
};

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
          className={`w-5 h-5 transition-transform duration-300 ${
            isOpen ? "rotate-180" : ""
          }`}
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
