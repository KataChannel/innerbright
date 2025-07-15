// 📖 Examples - Ví dụ sử dụng Components InnerBright

import { Section, Hero, Card } from '@/components';

// 🏠 Homepage Example
export const HomepageExample = () => (
  <div>
    {/* Hero Section */}
    <Section padding="none" id="hero">
      <Hero
        title={
          <>
            Khai phóng <span className="text-blue-400">tiềm năng</span> nội tại
          </>
        }
        subtitle="InnerBright Training & Coaching"
        description="Hành trình phát triển bản thân toàn diện cùng NLP"
        imageSrc="/homepage-hero.jpg"
        imageAlt="InnerBright Homepage Hero"
        height="large"
        textPosition="center"
      />
    </Section>

    {/* Services Section */}
    <Section backgroundColor="gray">
      <h2 className="text-3xl font-bold text-center mb-12">Dịch vụ của chúng tôi</h2>
      <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
        <Card
          title="NLP Training"
          content="Đào tạo Lập trình Ngôn ngữ Tư duy chuyên nghiệp"
          imageSrc="/nlp-training.jpg"
          imageAlt="NLP Training"
        />
        <Card
          title="Personal Coaching"
          content="Huấn luyện cá nhân 1-1 để phát triển bản thân"
          imageSrc="/coaching.jpg"
          imageAlt="Personal Coaching"
        />
        <Card
          title="Corporate Training"
          content="Đào tạo doanh nghiệp và phát triển đội nhóm"
          imageSrc="/corporate.jpg"
          imageAlt="Corporate Training"
        />
      </div>
    </Section>
  </div>
);

// 📖 About Page Example  
export const AboutPageExample = () => (
  <div>
    {/* Story Hero */}
    <Section padding="none" id="story">
      <Hero
        title={
          <>
            <span>CÂU CHUYỆN</span>{' '}
            <span className="text-3xl">Về InnerBright</span>
          </>
        }
        description="InnerBright Training & Coaching được thành lập từ năm 2020 bởi nhà đào tạo Chloe Quý Châu"
        imageSrc="/about-hero.jpg"
        imageAlt="InnerBright Story"
        textPosition="left"
      />
    </Section>

    {/* Mission, Vision, Values */}
    <Section>
      <h2 className="text-center text-3xl font-bold text-blue-700 mb-8">
        <span>Mang trong mình</span> <span className="text-5xl">KHÁT VỌNG</span>
      </h2>
      <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
        <Card
          title="SỨ MỆNH"
          content="Tạo dựng cuộc sống thịnh vượng hơn cho người Việt Nam bằng việc khai phóng tiềm năng"
          imageSrc="/mission-bg.jpg"
          imageAlt="Mission"
          imagePosition="background"
          overlay={true}
          className="text-white"
        />
        <Card
          title="TẦM NHÌN"
          content="Trang bị cho mỗi người Việt Nam tư duy phát triển bản thân đúng đắn"
          imageSrc="/vision-bg.jpg"
          imageAlt="Vision"
          imagePosition="background"
          overlay={true}
          className="text-white"
        />
        <Card
          title="GIÁ TRỊ CỐT LÕI"
          content={
            <ul className="space-y-2">
              <li>• Hệ thống</li>
              <li>• Hợp nhất</li>
              <li>• Tử tế</li>
            </ul>
          }
          imageSrc="/values-bg.jpg"
          imageAlt="Values"
          imagePosition="background"
          overlay={true}
          className="text-white"
        />
      </div>
    </Section>

    {/* Team Section */}
    <Section backgroundColor="gray">
      <h2 className="text-center text-3xl font-bold mb-8">ĐỘI NGŨ CHUYÊN GIA</h2>
      <Card
        title="Chloe Quý Châu"
        content={
          <div>
            <p className="mb-4">
              Chuyên gia đào tạo NLP được chứng nhận bởi ABNLP Coaching Division...
            </p>
            <p>
              Chloe là một trong số ít người Việt đầu tiên được chứng nhận 
              đào tạo Time Line Therapy® trực tiếp từ hiệp hội...
            </p>
          </div>
        }
        imageSrc="/chloe-portrait.jpg"
        imageAlt="Chloe Quý Châu"
        imagePosition="left"
        className="max-w-4xl mx-auto"
      />
    </Section>
  </div>
);

