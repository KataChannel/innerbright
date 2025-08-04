import { Metadata } from 'next';export const metadata: Metadata = {  title: 'NLP - Neuro Linguistic Programming | InnerBright',  description: 'Tìm hiểu về NLP - Lập trình ngôn ngữ tư duy và các khóa đào tạo chuyên sâu tại InnerBright',};export default function NLPPage() {  return (    <div className="min-h-screen bg-gray-50">      {/* Hero Section */}      <section className="bg-gradient-to-r from-blue-600 to-purple-700 text-white py-20">        <div className="container mx-auto px-4 text-center">          <h1 className="text-5xl font-bold mb-6">            NLP - Neuro Linguistic Programming          </h1>          <p className="text-xl mb-8 max-w-3xl mx-auto">            Lập trình ngôn ngữ tư duy - Phương pháp thay đổi tích cực từ bên trong             để tạo ra những kết quả vượt trội trong cuộc sống          </p>          <div className="space-x-4">            <button className="bg-white text-blue-600 px-8 py-3 rounded-lg font-semibold hover:bg-gray-100 transition-colors">              Đăng ký khóa học            </button>            <button className="border-2 border-white text-white px-8 py-3 rounded-lg font-semibold hover:bg-white hover:text-blue-600 transition-colors">              Tìm hiểu thêm            </button>          </div>        </div>      </section>      {/* What is NLP Section */}      <section className="py-16">        <div className="container mx-auto px-4">          <div className="max-w-4xl mx-auto text-center mb-12">            <h2 className="text-3xl font-bold text-gray-800 mb-6">NLP là gì?</h2>            <p className="text-lg text-gray-600 leading-relaxed">              NLP (Neuro Linguistic Programming) là một tập hợp các kỹ thuật và phương pháp               để hiểu và thay đổi cách chúng ta suy nghĩ, cảm nhận và hành động.            </p>          </div>          <div className="grid grid-cols-1 md:grid-cols-3 gap-8">            <div className="text-center">              <div className="w-20 h-20 bg-blue-100 rounded-full flex items-center justify-center mx-auto mb-6">                <span className="text-blue-600 text-3xl">🧠</span>              </div>              <h3 className="text-xl font-semibold mb-4">Neuro (Thần kinh)</h3>              <p className="text-gray-600">                Cách bộ não và hệ thần kinh xử lý thông tin và tạo ra trải nghiệm              </p>            </div>            <div className="text-center">              <div className="w-20 h-20 bg-green-100 rounded-full flex items-center justify-center mx-auto mb-6">                <span className="text-green-600 text-3xl">💬</span>              </div>              <h3 className="text-xl font-semibold mb-4">Linguistic (Ngôn ngữ)</h3>              <p className="text-gray-600">                Cách ngôn ngữ ảnh hưởng đến tư duy và hành vi của chúng ta              </p>            </div>            <div className="text-center">              <div className="w-20 h-20 bg-purple-100 rounded-full flex items-center justify-center mx-auto mb-6">                <span className="text-purple-600 text-3xl">⚙️</span>              </div>              <h3 className="text-xl font-semibold mb-4">Programming (Lập trình)</h3>              <p className="text-gray-600">                Các chiến lược và kỹ thuật để tối ưu hóa tư duy và hành vi              </p>            </div>          </div>        </div>      </section>

      {/* Benefits Section */}
      <section className="bg-white py-16">
        <div className="container mx-auto px-4">
          <h2 className="text-3xl font-bold text-center text-gray-800 mb-12">
            Lợi ích của NLP
          </h2>
          
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
            {[
              {
                title: "Cải thiện giao tiếp",
                description: "Nâng cao khả năng giao tiếp hiệu quả và xây dựng mối quan hệ tốt hơn",
                icon: "🗣️"
              },
              {
                title: "Quản lý cảm xúc",
                description: "Kiểm soát và điều chỉnh cảm xúc một cách tích cực",
                icon: "😌"
              },
              {
                title: "Đạt mục tiêu",
                description: "Tạo ra chiến lược rõ ràng để đạt được những mục tiêu mong muốn",
                icon: "🎯"
              },
              {
                title: "Tăng tự tin",
                description: "Xây dựng lòng tự tin và sự tự tin trong mọi tình huống",
                icon: "💪"
              },
              {
                title: "Lãnh đạo hiệu quả",
                description: "Phát triển kỹ năng lãnh đạo và ảnh hưởng tích cực",
                icon: "👑"
              },
              {
                title: "Thay đổi thói quen",
                description: "Loại bỏ các thói quen xấu và xây dựng thói quen tích cực",
                icon: "🔄"
              }
            ].map((benefit, index) => (
              <div key={index} className="bg-gray-50 rounded-lg p-6 text-center">
                <div className="text-4xl mb-4">{benefit.icon}</div>
                <h3 className="text-xl font-semibold mb-3">{benefit.title}</h3>
                <p className="text-gray-600">{benefit.description}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* CTA Section */}
      <section className="bg-blue-600 text-white py-16">
        <div className="container mx-auto px-4 text-center">
          <h2 className="text-3xl font-bold mb-6">
            Bắt đầu hành trình thay đổi của bạn ngay hôm nay
          </h2>
          <p className="text-xl mb-8 max-w-2xl mx-auto">
            Tham gia khóa đào tạo NLP chuyên sâu cùng InnerBright và khám phá tiềm năng vô hạn của bản thân
          </p>
          <div className="space-x-4">
            <button className="bg-white text-blue-600 px-8 py-3 rounded-lg font-semibold hover:bg-gray-100 transition-colors">
              Đăng ký ngay
            </button>
            <button className="border-2 border-white text-white px-8 py-3 rounded-lg font-semibold hover:bg-white hover:text-blue-600 transition-colors">
              Liên hệ tư vấn
            </button>
          </div>
        </div>
      </section>
    </div>
  );
}