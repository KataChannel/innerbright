import React from 'react';
import Hero from '@/components/Hero';
import Section from '@/components/Section';
import Card from '@/components/Card';
import Button from '@/components/Button';
import { Metadata } from 'next';

export const metadata: Metadata = {
  title: 'Trang chủ - InnerBright Training & Coaching',
  description: 'Khai phóng tiềm năng và phát huy tối đa nội lực thông qua NLP và Time Line Therapy',
};

export default function HomePage() {
  return (
    <main className="min-h-screen">
      {/* Hero Section */}
      <Hero
        title={
          <>
            Khám Phá <span className="text-blue-600">Tiềm Năng Nội Tâm</span>
          </>
        }
        subtitle="Trung tâm Tâm lý Trị liệu Chuyên nghiệp"
        description="Chúng tôi cung cấp các liệu pháp tâm lý hiện đại như NLP và Time-line Therapy để giúp bạn vượt qua khó khăn và phát triển bản thân."
        imageSrc="/images/hero-therapy.jpg"
        imageAlt="Tâm lý trị liệu InnerBright"
        height="large"
        textPosition="center"
        className="mb-0"
      />

      {/* Services Section */}
      <Section
        backgroundColor="gray"
        padding="large"
        className="py-16"
      >
        <div className="container mx-auto px-4">
          <div className="text-center mb-12">
            <h2 className="text-3xl md:text-4xl font-bold text-gray-800 mb-4">
              Dịch Vụ Của Chúng Tôi
            </h2>
            <p className="text-lg text-gray-600 max-w-2xl mx-auto">
              Các phương pháp trị liệu hiện đại và hiệu quả được áp dụng bởi đội ngũ chuyên gia có kinh nghiệm
            </p>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
            <Card
              title="NLP Therapy"
              content={
                <div>
                  <p className="text-gray-600 mb-4">
                    Lập trình ngôn ngữ tư duy giúp thay đổi các mẫu hình tư duy tiêu cực và xây dựng mindset tích cực.
                  </p>
                  <Button variant="primary" size="sm">
                    Tìm hiểu thêm
                  </Button>
                </div>
              }
              imageSrc="/images/nlp-therapy.jpg"
              imageAlt="NLP Therapy"
              className="h-full"
            />

            <Card
              title="Time-line Therapy"
              content={
                <div>
                  <p className="text-gray-600 mb-4">
                    Liệu pháp dòng thời gian giúp giải phóng cảm xúc tiêu cực và tạo ra tương lai tích cực.
                  </p>
                  <Button variant="primary" size="sm">
                    Tìm hiểu thêm
                  </Button>
                </div>
              }
              imageSrc="/images/timeline-therapy.jpg"
              imageAlt="Time-line Therapy"
              className="h-full"
            />

            <Card
              title="Tư Vấn Cá Nhân"
              content={
                <div>
                  <p className="text-gray-600 mb-4">
                    Buổi tư vấn riêng với chuyên gia để giải quyết các vấn đề cá nhân một cách hiệu quả.
                  </p>
                  <Button variant="primary" size="sm">
                    Đặt lịch tư vấn
                  </Button>
                </div>
              }
              imageSrc="/images/counseling.jpg"
              imageAlt="Tư vấn cá nhân"
              className="h-full"
            />
          </div>
        </div>
      </Section>

      {/* About Section */}
      <Section
        backgroundColor="white"
        padding="large"
        className="py-16"
      >
        <div className="container mx-auto px-4">
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-12 items-center">
            <div>
              <h2 className="text-3xl md:text-4xl font-bold text-gray-800 mb-6">
                Về InnerBright
              </h2>
              <p className="text-lg text-gray-600 mb-6">
                InnerBright là trung tâm tâm lý trị liệu hàng đầu, chuyên cung cấp các liệu pháp tâm lý hiện đại 
                và hiệu quả. Chúng tôi tin rằng mọi người đều có tiềm năng để vượt qua khó khăn và đạt được 
                hạnh phúc trong cuộc sống.
              </p>
              <p className="text-lg text-gray-600 mb-8">
                Với đội ngũ chuyên gia giàu kinh nghiệm và các phương pháp trị liệu được chứng minh khoa học, 
                chúng tôi cam kết đồng hành cùng bạn trên hành trình phát triển bản thân.
              </p>
              <Button variant="primary" size="lg">
                Tìm hiểu về chúng tôi
              </Button>
            </div>
            <div className="relative">
              <img
                src="/images/about-innerbright.jpg"
                alt="Về InnerBright"
                className="rounded-lg shadow-lg w-full h-auto"
              />
            </div>
          </div>
        </div>
      </Section>

      {/* CTA Section */}
      <Section
        backgroundColor="dark"
        padding="large"
        className="py-16 text-white"
      >
        <div className="container mx-auto px-4 text-center">
          <h2 className="text-3xl md:text-4xl font-bold mb-6">
            Sẵn Sàng Bắt Đầu Hành Trình Của Bạn?
          </h2>
          <p className="text-xl mb-8 max-w-2xl mx-auto">
            Đừng để những khó khăn cản trở bạn. Hãy liên hệ với chúng tôi ngay hôm nay 
            để bắt đầu hành trình thay đổi tích cực.
          </p>
          <div className="flex flex-col sm:flex-row gap-4 justify-center">
            <Button variant="secondary" size="lg">
              Đặt lịch tư vấn miễn phí
            </Button>
            <Button variant="outline" size="lg">
              Liên hệ với chúng tôi
            </Button>
          </div>
        </div>
      </Section>
    </main>
  );
}
