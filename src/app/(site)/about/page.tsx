import { Metadata } from 'next';

export const metadata: Metadata = {
  title: 'Về chúng tôi - InnerBright',
  description: 'Tìm hiểu về câu chuyện InnerBright Training & Coaching và đội ngũ chuyên gia NLP',
};

export default function AboutPage() {
  return (
    <div className="container mx-auto px-4 py-16">
      <div className="max-w-4xl mx-auto">
        {/* Hero Section */}
        <div className="text-center mb-16">
          <h1 className="text-4xl md:text-6xl font-bold text-gray-900 mb-6">
            Câu Chuyện Về <span className="text-blue-600">InnerBright</span>
          </h1>
          <p className="text-xl text-gray-600 leading-relaxed">
            InnerBright Training & Coaching được thành lập từ năm 2020 bởi nhà đào tạo Chloe Quý Châu
          </p>
        </div>

        {/* Vision & Mission */}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-8 mb-16">
          <div className="bg-white rounded-lg shadow-lg p-8">
            <h3 className="text-2xl font-bold text-gray-800 mb-4">Tầm Nhìn</h3>
            <p className="text-gray-600 leading-relaxed">
              Trang bị cho mỗi người Việt Nam đủ sở hữu tư duy phát triển bản thân đúng đắn, 
              hiệu quả và bền vững.
            </p>
          </div>
          
          <div className="bg-white rounded-lg shadow-lg p-8">
            <h3 className="text-2xl font-bold text-gray-800 mb-4">Sứ Mệnh</h3>
            <p className="text-gray-600 leading-relaxed">
              Tạo dựng cuộc sống thịnh vượng hơn cho người người Việt Nam bằng việc khai phóng 
              tiềm năng và giúp phát huy tối đa nội lực của mỗi cá nhân.
            </p>
          </div>
        </div>

        {/* Core Values */}
        <div className="bg-gray-50 rounded-lg p-8 mb-16">
          <h3 className="text-2xl font-bold text-gray-800 mb-6 text-center">Giá Trị Cốt Lõi</h3>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            <div className="text-center">
              <div className="w-16 h-16 bg-blue-100 rounded-full flex items-center justify-center mx-auto mb-4">
                <span className="text-blue-600 text-2xl">🎯</span>
              </div>
              <h4 className="font-semibold text-lg mb-2">Hệ Thống</h4>
              <p className="text-gray-600">Phương pháp có hệ thống và khoa học</p>
            </div>
            
            <div className="text-center">
              <div className="w-16 h-16 bg-green-100 rounded-full flex items-center justify-center mx-auto mb-4">
                <span className="text-green-600 text-2xl">🤝</span>
              </div>
              <h4 className="font-semibold text-lg mb-2">Hợp Nhất</h4>
              <p className="text-gray-600">Kết hợp tốt nhất từ Đông và Tây</p>
            </div>
            
            <div className="text-center">
              <div className="w-16 h-16 bg-purple-100 rounded-full flex items-center justify-center mx-auto mb-4">
                <span className="text-purple-600 text-2xl">💝</span>
              </div>
              <h4 className="font-semibold text-lg mb-2">Tử Tế</h4>
              <p className="text-gray-600">Sự chăm sóc và quan tâm chân thành</p>
            </div>
          </div>
        </div>

        {/* Founder */}
        <div className="bg-white rounded-lg shadow-lg p-8">
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-8 items-center">
            <div>
              <h3 className="text-2xl font-bold text-gray-800 mb-4">
                Nhà Đào Tạo Chloe Quý Châu
              </h3>
              <p className="text-gray-600 mb-4 leading-relaxed">
                Với hơn 5 năm kinh nghiệm trong lĩnh vực NLP và Time Line Therapy, 
                Chloe Quý Châu là thành viên chính thức của Hiệp Hội NLP Hoa Kỳ (ABNLP).
              </p>
              <p className="text-gray-600 leading-relaxed">
                Bà đã giúp đỡ hàng ngàn người Việt Nam khai phóng tiềm năng và đạt được 
                những thành công vượt trội trong cuộc sống.
              </p>
            </div>
            <div className="relative">
              <img
                src="https://placehold.co/400x500/e0e0e0/333333?text=Chloe+Quý+Châu"
                alt="Chloe Quý Châu"
                className="rounded-lg shadow-md w-full"
              />
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
