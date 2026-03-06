import Link from 'next/link';

export default function Header() {
  return (
    <>
      <div id="aab">
        <img id="aac" src="/aac.png" srcSet="/aac.png 1x, /aac@2x.png 2x" alt="Header Background" />
      </div>
      <div id="aad">
        <img id="aae" src="/aae.png" srcSet="/aae.png 1x, /aae@2x.png 2x" alt="User Icon" />
      </div>
      <div id="aaf" style={{ cursor: 'pointer' }} className="relative z-50">
        <Link href="/">
          <img id="aag" src="/aag.png" srcSet="/aag.png 1x, /aag@2x.png 2x" alt="Logo Section" />
        </Link>
      </div>
      <svg className="aah" viewBox="163.359 104.418 1339.799 49.335">
        <path id="aah" d="M 1493.431884765625 153.7531127929688 L 173.0869903564453 153.7531127929688 C 167.7145843505859 153.7531127929688 163.3589935302734 148.8037719726562 163.3589935302734 142.70068359375 L 163.3589935302734 115.4704513549805 C 163.3589935302734 109.3673477172852 167.7145843505859 104.4180068969727 173.0869903564453 104.4180068969727 L 1493.431884765625 104.4180068969727 C 1498.804321289062 104.4180068969727 1503.158081054688 109.3673477172852 1503.158081054688 115.4704513549805 L 1503.158081054688 142.70068359375 C 1503.158081054688 148.8037719726562 1498.804321289062 153.7531127929688 1493.431884765625 153.7531127929688">
        </path>
      </svg>
      <svg className="aai">
        <rect id="aai" rx="0" ry="0" x="0" y="0" width="1339.801" height="49.328">
        </rect>
      </svg>
      <div id="aaj">
        <span>V</span>
      </div>
      <div id="aak" style={{ cursor: 'pointer' }} className="relative z-50">
        <Link href="/nlp" className="block w-full h-full">
          <span>NLP</span>
        </Link>
      </div>
      <div id="aal">
        <div id="aam">
          <span>Time Line </span>
        </div>
        <div id="aan">
          <span>Therapy</span>
        </div>
        <div id="aao">
          <span>®</span>
        </div>
      </div>
      <div id="aap">
        <span>Đào tạo doanh nghiệp</span>
      </div>
      <div id="aaq">
        <span>Khai vấn cá nhân</span>
      </div>
      <div id="aar" style={{ cursor: 'pointer' }} className="relative z-50">
        <Link href="/bothenlp" className="block w-full h-full">
          <span>Bộ thẻ NLP</span>
        </Link>
      </div>
      <div id="aas">
        <span>Thư viện</span>
      </div>
      <div id="aat">
        <span>Liên hệ</span>
      </div>
      <div id="aau">
        <img id="aav" src="/aav.png" srcSet="/aav.png 1x, /aav@2x.png 2x" alt="Search Bar Background" />
      </div>
      <div id="aaw">
        <span>Khoá học</span>
      </div>
      <div id="aax" style={{ cursor: 'pointer' }} className="relative z-50">
        <Link href="/" className="block w-full h-full">
          <span>Về InnerBright</span>
        </Link>
      </div>
    </>
  );
}
