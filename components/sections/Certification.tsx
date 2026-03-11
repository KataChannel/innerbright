import { getAssetUrl } from '@/utils/asset';
export default function Certification() {
  return (
    <div id="acn">
      <svg className="aco">
        <rect id="aco" rx="0" ry="0" x="0" y="0" width="1920" height="1195">
        </rect>
      </svg>
      <div id="acp">
        <span>InnerBright Training & Coaching tự hào là thành viên chính thức và uy <br />tín của Hiệp Hội NLP Hoa Kỳ (ABNLP) trong hơn 5 năm liên tục. ABNLP <br />với vai trò là tổ chức lớn nhất và lâu đời nhất về Lập Trình Ngôn Ngữ Tư <br />Duy (NLP - Neuro Linguistic Programming) tại Hoa Kỳ, có chứng nhận sự <br />chuyên nghiệp và chất lượng đào tạo của InnerBright.<br /><br />Đặc biệt, InnerBright là đơn vị tiên phong tại Việt Nam được Ban Cố Vấn <br />(Board of Advisors) của Hiệp Hội ABNLP chứng thực bằng chương trình <br />NLP Master Coach Quốc Tế. Điều này đảm bảo rằng không chỉ về kiến <br />thức chuyên môn, mà còn về đạo đức nghề nghiệp, InnerBright mang <br />đến chương trình đào tạo NLP Coaching chuẩn quốc tế tại Việt Nam.</span>
      </div>
      <div id="acq">
        <img id="acr" src={getAssetUrl("/acr.png")} srcSet={`${getAssetUrl("/acr.png")} 1x, ${getAssetUrl("/acr@2x.png")} 2x`} alt="Certification Logo" />
      </div>
      <div id="acs">
        <span>CHỨNG NHẬN</span>
      </div>
      <div id="act">
        <span>HỆ THỐNG CHỨNG NHẬN</span>
      </div>
      <div id="acu">
        <div id="acv">
          <div id="acw">
            <div id="acx">
              <img id="acy" src={getAssetUrl("/acy.png")} srcSet={`${getAssetUrl("/acy.png")} 1x, ${getAssetUrl("/acy@2x.png")} 2x`} alt="Diploma" />
            </div>
          </div>
          <svg className="acz" viewBox="897.157 11.451 634.339 408.197">
            <path id="acz" d="M 1498.978637695312 419.6475524902344 L 929.6748657226562 419.6475524902344 C 911.71533203125 419.6475524902344 897.156982421875 405.0884094238281 897.156982421875 387.1297302246094 L 897.156982421875 43.96966934204102 C 897.156982421875 26.01017379760742 911.71533203125 11.45100021362305 929.6748657226562 11.45100021362305 L 1498.978637695312 11.45100021362305 C 1516.938110351562 11.45100021362305 1531.496459960938 26.01017379760742 1531.496459960938 43.96966934204102 L 1531.496459960938 387.1297302246094 C 1531.496459960938 405.0884094238281 1516.938110351562 419.6475524902344 1498.978637695312 419.6475524902344">
            </path>
          </svg>
          <div id="ada">
            <img id="adb" src={getAssetUrl("/adb.png")} srcSet={`${getAssetUrl("/adb.png")} 1x, ${getAssetUrl("/adb@2x.png")} 2x`} alt="Certification Seal" />
          </div>
        </div>
        <div id="adc">
          <img id="add" src={getAssetUrl("/add.png")} srcSet={`${getAssetUrl("/add.png")} 1x, ${getAssetUrl("/add@2x.png")} 2x`} alt="Dot" />
        </div>
      </div>
      <div id="ade">
        <div id="ade_inner_wrap">
          <div id="adf">
            <img id="adg" src={getAssetUrl("/adg.png")} srcSet={`${getAssetUrl("/adg.png")} 1x, ${getAssetUrl("/adg@2x.png")} 2x`} alt="Dot" />
          </div>
          <div id="adh">
            <div id="adi">
              <div id="adj">
                <img id="adk" src={getAssetUrl("/adk.png")} srcSet={`${getAssetUrl("/adk.png")} 1x, ${getAssetUrl("/adk@2x.png")} 2x`} alt="Diploma" />
              </div>
            </div>
            <div id="adl">
              <svg className="adm" viewBox="4.969 11.451 634.339 408.197">
                <path id="adm" d="M 606.79052734375 419.6475524902344 L 37.48685073852539 419.6475524902344 C 19.5273551940918 419.6475524902344 4.968999862670898 405.0884094238281 4.968999862670898 387.1297302246094 L 4.968999862670898 43.96966934204102 C 4.968999862670898 26.01017379760742 19.5273551940918 11.45100021362305 37.48685073852539 11.45100021362305 L 606.79052734375 11.45100021362305 C 624.7500610351562 11.45100021362305 639.308349609375 26.01017379760742 639.308349609375 43.96966934204102 L 639.308349609375 387.1297302246094 C 639.308349609375 405.0884094238281 624.7500610351562 419.6475524902344 606.79052734375 419.6475524902344">
                </path>
              </svg>
              <div id="adn">
                <img id="ado" src={getAssetUrl("/ado.png")} srcSet={`${getAssetUrl("/ado.png")} 1x, ${getAssetUrl("/ado@2x.png")} 2x`} alt="Certification Seal" />
              </div>
            </div>
          </div>
        </div>
      </div>
      <div id="adp">
        <span>HỌC VIỆN ĐÀO TẠO NLP</span>
      </div>
      <div id="adq">
        <span>HỌC VIỆN ĐÀO TẠO NLP COACHING</span>
      </div>
    </div>
  );
}
