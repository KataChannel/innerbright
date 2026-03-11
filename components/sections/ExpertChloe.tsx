import { getAssetUrl } from '@/utils/asset';
export default function ExpertChloe() {
  return (
    <div id="ahi">
      <svg className="ahj">
        <rect id="ahj" rx="0" ry="0" x="0" y="0" width="1920" height="915">
        </rect>
      </svg>
      <div id="ahk" className="reveal-hidden" style={{ transitionDelay: "0.2s" }}>
        <span>Trong quá trình học tập và huấn luyện tại Việt Nam, </span><span style={{ letterSpacing: '-0.05px' }}>Chloe Quý Châu là chuyên gia nguyên vật liệu, kiến</span><span> trúc ABNLP Coaching Division cấp phép đào tạo NLP  </span><span style={{ letterSpacing: '0.1px' }}>Master Coach. Chloe tập trung truyền tải nguyên bản công cụ NLP để học viên hiểu rõ, đúng, đủ và</span><span> ứng dụng linh hoạt vào cuộc sống.<br /></span><br /><span style={{ letterSpacing: '0.1px' }}>Chloe cũng là một trong số ít người Việt đầu tiên</span><span> được chứng nhận đào tạo </span><span style={{ fontStyle: 'normal', fontWeight: 'bold' }}>Time Line Therapy®</span><span> trực tiếp từ hiệp hội, một phương pháp mạnh mẽ giúp xử lý sâu sắc các cảm xúc tiêu cực và niềm tin giới hạn.</span>
      </div>
      <div id="ahl" className="reveal-hidden hover-premium">
        <img id="ahm" src={getAssetUrl("/ahm.png")} srcSet={`${getAssetUrl("/ahm.png")} 1x, ${getAssetUrl("/ahm@2x.png")} 2x`} alt="Chloe Portrait" />
      </div>
      <div id="ahn">
        <div id="aho">
          <img id="ahp" src={getAssetUrl("/ahp.png")} srcSet={`${getAssetUrl("/ahp.png")} 1x, ${getAssetUrl("/ahp@2x.png")} 2x`} alt="Certification" />
        </div>
        <div id="ahq">
          <span>•</span>
        </div>
        <div id="ahr">
          <span>NLP Coach </span><span style={{ letterSpacing: '-0.74px' }}>T</span><span>rainer</span>
        </div>
        <div id="ahs">
          <span>•</span>
        </div>
        <div id="aht">
          <span>ABNLP I Time Line Therapy</span>
        </div>
        <div id="ahu">
          <span>®</span>
        </div>
        <div id="ahv">
          <img id="ahw" src={getAssetUrl("/ahw.png")} srcSet={`${getAssetUrl("/ahw.png")} 1x, ${getAssetUrl("/ahw@2x.png")} 2x`} alt="Logo" />
        </div>
      </div>
    </div>
  );
}