// 📞 Contact Page Example
export const ContactPageExample = () => (
  <div>
    {/* Contact Hero */}
    <Section padding="none">
      <Hero
        title="Liên hệ với chúng tôi"
        subtitle="Bắt đầu hành trình thay đổi của bạn ngay hôm nay"
        imageSrc="/contact-hero.jpg"
        imageAlt="Contact Us"
        height="medium"
        textPosition="center"
      />
    </Section>

    {/* Contact Info */}
    <Section>
      <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
        <Card
          title="Thông tin liên hệ"
          content={
            <div className="space-y-4">
              <div>
                <h4 className="font-semibold">Địa chỉ:</h4>
                <p>123 Đường ABC, Quận 1, TP.HCM</p>
              </div>
              <div>
                <h4 className="font-semibold">Điện thoại:</h4>
                <p>+84 123 456 789</p>
              </div>
              <div>
                <h4 className="font-semibold">Email:</h4>
                <p>info@innerbright.vn</p>
              </div>
            </div>
          }
        />
        <Card
          title="Giờ làm việc"
          content={
            <div className="space-y-2">
              <p><span className="font-semibold">Thứ 2 - Thứ 6:</span> 9:00 - 18:00</p>
              <p><span className="font-semibold">Thứ 7:</span> 9:00 - 12:00</p>
              <p><span className="font-semibold">Chủ nhật:</span> Nghỉ</p>
            </div>
          }
        />
      </div>
    </Section>

    {/* CTA Section */}
    <Section backgroundColor="dark" className="text-white text-center">
      <h2 className="text-3xl font-bold mb-4">Sẵn sàng bắt đầu?</h2>
      <p className="text-xl mb-8">
        Đăng ký tư vấn miễn phí để khám phá tiềm năng của bạn
      </p>
      <button className="bg-blue-600 hover:bg-blue-700 text-white px-8 py-3 rounded-lg text-lg font-semibold transition-colors">
        Đăng ký ngay
      </button>
    </Section>
  </div>
);

// 🎓 Courses Page Example
export const CoursesPageExample = () => (
  <div>
    {/* Courses Hero */}
    <Section padding="none">
      <Hero
        title="Khóa học NLP"
        subtitle="Từ cơ bản đến chuyên gia"
        description="Hệ thống khóa học NLP chuyên nghiệp được chứng nhận quốc tế"
        imageSrc="/courses-hero.jpg"
        imageAlt="NLP Courses"
      />
    </Section>

    {/* Course Categories */}
    <Section>
      <h2 className="text-3xl font-bold text-center mb-12">Khóa học nổi bật</h2>
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
        <Card
          title="NLP Practitioner"
          content={
            <div>
              <p className="mb-4">Khóa học cơ bản về NLP với chứng chỉ quốc tế</p>
              <ul className="text-sm space-y-1">
                <li>• 7 ngày đào tạo</li>
                <li>• Chứng chỉ ABNLP</li>
                <li>• Thực hành intensiv</li>
              </ul>
              <div className="mt-4 text-blue-600 font-bold">15.000.000 VNĐ</div>
            </div>
          }
          imageSrc="/nlp-practitioner.jpg"
          imageAlt="NLP Practitioner"
        />
        
        <Card
          title="NLP Master Practitioner"
          content={
            <div>
              <p className="mb-4">Khóa học nâng cao cho những ai muốn trở thành chuyên gia</p>
              <ul className="text-sm space-y-1">
                <li>• 10 ngày đào tạo</li>
                <li>• Chứng chỉ Master</li>
                <li>• Kỹ thuật cao cấp</li>
              </ul>
              <div className="mt-4 text-blue-600 font-bold">25.000.000 VNĐ</div>
            </div>
          }
          imageSrc="/nlp-master.jpg"
          imageAlt="NLP Master Practitioner"
        />

        <Card
          title="NLP Coach Certification"
          content={
            <div>
              <p className="mb-4">Trở thành NLP Coach được chứng nhận quốc tế</p>
              <ul className="text-sm space-y-1">
                <li>• 12 ngày đào tạo</li>
                <li>• Chứng chỉ Coach</li>
                <li>• Thực hành coaching</li>
              </ul>
              <div className="mt-4 text-blue-600 font-bold">35.000.000 VNĐ</div>
            </div>
          }
          imageSrc="/nlp-coach.jpg"
          imageAlt="NLP Coach"
        />
      </div>
    </Section>

    {/* Testimonials */}
    <Section backgroundColor="gray">
      <h2 className="text-3xl font-bold text-center mb-12">Chia sẻ của học viên</h2>
      <div className="max-w-4xl mx-auto">
        <Card
          content={
            <div className="text-center">
              <blockquote className="text-lg italic mb-4">
                "Khóa học NLP đã thay đổi hoàn toàn cách tôi nhìn nhận cuộc sống. 
                Tôi đã học được cách quản lý cảm xúc và giao tiếp hiệu quả hơn."
              </blockquote>
              <cite className="font-semibold">- Nguyễn Văn A, CEO Công ty XYZ</cite>
            </div>
          }
          imageSrc="/testimonial-bg.jpg"
          imageAlt="Testimonial"
          imagePosition="background"
          overlay={true}
          gradientOverlay={false}
          className="text-white"
        />
      </div>
    </Section>
  </div>
);

