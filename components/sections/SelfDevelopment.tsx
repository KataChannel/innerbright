import { getAssetUrl } from '@/utils/asset';
export default function SelfDevelopment() {
  return (
    <div id="acb">
      <div id="acc" className="reveal-hidden hover-premium">
        <img id="acd" src={getAssetUrl("/acd.png")} srcSet={`${getAssetUrl("/acd.png")} 1x, ${getAssetUrl("/acd@2x.png")} 2x`} alt="Self Development Banner" />
      </div>
      <div id="ace">
        <div id="acf">
          <span>PHÁT TRIỂN BẢN THÂN</span>
        </div>
        <div id="acg">
          <span>LÀ SỨC MẠNH ĐỂ THAY ĐỔI THẾ GIỚI</span>
        </div>
        <svg className="ach" viewBox="2.484 59.536 536.239 1">
          <path id="ach" d="M 2.484000205993652 59.5359992980957 L 538.7229614257812 59.5359992980957 L 2.484000205993652 59.5359992980957 Z">
          </path>
        </svg>
        <svg className="aci" viewBox="0 0 530 1">
          <path id="aci" d="M 0 0 L 530 0">
          </path>
        </svg>
      </div>
      <div id="acj" className="reveal-hidden" style={{ transitionDelay: "0.2s" }}>
        <span>Thế giới của mỗi người chính là bề sinh trắc, nơi mỗi chúng ta sống và  làm việc cùng các cộng đồng. Tại InnerBright, điều quan trọng không  chỉ là được thành công cá nhân, mà còn là sử dụng sức mạnh này để  tạo ra sự khác biệt và ảnh hưởng đến hệ sinh thái của riêng bạn. Bằng  cách phát triển bản thân, chúng ta tự trở thành người cầm trịch và sẽ  thay đổi cả thế giới.</span>
      </div>
      <div id="ack" className="reveal-hidden" style={{ transitionDelay: "0.4s" }}>
        <span>Chúng tôi - những con người tại InnerBright rất tự hào và sẵn sàng đồng hành cùng bạn trên hành trình này để khai phóng tiềm năng và giúp phát huy tối đa nội lực của riêng Bạn</span>
      </div>
      <div id="acl" className="float-animation">
        <img id="acm" src={getAssetUrl("/acm.png")} srcSet={`${getAssetUrl("/acm.png")} 1x, ${getAssetUrl("/acm@2x.png")} 2x`} alt="Bottom Image" />
      </div>
    </div>
  );
}
