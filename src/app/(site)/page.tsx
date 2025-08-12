import React from 'react';
import { Metadata } from 'next';
import { 
  RobotoDisplay, 
  RobotoHeadline, 
  RobotoTitle, 
  RobotoBody, 
  RobotoBodyLarge, 
  RobotoButton,
  RobotoCaption 
} from '@/components/ui/Typography';

export const metadata: Metadata = {
  title: 'InnerBright - Khám phá tiềm năng bên trong bạn',
  description: 'Khám phá sức mạnh tiềm ẩn bên trong bạn với các khóa học NLP, Time Line Therapy và Hypnosis chuyên nghiệp',
  keywords: 'NLP, Time Line Therapy, Hypnosis, phát triển bản thân, coaching, InnerBright',
};

export default function HomePage() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100">
      <div className="container mx-auto px-6 py-12">
        {/* Header */}
        <header className="text-center mb-16">
          <RobotoDisplay className="text-gray-900 mb-4">
            InnerBright
          </RobotoDisplay>
          <RobotoBodyLarge className="text-gray-600 max-w-3xl mx-auto">
            Khám phá sức mạnh tiềm ẩn bên trong bạn với các khóa học NLP, Time Line Therapy và Hypnosis chuyên nghiệp
          </RobotoBodyLarge>
        </header>

        {/* Hero Section */}
        <section className="grid md:grid-cols-2 gap-12 items-center mb-16">
          <div>
            <RobotoTitle className="text-gray-900 mb-6">
              Phát triển bản thân với công nghệ tâm lý học hiện đại
            </RobotoTitle>
            <RobotoBody className="text-gray-700 mb-8">
              InnerBright mang đến cho bạn những phương pháp đã được chứng minh khoa học 
              để giúp bạn vượt qua giới hạn, thay đổi tư duy và đạt được mục tiêu cuộc sống.
            </RobotoBody>
            <div className="flex gap-4">
              <button className="bg-blue-600 hover:bg-blue-700 text-white px-8 py-3 rounded-lg transition-colors">
                <RobotoButton className="text-white">
                  Khám phá khóa học
                </RobotoButton>
              </button>
              <button className="border border-gray-300 hover:border-gray-400 text-gray-700 px-8 py-3 rounded-lg transition-colors">
                <RobotoButton className="text-gray-700">
                  Tư vấn miễn phí
                </RobotoButton>
              </button>
            </div>
          </div>
          <div className="bg-white p-8 rounded-2xl shadow-lg">
            <RobotoTitle className="text-gray-900 mb-6">
              Các khóa học nổi bật
            </RobotoTitle>
            <div className="space-y-4">
              <div className="flex items-center gap-4">
                <div className="w-3 h-3 bg-blue-500 rounded-full"></div>
                <RobotoBody>NLP - Lập trình ngôn ngữ tư duy</RobotoBody>
              </div>
              <div className="flex items-center gap-4">
                <div className="w-3 h-3 bg-green-500 rounded-full"></div>
                <RobotoBody>Time Line Therapy - Trị liệu dòng thời gian</RobotoBody>
              </div>
              <div className="flex items-center gap-4">
                <div className="w-3 h-3 bg-purple-500 rounded-full"></div>
                <RobotoBody>Hypnosis - Thôi miên chuyên nghiệp</RobotoBody>
              </div>
            </div>
          </div>
        </section>

        {/* Services Section */}
        <section className="mb-16">
          <RobotoHeadline className="text-center mb-12 text-gray-900">
            Dịch vụ của chúng tôi
          </RobotoHeadline>
          
          <div className="grid md:grid-cols-3 gap-8">
            <div className="bg-white p-8 rounded-2xl shadow-lg text-center">
              <div className="w-16 h-16 bg-blue-100 rounded-full flex items-center justify-center mx-auto mb-6">
                <div className="w-8 h-8 bg-blue-500 rounded-full"></div>
              </div>
              <RobotoTitle className="mb-4 text-blue-600">
                Coaching cá nhân
              </RobotoTitle>
              <RobotoBody>
                Hướng dẫn một-đối-một để phát triển kỹ năng và đạt được mục tiêu cá nhân
              </RobotoBody>
            </div>
            
            <div className="bg-white p-8 rounded-2xl shadow-lg text-center">
              <div className="w-16 h-16 bg-green-100 rounded-full flex items-center justify-center mx-auto mb-6">
                <div className="w-8 h-8 bg-green-500 rounded-full"></div>
              </div>
              <RobotoTitle className="mb-4 text-green-600">
                Khóa học online
              </RobotoTitle>
              <RobotoBody>
                Các khóa học trực tuyến chất lượng cao về phát triển bản thân và kỹ năng sống
              </RobotoBody>
            </div>
            
            <div className="bg-white p-8 rounded-2xl shadow-lg text-center">
              <div className="w-16 h-16 bg-purple-100 rounded-full flex items-center justify-center mx-auto mb-6">
                <div className="w-8 h-8 bg-purple-500 rounded-full"></div>
              </div>
              <RobotoTitle className="mb-4 text-purple-600">
                Cộng đồng hỗ trợ
              </RobotoTitle>
              <RobotoBody>
                Kết nối với cộng đồng những người cùng chí hướng trong hành trình phát triển
              </RobotoBody>
            </div>
          </div>
        </section>

        {/* Testimonials */}
        <section className="mb-16">
          <RobotoHeadline className="text-center mb-12 text-gray-900">
            Khách hàng nói gì về chúng tôi
          </RobotoHeadline>
          
          <div className="grid md:grid-cols-2 gap-8">
            <div className="bg-white p-8 rounded-2xl shadow-lg">
              <RobotoBody className="mb-6 italic">
                "Khóa học NLP đã thay đổi hoàn toàn cách tôi nhìn nhận và xử lý các vấn đề trong cuộc sống. 
                Tôi cảm thấy tự tin hơn và có thể đạt được những mục tiêu mà trước đây tưởng như bất khả thi."
              </RobotoBody>
              <div className="flex items-center gap-4">
                <div className="w-12 h-12 bg-gray-200 rounded-full"></div>
                <div>
                  <RobotoBody className="font-medium">Nguyễn Thị Lan</RobotoBody>
                  <RobotoCaption>Giám đốc Marketing</RobotoCaption>
                </div>
              </div>
            </div>
            
            <div className="bg-white p-8 rounded-2xl shadow-lg">
              <RobotoBody className="mb-6 italic">
                "Time Line Therapy đã giúp tôi vượt qua những trải nghiệm khó khăn trong quá khứ. 
                Giờ đây tôi có thể sống trọn vẹn trong hiện tại và hướng tới tương lai tích cực."
              </RobotoBody>
              <div className="flex items-center gap-4">
                <div className="w-12 h-12 bg-gray-200 rounded-full"></div>
                <div>
                  <RobotoBody className="font-medium">Trần Văn Minh</RobotoBody>
                  <RobotoCaption>Doanh nhân</RobotoCaption>
                </div>
              </div>
            </div>
          </div>
        </section>

        {/* CTA Section */}
        <section className="bg-gradient-to-r from-blue-600 to-purple-600 text-white p-12 rounded-2xl text-center">
          <RobotoHeadline className="mb-6 text-white">
            Sẵn sàng thay đổi cuộc sống?
          </RobotoHeadline>
          <RobotoBodyLarge className="mb-8 text-blue-100">
            Tham gia cùng hàng nghìn người đã tìm thấy hướng đi mới trong cuộc sống
          </RobotoBodyLarge>
          <div className="flex gap-4 justify-center">
            <button className="bg-white text-blue-600 px-8 py-4 rounded-lg hover:bg-gray-100 transition-colors">
              <RobotoButton className="text-blue-600">
                Đăng ký ngay
              </RobotoButton>
            </button>
            <button className="border border-white text-white px-8 py-4 rounded-lg hover:bg-white hover:text-blue-600 transition-colors">
              <RobotoButton className="hover:text-blue-600">
                Tìm hiểu thêm
              </RobotoButton>
            </button>
          </div>
        </section>
      </div>
    </div>
  );
}