// 📝 Blog Page Example
export const BlogPageExample = () => (
  <div>
    {/* Blog Hero */}
    <Section padding="none">
      <Hero
        title="Blog & Insights"
        subtitle="Kiến thức và kinh nghiệm từ chuyên gia"
        imageSrc="/blog-hero.jpg"
        imageAlt="Blog"
        height="medium"
      />
    </Section>

    {/* Featured Article */}
    <Section>
      <Card
        title="5 Kỹ thuật NLP cơ bản mọi người nên biết"
        content={
          <div>
            <p className="mb-4">
              NLP (Neuro Linguistic Programming) không chỉ là một tập hợp kỹ thuật, 
              mà là cách tiếp cận toàn diện để hiểu và thay đổi...
            </p>
            <div className="flex items-center text-sm text-gray-500">
              <span>Chloe Quý Châu</span>
              <span className="mx-2">•</span>
              <span>15 phút đọc</span>
              <span className="mx-2">•</span>
              <span>10 Tháng 7, 2025</span>
            </div>
          </div>
        }
        imageSrc="/featured-article.jpg"
        imageAlt="Featured Article"
        imagePosition="left"
        className="max-w-6xl mx-auto"
      />
    </Section>

    {/* Article Grid */}
    <Section backgroundColor="gray">
      <h2 className="text-3xl font-bold text-center mb-12">Bài viết mới nhất</h2>
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
        {[1, 2, 3, 4, 5, 6].map((i) => (
          <Card
            key={i}
            title={`Bài viết ${i}: Tiêu đề thú vị về NLP`}
            content={
              <div>
                <p className="mb-4">
                  Mô tả ngắn gọn về nội dung bài viết, thu hút người đọc...
                </p>
                <div className="text-sm text-gray-500">
                  <span>5 phút đọc</span>
                  <span className="mx-2">•</span>
                  <span>{5 + i} Tháng 7, 2025</span>
                </div>
              </div>
            }
            imageSrc={`/article-${i}.jpg`}
            imageAlt={`Article ${i}`}
          />
        ))}
      </div>
    </Section>
  </div>
);

// 💼 Corporate Page Example
export const CorporatePageExample = () => (
  <div>
    {/* Corporate Hero */}
    <Section padding="none">
      <Hero
        title="Đào tạo Doanh nghiệp"
        subtitle="Phát triển đội nhóm với NLP"
        description="Nâng cao hiệu suất làm việc và kỹ năng lãnh đạo"
        imageSrc="/corporate-hero.jpg"
        imageAlt="Corporate Training"
        textPosition="center"
      />
    </Section>

    {/* Benefits */}
    <Section>
      <h2 className="text-3xl font-bold text-center mb-12">Lợi ích cho doanh nghiệp</h2>
      <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
        <Card
          title="Tăng hiệu suất làm việc"
          content="NLP giúp nhân viên quản lý thời gian, tập trung và đạt mục tiêu hiệu quả hơn"
          imageSrc="/productivity.jpg"
          imageAlt="Productivity"
          imagePosition="background"
          overlay={true}
          className="text-white"
        />
        <Card
          title="Cải thiện giao tiếp"
          content="Kỹ năng giao tiếp và thuyết phục tốt hơn trong môi trường công việc"
          imageSrc="/communication.jpg"
          imageAlt="Communication"
          imagePosition="background"
          overlay={true}
          className="text-white"
        />
        <Card
          title="Phát triển lãnh đạo"
          content="Đào tạo kỹ năng lãnh đạo và quản lý đội nhóm hiệu quả"
          imageSrc="/leadership.jpg"
          imageAlt="Leadership"
          imagePosition="background"
          overlay={true}
          className="text-white"
        />
        <Card
          title="Giảm stress công việc"
          content="Kỹ thuật quản lý cảm xúc và stress trong môi trường làm việc"
          imageSrc="/stress-management.jpg"
          imageAlt="Stress Management"
          imagePosition="background"
          overlay={true}
          className="text-white"
        />
      </div>
    </Section>

    {/* CTA */}
    <Section backgroundColor="dark" className="text-white text-center">
      <h2 className="text-3xl font-bold mb-4">
        Sẵn sàng đầu tư vào đội nhóm của bạn?
      </h2>
      <p className="text-xl mb-8 max-w-2xl mx-auto">
        Liên hệ với chúng tôi để được tư vấn chương trình đào tạo 
        phù hợp với doanh nghiệp của bạn
      </p>
      <div className="flex flex-col sm:flex-row gap-4 justify-center">
        <button className="bg-blue-600 hover:bg-blue-700 text-white px-8 py-3 rounded-lg font-semibold transition-colors">
          Nhận tư vấn miễn phí
        </button>
        <button className="border-2 border-white text-white hover:bg-white hover:text-gray-900 px-8 py-3 rounded-lg font-semibold transition-colors">
          Tải brochure
        </button>
      </div>
    </Section>
  </div>
);

export default {
  HomepageExample,
  AboutPageExample,
  ContactPageExample,
  CoursesPageExample,
  BlogPageExample,
  CorporatePageExample,
};
