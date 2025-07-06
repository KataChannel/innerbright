"use client";
export default function Layout({ children }: { children: React.ReactNode }) {
  return (
    <div className="min-h-screen bg-gray-100 font-sans antialiased">
      <section
        id="section2"
        className="relative bg-white rounded-xl shadow-lg overflow-hidden mb-8"
      >
        <div className="relative h-80 lg:h-96">
          <img
            src="https://placehold.co/800x300/4f46e5/ffffff"
            alt="NLP Background"
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
            <span className="font-semibold">Lập Trình Ngôn Ngữ Tư Duy NLP</span>{" "}
            (Neuro Linguistic Programming) là chìa khóa giúp khai phá sức mạnh
            của bản thân. Các nhà khoa học đã công nhận tầm quan trọng của
            phương pháp NLP. Nếu hiểu rõ về NLP, bạn sẽ có cơ hội phát triển bản
            thân lên tầm cao mới. Vậy phương pháp NLP là gì?
          </p>
          <p className="text-lg md:text-xl text-gray-700 leading-relaxed">
            NLP được khởi nguồn tại Mỹ, bởi John Grinder (nhà ngôn ngữ học) và
            Richard Bandler (nhà toán học và liệu pháp tâm lý Gestalt) với mục
            đích tạo ra các mô hình học tập rõ ràng về sự xuất sắc của con
            người.
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
            <div className="relative bg-blue-700 p-6 rounded-lg shadow-md hover:shadow-xl transition-shadow duration-300 overflow-hidden">
              <div className="absolute inset-0 bg-gradient-to-br from-blue-600 to-blue-800" />
              <div className="relative flex flex-col items-center text-center">
                <div className="w-16 h-16 md:w-20 md:h-20 bg-white text-blue-700 rounded-full flex items-center justify-center text-4xl md:text-5xl font-extrabold mb-4 border-4 border-blue-300">
                  1
                </div>
                <p className="text-lg md:text-xl font-medium text-white">
                  Tại sao tôi trở thành con người mà tôi đang là?
                </p>
              </div>
            </div>

            <div className="relative bg-blue-700 p-6 rounded-lg shadow-md hover:shadow-xl transition-shadow duration-300 overflow-hidden">
              <div className="absolute inset-0 bg-gradient-to-br from-blue-600 to-blue-800" />
              <div className="relative flex flex-col items-center text-center">
                <div className="w-16 h-16 md:w-20 md:h-20 bg-white text-blue-700 rounded-full flex items-center justify-center text-4xl md:text-5xl font-extrabold mb-4 border-4 border-blue-300">
                  2
                </div>
                <p className="text-lg md:text-xl font-medium text-white">
                  Tôi thực sự mong muốn điều gì trong cuộc đời?
                </p>
              </div>
            </div>

            <div className="relative bg-blue-700 p-6 rounded-lg shadow-md hover:shadow-xl transition-shadow duration-300 overflow-hidden">
              <div className="absolute inset-0 bg-gradient-to-br from-blue-600 to-blue-800" />
              <div className="relative flex flex-col items-center text-center">
                <div className="w-16 h-16 md:w-20 md:h-20 bg-white text-blue-700 rounded-full flex items-center justify-center text-4xl md:text-5xl font-extrabold mb-4 border-4 border-blue-300">
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
            Bạn chính là tác giả của cuộc đời mình, là đạo diễn của vở kịch mang
            tên "Cuộc sống" mà bạn đóng vai chính. Mỗi người sinh ra đều sở hữu
            tiềm năng to lớn bên trong để kiến tạo cuộc sống như mong muốn. Tuy
            nhiên, thay vì nắm chặt tay chèo dẫn dắt con thuyền cuộc đời mình
            đến mục tiêu, nhiều người lại mặc một phương hướng vô không biết
            tiếp tục bước đi như thế nào. Những nỗi lo âu đã vô tình đặt cản
            đường xuất hiện, khiến nhiều người lựa chọn dừng lại.
          </p>
          <h2 className="text-3xl md:text-4xl font-bold text-center text-blue-600 mb-6">
            Nhưng bạn sẽ không nằm trong số đó!
          </h2>
          <h3 className="text-2xl md:text-3xl font-semibold text-center text-gray-800 mb-4">
            NLP - Nguồn lực mạnh mẽ giúp bạn làm chủ cuộc đời
          </h3>
          <p className="text-lg md:text-xl text-gray-700 leading-relaxed">
            Một trong những nguồn lực tuyệt vời nhất mà mỗi người sở hữu chính
            là khả năng học cách làm chủ tâm trí và hiện diện - sống trọn vẹn
            với thực tại. Cách chúng ta phản ứng với cuộc sống, những suy nghĩ,
            cảm xúc, hành động, niềm tin và giá trị theo đuổi đóng vai trò vô
            cùng quan trọng, tác động trực tiếp đến mọi kết quả trong cuộc đời.
            Và NLP chính là công cụ giúp bạn làm chủ những yếu tố then chốt này.
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
              đến những chương trình chạy ngầm trong tiềm thức, dẫn dắt hành vi
              và tạo ra kết quả trong cuộc sống của chúng ta.
            </p>
          </div>

          <div className="max-w-6xl mx-auto grid grid-cols-1 md:grid-cols-3 gap-8">
            <div className="bg-white p-6 rounded-lg shadow-md border-t-4 border-blue-500">
              <h2 className="text-2xl font-bold text-blue-700 mb-3">
                Neuro - Tư duy
              </h2>
              <p className="text-gray-700 leading-relaxed">
                Hệ thống nơ-ron bộ và mạng lưới thần kinh sinh tồn. Trong con
                người có trung bình dao động từ 80 đến 100 tỷ nơ-ron và 100 tỷ
                tế bào nơ-ron thần kinh, hoạt động chính của nó là giúp chúng ta
                có thể tiếp nhận, xử lý thông tin. Sau đó bộ não sẽ tạo ra các
                thiết lập và hệ thống phản hồi làm việc một cách hiệu quả hơn
                trong cuộc sống.
              </p>
            </div>

            <div className="bg-white p-6 rounded-lg shadow-md border-t-4 border-green-500">
              <h2 className="text-2xl font-bold text-green-700 mb-3">
                Linguistic - Ngôn ngữ
              </h2>
              <p className="text-gray-700 leading-relaxed">
                Cách chúng ta sử dụng ngôn từ không chỉ đơn thuần diễn đạt ý
                định của chúng ta mà còn thể hiện niềm tin và thái độ của mỗi
                người. Một lời nói có thể mang năng lượng tích cực, có thể mang
                năng lượng tiêu cực. Một lời nói có thể mang năng lượng tiêu
                cực, một lời nói có thể mang năng lượng tiêu cực. Một lời nói có
                thể mang năng lượng tiêu cực. Một lời nói có thể mang năng lượng
                tiêu cực. Một lời nói có thể mang năng lượng tiêu cực. Một lời
                nói có thể mang năng lượng tiêu cực. Một lời nói có thể mang
                năng lượng tiêu cực.
              </p>
            </div>

            <div className="bg-white p-6 rounded-lg shadow-md border-t-4 border-purple-500">
              <h2 className="text-2xl font-bold text-purple-700 mb-3">
                Programming - Lập trình
              </h2>
              <p className="text-gray-700 leading-relaxed">
                Tương tự như hệ điều hành máy tính, lập trình ngôn ngữ tư duy là
                dòng hóa các phản ứng thông tin và hành vi. Nó là một tập hợp
                các nguyên tắc giúp điều chỉnh các kiểu tiết niệu và hành vi
                không mong muốn, đồng thời hay mới lạ. Có thể hóa số chương
                trình tư duy và hành vi để đạt được hiệu quả hơn.
              </p>
            </div>
          </div>
        </section>

        <section
          className="relative py-20 px-4 sm:px-6 lg:px-8 bg-cover bg-center rounded-lg mx-4 sm:mx-6 lg:mx-8 shadow-lg"
          style={{
            backgroundImage: `url(https://placehold.co/1200x400/A0A0A0/FFFFFF?text=Background+Image)`,
          }}
        >
          <div className="absolute inset-0 bg-black opacity-50 rounded-lg"></div>
          <div className="relative max-w-4xl mx-auto text-center text-white">
            <h2 className="text-3xl sm:text-4xl font-bold mb-4 leading-tight">
              NLP - Tái cấu trúc hệ điều hành cuộc đời bạn
            </h2>
            <p className="text-lg sm:text-xl leading-relaxed">
              NLP dựa trên cơ sở bộ não của chúng ta có thể được tái cấu trúc để
              biến chúng ta thành những thực thể mới. Hay nói cách khác, bộ não
              là hệ điều hành của cuộc sống. NLP giúp thay đổi cách chúng ta
              nghĩ về bản thân, về người khác, về thế giới và thay thế bằng
              những điều hữu ích cho cuộc sống. NLP giúp tái cấu trúc những
              chương trình chạy ngầm bên trong, từ đó thay đổi tư duy và hành vi
              để đạt được hiệu quả.
            </p>
          </div>
        </section>

        <section className="py-16 px-4 sm:px-6 lg:px-8">
          <div className="max-w-6xl mx-auto text-center mb-12">
            <h2 className="text-3xl sm:text-4xl font-bold text-blue-700 mb-3">
              NLP - Hộp công cụ cuộc sống đa năng
            </h2>
            <p className="text-xl sm:text-2xl text-gray-700">
              NLP là một tập hợp gồm nhiều công cụ và kỹ thuật hữu ích trang bị
              cho bạn khả năng
            </p>
          </div>

          <div className="max-w-6xl mx-auto grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-8">
            <ToolCard
              title="Hiểu rõ bản thân"
              description="Hiểu rõ hơn về giá trị, mục tiêu, niềm tin và khả năng của bản thân để phát triển tiềm năng cá nhân."
              imageUrl="https://placehold.co/300x200/F0F0F0/333333?text=Self-Understanding"
            />

            <ToolCard
              title="Hiểu rõ người khác"
              description="Nâng cao kỹ năng giao tiếp, tạo ra mối quan hệ tốt đẹp và ảnh hưởng tích cực đến những người xung quanh."
              imageUrl="https://placehold.co/300x200/F0F0F0/333333?text=Others-Understanding"
            />

            <ToolCard
              title="Làm chủ cuộc sống"
              description="Phát triển khả năng tự quản lý cảm xúc, giải quyết vấn đề và đạt được mục tiêu cuộc sống."
              imageUrl="https://placehold.co/300x200/F0F0F0/333333?text=Life-Mastery"
            />

            <ToolCard
              title="Khai vấn - Coaching"
              description="Cung cấp các công cụ và kỹ thuật để hỗ trợ người khác đạt được mục tiêu và giải quyết vấn đề."
              imageUrl="https://placehold.co/300x200/F0F0F0/333333?text=Coaching"
            />
          </div>
        </section>
    </div>
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
          target.src =
            "https://placehold.co/300x200/E0E0E0/666666?text=Image+Error";
        }}
      />
      <div className="p-6">
        <h3 className="text-xl font-semibold text-blue-600 mb-2">{title}</h3>
        <p className="text-gray-700 text-base leading-relaxed">{description}</p>
      </div>
    </div>
  );
};
