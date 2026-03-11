'use client';
import { getAssetUrl } from '@/utils/asset';

import './NLP.css';
import ScaleWrapper from '@/components/sections/ScaleWrapper';
import Link from 'next/link';
import ScrollReveal from '@/components/ScrollReveal';

export default function NLPPage() {
	return (
		<ScaleWrapper height={11386}>
			<ScrollReveal />

			<div id="NLP">
				<svg className="aac">
					<rect id="aac" rx="0" ry="0" x="0" y="0" width="1920" height="691" />

				</svg>
				<svg className="aad">
					<rect id="aad" rx="0" ry="0" x="0" y="0" width="1920" height="258" />

				</svg>
				<div id="aae" className="float-animation">
					<img id="aaf" src={getAssetUrl("/images/nlp/aaf.png")} srcSet={`${getAssetUrl("/images/nlp/aaf.png")} 1x, ${getAssetUrl("/images/nlp/aaf@2x.png")} 2x`} />
				</div>
				<div id="aag" style={{ cursor: "pointer" }} className="relative z-50 hover-premium">
					<Link href="/" className="block w-full h-full">
						<img id="aah" src={getAssetUrl("/images/nlp/aah.png")} srcSet={`${getAssetUrl("/images/nlp/aah.png")} 1x, ${getAssetUrl("/images/nlp/aah@2x.png")} 2x`} />
					</Link>
				</div>
				<div id="aai" className="float-animation" style={{ animationDelay: "1s" }}>
					<img id="aaj" src={getAssetUrl("/images/nlp/aaj.png")} srcSet={`${getAssetUrl("/images/nlp/aaj.png")} 1x, ${getAssetUrl("/images/nlp/aaj@2x.png")} 2x`} />
				</div>
				<svg className="aak" viewBox="163.359 104.418 1339.799 49.335">
					<path id="aak" d="M 1493.431884765625 153.7531127929688 L 173.0869903564453 153.7531127929688 C 167.7145843505859 153.7531127929688 163.3589935302734 148.8037719726562 163.3589935302734 142.70068359375 L 163.3589935302734 115.4704513549805 C 163.3589935302734 109.3673477172852 167.7145843505859 104.4180068969727 173.0869903564453 104.4180068969727 L 1493.431884765625 104.4180068969727 C 1498.804321289062 104.4180068969727 1503.158081054688 109.3673477172852 1503.158081054688 115.4704513549805 L 1503.158081054688 142.70068359375 C 1503.158081054688 148.8037719726562 1498.804321289062 153.7531127929688 1493.431884765625 153.7531127929688" />

				</svg>
				<svg className="aal">
					<rect id="aal" rx="0" ry="0" x="0" y="0" width="1339.801" height="49.328" />

				</svg>
				<div id="aam" style={{ cursor: "pointer" }} className="relative z-50">
					<Link href="/" className="block w-full h-full">
						<div id="aan">
							<span>Time Line </span>
						</div>
						<div id="aao">
							<span>Therapy</span>
						</div>
						<div id="aap">
							<span>®</span>
						</div>
					</Link>
				</div>
				<div id="aaq">
					<span>Đào tạo doanh nghiệp</span>
				</div>
				<div id="aar">
					<span>Khai vấn cá nhân</span>
				</div>
				<div id="aas" style={{ cursor: "pointer" }} className="relative z-50">
					<Link href="/bothenlp"><span>Bộ thẻ NLP</span></Link>
				</div>
				<div id="aat">
					<span>Thư viện</span>
				</div>
				<div id="aau">
					<span>Liên hệ</span>
				</div>
				<svg className="aav" viewBox="163.171 104.421 72.035 49.335">
					<path id="aav" d="M 231.3236389160156 153.756103515625 L 172.202392578125 153.756103515625 C 164.7277679443359 153.756103515625 163.1710205078125 147.3352355957031 163.1710205078125 142.7119750976562 L 163.1710205078125 114.2422561645508 C 163.1710205078125 109.5578079223633 166.0271759033203 104.4209976196289 172.202392578125 104.4209976196289 L 225.17529296875 104.4209976196289 C 232.2004547119141 104.4209976196289 235.2061157226562 109.5578079223633 235.2061157226562 114.2422561645508 L 235.2061157226562 142.7119750976562 C 235.2061157226562 147.3963928222656 232.1002349853516 153.756103515625 225.17529296875 153.756103515625" />

				</svg>
				<div id="aaw">
					<span>Khoá học</span>
				</div>
				<div id="aax" style={{ cursor: "pointer" }} className="relative z-50">
					<Link href="/" className="block w-full h-full">
						<span>Về InnerBright</span>
					</Link>
				</div>
				<div id="aay">
					<div id="aaz">
						<img id="aba" src={getAssetUrl("/images/nlp/aba.png")} srcSet={`${getAssetUrl("/images/nlp/aba.png")} 1x, ${getAssetUrl("/images/nlp/aba@2x.png")} 2x`} />
					</div>
					<div id="abb" style={{ cursor: 'pointer' }} onClick={() => window.scrollTo({ top: 0, behavior: 'smooth' })} className="relative z-50">
						<span>Trở lại đầu trang</span>
					</div>
				</div>
				<div id="abc" style={{ cursor: "pointer" }} className="relative z-50">
					<Link href="/nlp" className="block w-full h-full">
						<span>NLP</span>
					</Link>
				</div>
				<svg className="abd">
					<rect id="abd" rx="20" ry="20" x="0" y="0" width="1407" height="233" />

				</svg>
				<div id="abe">
					<span>NLP được khởi nguồn tại Mỹ, bởi </span><span style={{ fontStyle: 'normal', fontWeight: 'bold' }}>John Grinder</span><span> (nhà ngôn ngữ học) và </span><span style={{ fontStyle: 'normal', fontWeight: 'bold' }}>Richard Bandler</span><span> (nhà toán học và liệu pháp tâm lý Gestalt) với mục đích tạo ra các mô hình học tập rõ ràng về sự xuất sắc của con người.</span>
				</div>
				<div id="abf">
					<span>Vậy phương pháp NLP là gì?</span>
				</div>
				<svg className="abg">
					<rect id="abg" rx="0" ry="0" x="0" y="0" width="1920" height="1646" />

				</svg>
				<svg className="abh">
					<rect id="abh" rx="0" ry="0" x="0" y="0" width="1920" height="368" />

				</svg>
				<div id="abi">
					<span>3 CÂU HỎI MUÔN THUỞ</span>
				</div>
				<div id="abj">
					<span>Bạn chính là tác giả của cuộc đời mình, là đạo diễn của vở kịch mang tên “Cuộc sống” mà bạn đóng vai chính. Mỗi người sinh ra đều sở hữu tiềm năng to lớn bên trong để kiến tạo cuộc sống như mong muốn.</span>
				</div>
				<div id="abk">
					<span>Mỗi ngày, chúng ta đều trăn trở về những câu hỏi sâu sắc về cuộc sống:</span>
				</div>
				<div id="abl">
					<svg className="abm">
						<rect id="abm" rx="20" ry="20" x="0" y="0" width="419" height="139" />

					</svg>
					<div id="abn">
						<span>1</span>
					</div>
					<div id="abo">
						<span>Tại sao tôi trở thành con người mà tôi đang là?</span>
					</div>
				</div>
				<div id="abp">
					<svg className="abq">
						<rect id="abq" rx="20" ry="20" x="0" y="0" width="419" height="139" />

					</svg>
					<div id="abr">
						<span>2</span>
					</div>
					<div id="abs">
						<span>Tôi thực sự mong muốn điều gì trong cuộc đời?</span>
					</div>
				</div>
				<div id="abt">
					<svg className="abu">
						<rect id="abu" rx="20" ry="20" x="0" y="0" width="419" height="139" />

					</svg>
					<div id="abv">
						<span>3</span>
					</div>
					<div id="abw">
						<span>Làm thế nào để tôi vượt qua những rào cản và đạt được điều mình mong muốn?</span>
					</div>
				</div>
				<div id="abx">
					<span>CHÌA KHOÁ MỞ RA<br />CÁNH CỬA CUỘC SỐNG VƯỢT TRỘI</span>
				</div>
				<div id="aby">
					<span>Lập Trình Ngôn Ngữ Tư Duy NLP (Neuro Linguistic Programming) là chìa khóa giúp khai phá sức mạnh của bản thân. Các nhà khoa học đã công nhận tầm quan trọng của phương pháp NLP. Nếu hiểu rõ về NLP, bạn sẽ có cơ hội phát triển bản thân lên tầm cao mới.</span>
				</div>
				<svg className="abz" viewBox="0 0 1404.5 3">
					<path id="abz" d="M 0 3 L 1404.499877929688 0" />

				</svg>
				<svg className="aca" viewBox="0 0 1440 608">
					<path id="aca" d="M 0 0 L 1440 0 L 1440 608 L 0 608 L 0 0 Z" />

				</svg>
				<img id="acb" src={getAssetUrl("/images/nlp/acb.png")} srcSet={`${getAssetUrl("/images/nlp/acb.png")} 1x, ${getAssetUrl("/images/nlp/acb@2x.png")} 2x`} />

				<div id="acc">
					<span>Nhưng bạn sẽ không nằm<br />trong số đó!</span>
				</div>
				<div id="acd">
					<span>NLP - Nguồn lực mạnh mẽ giúp bạn làm chủ cuộc đời</span>
				</div>
				<div id="ace">
					<span>Một trong những nguồn lực tuyệt vời nhất mà mỗi người sở hữu chính là khả năng học cách làm chủ tâm trí và hiện diện - sống trọn vẹn với thực tại. Cách chúng ta phản ứng với cuộc sống, những suy nghĩ, cảm xúc, hành động, niềm tin và giá trị theo đuổi đóng vai trò vô cùng quan trọng, tác động trực tiếp đến mọi kết quả trong cuộc đời. Và NLP chính là công cụ giúp bạn làm chủ những yếu tố then chốt này.</span>
				</div>
				<div id="acf">
					<span>NLP dựa trên cơ sở bộ não của chúng ta có thể được tái cấu trúc để biến chúng ta thành những thực thể mới.<br />Hay nói cách khác, bộ não là hệ điều hành của cuộc sống. NLP giúp thay đổi cách chúng ta nghĩ về bản thân,<br />về người khác, về thế giới và thay thế bằng những điều hữu ích cho cuộc sống.<br /><br />NLP giúp tái cấu trúc những chương trình chạy ngầm bên trong, từ đó thay đổi tư duy và hành vi<br />để đạt được hiệu quả.</span>
				</div>
				<div id="acg">
					<span>Một cách đơn giản, thuật ngữ “Lập trình ngôn ngữ tư duy” đề cập đến những chương trình chạy ngầm trong tiềm thức, dẫn dắt hành vi và tạo ra kết quả trong cuộc sống của chúng ta.</span>
				</div>
				<div id="ach">
					<span>NLP là gì?</span>
				</div>
				<svg className="aci">
					<rect id="aci" rx="20" ry="20" x="0" y="0" width="1407" height="316" />

				</svg>
				<svg className="acj">
					<rect id="acj" rx="20" ry="20" x="0" y="0" width="1407" height="316" />

				</svg>
				<svg className="ack">
					<rect id="ack" rx="20" ry="20" x="0" y="0" width="1407" height="316" />

				</svg>
				<div id="acl">
					<span>1. Neuro - Tư duy</span>
				</div>
				<div id="acm">
					<span>2. Linguistic - Ngôn ngữ</span>
				</div>
				<div id="acn">
					<span>3. Programming - Lập trình</span>
				</div>
				<div id="aco">
					<span>Hệ thống nơ-ron bộ và mạng lưới thần kinh sinh tồn. Trong con người có trung bình dao động từ 80 đến 100 tỷ nơ-ron và 100 tỷ tế bào nơ-ron thần kinh, hoạt động chính của nó là giúp chúng ta có thể tiếp nhận, xử lý thông tin. Sau đó bộ não sẽ tạo ra các thiết lập và hệ thống phản hồi làm việc một cách hiệu quả hơn trong cuộc sống.</span>
				</div>
				<div id="acp">
					<span>Cách chúng ta sử dụng ngôn từ không chỉ đơn thuần diễn đạt ý định của chúng ta mà còn thể hiện niềm tin và thái độ của mỗi người. Một lời nói có thể mang năng lượng tích cực, có thể mang năng lượng tiêu cực, tác động mạnh mẽ đến tư duy và hành vi.</span>
				</div>
				<div id="acq">
					<span>Tương tự như hệ điều hành máy tính, lập trình ngôn ngữ tư duy là dòng hóa các phản ứng thông tin và hành vi. Nó là một tập hợp các nguyên tắc giúp điều chỉnh các kiểu hành vi không mong muốn, đồng thời tối ưu hóa các chương trình tư duy và hành vi để đạt được hiệu quả hơn.</span>
				</div>
				<img id="acr" src={getAssetUrl("/images/nlp/acr.png")} srcSet={`${getAssetUrl("/images/nlp/acr.png")} 1x, ${getAssetUrl("/images/nlp/acr@2x.png")} 2x`} />

				<img id="acs" src={getAssetUrl("/images/nlp/acs.png")} srcSet={`${getAssetUrl("/images/nlp/acs.png")} 1x, ${getAssetUrl("/images/nlp/acs@2x.png")} 2x`} />

				<img id="act" src={getAssetUrl("/images/nlp/act.png")} srcSet={`${getAssetUrl("/images/nlp/act.png")} 1x, ${getAssetUrl("/images/nlp/act@2x.png")} 2x`} />

				<div id="acu">
					<span>NLP - Tái cấu trúc hệ điều hành cuộc đời bạn</span>
				</div>
				<svg className="acv" viewBox="0 0 1920 857.022">
					<path id="acv" d="M 0 0 L 1920.000122070312 0 L 1920.000122070312 857.0215454101562 L 0 857.0215454101562 L 0 0 Z" />

				</svg>
				<img id="acw" src={getAssetUrl("/images/nlp/acw.png")} srcSet={`${getAssetUrl("/images/nlp/acw.png")} 1x, ${getAssetUrl("/images/nlp/acw@2x.png")} 2x`} />

				<div id="acx">
					<span>NLP - Hộp công cụ cuộc sống đa năng</span>
				</div>
				<div id="acy">
					<span>NLP là một tập hợp gồm nhiều công cụ và kỹ thuật hữu ích trang bị cho bạn khả năng</span>
				</div>
				<div id="acz">
					<svg className="ada" viewBox="0 0 1920 899.064">
						<path id="ada" d="M 0 0 L 1920.000122070312 0 L 1920.000122070312 899.064453125 L 0 899.064453125 L 0 0 Z" />

					</svg>
					<img id="adb" src={getAssetUrl("/images/nlp/adb.png")} srcSet={`${getAssetUrl("/images/nlp/adb.png")} 1x, ${getAssetUrl("/images/nlp/adb@2x.png")} 2x`} />

					<img id="adc" src={getAssetUrl("/images/nlp/adc.png")} srcSet={`${getAssetUrl("/images/nlp/adc.png")} 1x, ${getAssetUrl("/images/nlp/adc@2x.png")} 2x`} />

					<div id="add">
						<span>Tham gia<br />chương trình đào tạo NLP</span>
					</div>
					<div id="ade">
						<span>Bạn đang tham gia vào hành trình thấu hiểu bản thân, tìm thấy mục tiêu cuộc sống và làm chủ chính mình. Đây cũng là hành trình giúp Bạn chữa lành những tổn thương bên trong từ gốc rễ ở quá khứ.</span>
					</div>
					<div id="adf">
						<span>từ đó giúp kết nối mối quan hệ với bản thân, loại bỏ rào cản hoài nghi năng lực cá nhân, cải thiện khả năng tương tác thấu cảm với người khác; cung cấp cho bạn một loạt các chiến lược gia tăng hiệu suất cá nhân lâu dài, và một hành trình phát triển bản thân đúng đắn và toàn diện.<br /><br />Đến nay, NLP đã phát triển các công cụ và kỹ năng rất mạnh mẽ và tạo thay đổi trong nhiều lĩnh vực chuyên môn bao gồm: tư vấn, tâm lý trị liệu, giáo dục, sức khỏe, sáng tạo, luật, quản lý, bán hàng, lãnh đạo và nuôi dạy con cái.</span>
					</div>
				</div>
				<svg className="adg" viewBox="0 0 1920 1044.179">
					<path id="adg" d="M 0 0 L 1920.000122070312 0 L 1920.000122070312 1044.17919921875 L 0 1044.17919921875 L 0 0 Z" />

				</svg>
				<div id="adh">
					<span>LƯỢC SỬ NLP</span>
				</div>
				<div id="adi">
					<svg className="adj">
						<rect id="adj" rx="36" ry="36" x="0" y="0" width="1407" height="866" />

					</svg>
					<img id="adk" src={getAssetUrl("/images/nlp/adk.png")} srcSet={`${getAssetUrl("/images/nlp/adk.png")} 1x, ${getAssetUrl("/images/nlp/adk@2x.png")} 2x`} />

					<img id="adl" src={getAssetUrl("/images/nlp/adl.png")} srcSet={`${getAssetUrl("/images/nlp/adl.png")} 1x, ${getAssetUrl("/images/nlp/adl@2x.png")} 2x`} />

					<img id="adm" src={getAssetUrl("/images/nlp/adm.png")} srcSet={`${getAssetUrl("/images/nlp/adm.png")} 1x, ${getAssetUrl("/images/nlp/adm@2x.png")} 2x`} />

					<img id="adn" src={getAssetUrl("/images/nlp/adn.png")} srcSet={`${getAssetUrl("/images/nlp/adn.png")} 1x, ${getAssetUrl("/images/nlp/adn@2x.png")} 2x`} />

					<img id="ado" src={getAssetUrl("/images/nlp/ado.png")} srcSet={`${getAssetUrl("/images/nlp/ado.png")} 1x, ${getAssetUrl("/images/nlp/ado@2x.png")} 2x`} />

					<img id="adp" src={getAssetUrl("/images/nlp/adp.png")} srcSet={`${getAssetUrl("/images/nlp/adp.png")} 1x, ${getAssetUrl("/images/nlp/adp@2x.png")} 2x`} />

					<img id="adq" src={getAssetUrl("/images/nlp/adq.png")} srcSet={`${getAssetUrl("/images/nlp/adq.png")} 1x, ${getAssetUrl("/images/nlp/adq@2x.png")} 2x`} />

					<img id="adr" src={getAssetUrl("/images/nlp/adr.png")} srcSet={`${getAssetUrl("/images/nlp/adr.png")} 1x, ${getAssetUrl("/images/nlp/adr@2x.png")} 2x`} />

					<div id="ads">
						<svg className="adt">
							<rect id="adt" rx="34" ry="34" x="0" y="0" width="379" height="68" />

						</svg>
						<svg className="adu">
							<rect id="adu" rx="38" ry="38" x="0" y="0" width="391" height="76" />

						</svg>
						<div id="adv">
							<span>NLP 1970s</span>
						</div>
					</div>
					<div id="adw">
						<svg className="adx" viewBox="42.351 31.98 26.916 32.203">
							<path id="adx" d="M 68.86955261230469 44.90682983398438 L 55.87546920776367 31.97999954223633 L 42.88137817382812 44.90682983398438 C 42.46268463134766 45.22567367553711 42.26837921142578 45.7593994140625 42.38410186767578 46.27279281616211 C 42.49982833862305 46.78618621826172 42.90431976318359 47.18494033813477 43.41931533813477 47.29331588745117 C 43.93431091308594 47.40169906616211 44.4652099609375 47.19978713989258 44.77803421020508 46.77658081054688 L 54.53032302856445 37.10499572753906 L 54.53032302856445 62.83758926391602 C 54.53032302856445 63.58049392700195 55.13256454467773 64.18273162841797 55.87546920776367 64.18273162841797 C 56.61837005615234 64.18273162841797 57.22060775756836 63.58049392700195 57.22060775756836 62.83758926391602 L 57.22060775756836 37.10499572753906 L 66.972900390625 46.77658081054688 C 67.50035858154297 47.30032730102539 68.35253143310547 47.29731750488281 68.87628173828125 46.76985549926758 C 69.4000244140625 46.24239349365234 69.39701080322266 45.39022064208984 68.86955261230469 44.86647796630859 L 68.86955261230469 44.90682983398438 Z" />

						</svg>
					</div>
					<div id="ady">
						<svg className="adz" viewBox="42.351 31.98 26.916 32.203">
							<path id="adz" d="M 68.86955261230469 44.90682983398438 L 55.87546920776367 31.97999954223633 L 42.88137817382812 44.90682983398438 C 42.46268463134766 45.22567367553711 42.26837921142578 45.7593994140625 42.38410186767578 46.27279281616211 C 42.49982833862305 46.78618621826172 42.90431976318359 47.18494033813477 43.41931533813477 47.29331588745117 C 43.93431091308594 47.40169906616211 44.4652099609375 47.19978713989258 44.77803421020508 46.77658081054688 L 54.53032302856445 37.10499572753906 L 54.53032302856445 62.83758926391602 C 54.53032302856445 63.58049392700195 55.13256454467773 64.18273162841797 55.87546920776367 64.18273162841797 C 56.61837005615234 64.18273162841797 57.22060775756836 63.58049392700195 57.22060775756836 62.83758926391602 L 57.22060775756836 37.10499572753906 L 66.972900390625 46.77658081054688 C 67.50035858154297 47.30032730102539 68.35253143310547 47.29731750488281 68.87628173828125 46.76985549926758 C 69.4000244140625 46.24239349365234 69.39701080322266 45.39022064208984 68.86955261230469 44.86647796630859 L 68.86955261230469 44.90682983398438 Z" />

						</svg>
					</div>
					<div id="aea">
						<span>John Grinder</span>
					</div>
					<div id="aeb">
						<span>Fritz Peris</span>
					</div>
					<div id="aec">
						<span>Robert Dilts</span>
					</div>
					<div id="aed">
						<span>NLP University</span>
					</div>
					<div id="aee">
						<span>HỌC TRÒ</span>
					</div>
					<div id="aef">
						<span>HỌC TRÒ</span>
					</div>
					<div id="aeg">
						<span>HỌC TRÒ</span>
					</div>
					<div id="aeh">
						<span>ABNLP &amp; Time Line Therapy</span>
					</div>
					<div id="aei">
						<span>Virginia Satir</span>
					</div>
					<div id="aej">
						<span>Tad James &amp; Adriana James</span>
					</div>
					<div id="aek">
						<span>Milton Erickson</span>
					</div>
					<div id="ael">
						<span>Anthony Robbins</span>
					</div>
					<div id="aem">
						<span>Richard Bandler</span>
					</div>
					<div id="aen">
						<svg className="aeo" viewBox="2946.411 6871 189.63 523.591">
							<path id="aeo" d="M 3136.041259765625 6870.99951171875 L 2946.4111328125 7133.88916015625 L 3136.041259765625 7394.59033203125" />

						</svg>
						<svg className="aep">
							<ellipse id="aep" rx="7.5" ry="7.5" cx="7.5" cy="7.5" />

						</svg>
						<svg className="aeq">
							<ellipse id="aeq" rx="7.5" ry="7.5" cx="7.5" cy="7.5" />

						</svg>
					</div>
					<div id="aer">
						<svg className="aes" viewBox="2833 6881.5 56.221 442.155">
							<path id="aes" d="M 2833 6881.5 L 2889.221435546875 6881.5 L 2889.221435546875 7323.65478515625 L 2833 7323.65478515625" />

						</svg>
						<svg className="aet" viewBox="2833.126 7104.5 68.096 1">
							<path id="aet" d="M 2901.221435546875 7104.5 L 2833.125732421875 7104.5" />

						</svg>
						<svg className="aeu" viewBox="0 0 12 13">
							<path id="aeu" d="M 6 0 L 12 13 L 0 13 Z" />

						</svg>
						<svg className="aev" viewBox="0 0 12 13">
							<path id="aev" d="M 6 0 L 12 13 L 0 13 Z" />

						</svg>
						<svg className="aew" viewBox="0 0 12 13">
							<path id="aew" d="M 6 0 L 12 13 L 0 13 Z" />

						</svg>
					</div>
					<div id="aex">
						<svg className="aey" viewBox="2833 6881.5 112.015 554.862">
							<path id="aey" d="M 2832.999755859375 6881.5 L 2945.01513671875 6881.5 L 2945.01513671875 7436.3623046875 L 2832.999755859375 7436.3623046875" />

						</svg>
						<svg className="aez" viewBox="0 0 12 13">
							<path id="aez" d="M 6 0 L 12 13 L 0 13 Z" />

						</svg>
						<svg className="afa" viewBox="0 0 12 13">
							<path id="afa" d="M 6 0 L 12 13 L 0 13 Z" />

						</svg>
					</div>
					<svg className="afb" viewBox="3508.569 7406.5 144.085 1">
						<path id="afb" d="M 3652.653564453125 7406.5 L 3508.568603515625 7406.5" />

					</svg>
					<svg className="afc" viewBox="3508.569 7406.5 144.085 1">
						<path id="afc" d="M 3652.653564453125 7406.5 L 3508.568603515625 7406.5" />

					</svg>
					<svg className="afd" viewBox="3508.569 7406.5 144.085 1">
						<path id="afd" d="M 3652.653564453125 7406.5 L 3508.568603515625 7406.5" />

					</svg>
					<svg className="afe">
						<ellipse id="afe" rx="6.5" ry="6.5" cx="6.5" cy="6.5" />

					</svg>
					<svg className="aff">
						<ellipse id="aff" rx="6.5" ry="6.5" cx="6.5" cy="6.5" />

					</svg>
					<svg className="afg">
						<ellipse id="afg" rx="6.5" ry="6.5" cx="6.5" cy="6.5" />

					</svg>
					<div id="afh">
						<span>Học tập &amp; nghiên cứu</span>
					</div>
					<div id="afi">
						<span>Học tập &amp; nghiên cứu</span>
					</div>
				</div>
				<svg className="afj" viewBox="0 0 1920 396.091">
					<path id="afj" d="M 0 0 L 1920.000122070312 0 L 1920.000122070312 396.0908203125 L 0 396.0908203125 L 0 0 Z" />

				</svg>
				<div id="afk">
					<svg className="afl" viewBox="5 7 49.105 35.073">
						<path id="afl" d="M 8.50688362121582 42.07290267944336 L 19.02855110168457 42.07290267944336 L 26.04638481140137 28.04435729980469 L 26.04638481140137 7 L 4.999999523162842 7 L 4.999999523162842 28.04333877563477 L 15.52166938781738 28.04333877563477 L 8.50688362121582 42.07290267944336 Z M 36.56500244140625 42.07290267944336 L 47.08667373657227 42.07290267944336 L 54.10450744628906 28.04435729980469 L 54.10450744628906 7 L 33.05812072753906 7 L 33.05812072753906 28.04333877563477 L 43.57978820800781 28.04333877563477 L 36.56500244140625 42.07290267944336 Z" />

					</svg>
					<svg className="afm" viewBox="0 0 84.173 84.173">
						<path id="afm" d="M 0 0 L 84.17333984375 0 L 84.17333984375 84.17333984375 L 0 84.17333984375 L 0 0 Z" />

					</svg>
				</div>
				<div id="afn">
					<svg className="afo" viewBox="0 0 64.373 45.979">
						<path id="afo" d="M 4.597333908081055 45.97866439819336 L 18.39066505432129 45.97866439819336 L 27.59066390991211 27.58800315856934 L 27.59066390991211 0 L 0 0 L 0 27.58666801452637 L 13.79333400726318 27.58666801452637 L 4.597333908081055 45.97866439819336 Z M 41.38000106811523 45.97866439819336 L 55.17333984375 45.97866439819336 L 64.37333679199219 27.58800315856934 L 64.37333679199219 0 L 36.78266906738281 0 L 36.78266906738281 27.58666801452637 L 50.57600021362305 27.58666801452637 L 41.38000106811523 45.97866439819336 Z" />

					</svg>
					<svg className="afp" viewBox="0 0 110.347 110.347">
						<path id="afp" d="M 0 0 L 110.3466644287109 0 L 110.3466644287109 110.3466644287109 L 0 110.3466644287109 L 0 0 Z" />

					</svg>
				</div>
				<div id="afq">
					<span style={{ textTransform: 'uppercase' }}>Câu chuyện về NLP </span><span style={{ fontStyle: 'normal', fontWeight: 'lighter', fontSize: '34px' }}>Lập Trình Ngôn Ngữ Tư Duy bắt đầu</span>
				</div>
				<div id="afr">
					<span>NLP - Hộp công cụ cuộc sống đa năng</span>
				</div>
				<div id="afs">
					<span>từ niềm đam mê mãnh liệt của hai nhà nghiên cứu tiên phong: Richard Bandler và John Grinder. Họ trăn trở về một câu hỏi mang tính then chốt: “Yếu tố nào tạo nên sự khác biệt giữa một cá nhân bình thường và một cá nhân xuất sắc trong cùng một lĩnh vực?”. Khao khát tìm kiếm câu trả lời đã thôi thúc họ dấn thân vào hành trình nghiên cứu đầy say mê về cách con người sử dụng ngôn ngữ để phản ánh và ảnh hưởng đến tư duy của chính họ.</span>
				</div>
				<svg className="aft" viewBox="0 0 1920 1025.951">
					<path id="aft" d="M 0 0 L 1920 0 L 1920 1025.951171875 L 0 1025.951171875 L 0 0 Z" />

				</svg>
				<svg className="afu" viewBox="0 0 486.667 788.914">
					<path id="afu" d="M 0 0 L 486.6666870117188 0 L 486.6666870117188 788.9140625 L 0 788.9140625 L 0 0 Z" />

				</svg>
				<div id="afv">
					<span>Là một bác sĩ tâm thần, nhà trị liệu thôi miên rất thành công. NLP dựa trên cách mà Milton Erickson sử dụng ngôn ngữ thôi miên trị liệu để tạo nên các mẫu ngôn ngữ mang tên Mô hình Milton. Bất kể bạn đang ở bất cảnh nào, vai trò của bạn là gì thì những mẫu ngôn ngữ này sẽ giúp cho bạn có thể gia tăng khả năng giao tiếp với tầng tiềm thức của người nghe, thúc đẩy động lực, gây sự ảnh hưởng và tạo ra sự thay đổi lâu dài mang tính tích cực.</span>
				</div>
				<img id="afw" src={getAssetUrl("/images/nlp/afw.png")} srcSet={`${getAssetUrl("/images/nlp/afw.png")} 1x, ${getAssetUrl("/images/nlp/afw@2x.png")} 2x`} />

				<div id="afx">
					<span>Milton Erickson</span>
				</div>
				<div id="afy">
					<span>(1901-80)</span>
				</div>
				<svg className="afz" viewBox="0 0 486.667 786.248">
					<path id="afz" d="M 0 0 L 486.6666870117188 0 L 486.6666870117188 786.248046875 L 0 786.248046875 L 0 0 Z" />

				</svg>
				<div id="aga">
					<span>Là một bác sĩ phẫu thuật thần kinh người Đức và nhà phân tâm học gốc Do Thái. Ông cũng là người người sáng lập ra liệu pháp Gestalt. Ông được đóng góp phát triển thành một công cụ trị liệu để phân tích tâm lý.</span>
				</div>
				<div id="agb">
					<span>Fritz Perls</span>
				</div>
				<div id="agc">
					<span>(1893-70)</span>
				</div>
				<svg className="agd" viewBox="0 0 486.667 786.248">
					<path id="agd" d="M 0 0 L 486.6666870117188 0 L 486.6666870117188 786.248046875 L 0 786.248046875 L 0 0 Z" />

				</svg>
				<div id="age">
					<span>Được xem là bậc thầy về Liệu pháp gia đình. Virginia Satir tin rằng vai trò mà chúng ta đảm nhận trong gia đình, nơi chúng ta tồn tại là hạt giống có phản ánh hướng rất lớn đến quá trình trưởng thành. Bà tin rằng yếu tố gia đình đã góp phần tạo nên tính cách của mỗi con người. Bandler và Grinder đã sử dụng Mô hình trị liệu của Satir để tạo ra Mô hình Meta với các mẫu câu hỏi giúp tạo ra sự rõ ràng và sáng tỏ trong các vấn đề.</span>
				</div>
				<div id="agf">
					<span>Virginia Satir</span>
				</div>
				<div id="agg">
					<span>(1916-88)</span>
				</div>
				<div id="agh">
					<span>Những nhà tiên phong truyền cảm hứng</span>
				</div>
				<img id="agi" src={getAssetUrl("/images/nlp/agi.png")} srcSet={`${getAssetUrl("/images/nlp/agi.png")} 1x, ${getAssetUrl("/images/nlp/agi@2x.png")} 2x`} />

				<img id="agj" src={getAssetUrl("/images/nlp/agj.png")} srcSet={`${getAssetUrl("/images/nlp/agj.png")} 1x, ${getAssetUrl("/images/nlp/agj@2x.png")} 2x`} />

				<svg className="agk" viewBox="0 0 1920 683.83">
					<path id="agk" d="M 0 0 L 1920 0 L 1920 683.830078125 L 0 683.830078125 L 0 0 Z" />

				</svg>
				<div id="agl">
					<div id="agm">
						<svg className="agn" viewBox="5 7 21.448 15.317">
							<path id="agn" d="M 6.532000064849854 22.3169994354248 L 11.13199996948242 22.3169994354248 L 14.1899995803833 16.19000053405762 L 14.1899995803833 7 L 5 7 L 5 16.18999862670898 L 9.600000381469727 16.18999862670898 L 6.532000064849854 22.3169994354248 Z M 18.78499984741211 22.3169994354248 L 23.38500022888184 22.3169994354248 L 26.44799995422363 16.18999862670898 L 26.44799995422363 7 L 17.25799942016602 7 L 17.25799942016602 16.18999862670898 L 21.85799980163574 16.18999862670898 L 18.78499984741211 22.3169994354248 Z" />

						</svg>
						<svg className="ago" viewBox="0 0 36.76 36.76">
							<path id="ago" d="M 0 0 L 36.7599983215332 0 L 36.7599983215332 36.7599983215332 L 0 36.7599983215332 L 0 0 Z" />

						</svg>
					</div>
					<div id="agp">
						<svg className="agq" viewBox="0 0 21.448 15.317">
							<path id="agq" d="M 1.532000064849854 15.3169994354248 L 6.131999969482422 15.3169994354248 L 9.189999580383301 9.190000534057617 L 9.189999580383301 0 L 0 0 L 0 9.189998626708984 L 4.600000381469727 9.189998626708984 L 1.532000064849854 15.3169994354248 Z M 13.78499984741211 15.3169994354248 L 18.38500022888184 15.3169994354248 L 21.44799995422363 9.189998626708984 L 21.44799995422363 0 L 12.25799942016602 0 L 12.25799942016602 9.189998626708984 L 16.85799980163574 9.189998626708984 L 13.78499984741211 15.3169994354248 Z" />

						</svg>
						<svg className="agr" viewBox="0 0 36.76 36.76">
							<path id="agr" d="M 0 0 L 36.7599983215332 -1.275368641304633e-16 L 36.7599983215332 36.7599983215332 L -2.550737282609267e-16 36.7599983215332 L 0 0 Z" />

						</svg>
					</div>
					<div id="ags">
						<span>TAD JAMES</span>
					</div>
					<div id="agt">
						<img id="agu" src={getAssetUrl("/images/nlp/agu.png")} srcSet={`${getAssetUrl("/images/nlp/agu.png")} 1x, ${getAssetUrl("/images/nlp/agu@2x.png")} 2x`} />

					</div>
					<div id="agv">
						<span>Nhà tiên phong trong lĩnh vực trị liệu dòng thời gian</span>
					</div>
				</div>
				<div id="agw">
					<div id="agx">
						<svg className="agy" viewBox="5 7 21.448 15.317">
							<path id="agy" d="M 6.532000064849854 22.3169994354248 L 11.13199996948242 22.3169994354248 L 14.1899995803833 16.19000053405762 L 14.1899995803833 7 L 5 7 L 5 16.18999862670898 L 9.600000381469727 16.18999862670898 L 6.532000064849854 22.3169994354248 Z M 18.78499984741211 22.3169994354248 L 23.38500022888184 22.3169994354248 L 26.44799995422363 16.18999862670898 L 26.44799995422363 7 L 17.25799942016602 7 L 17.25799942016602 16.18999862670898 L 21.85799980163574 16.18999862670898 L 18.78499984741211 22.3169994354248 Z" />

						</svg>
						<svg className="agz" viewBox="0 0 36.76 36.76">
							<path id="agz" d="M 0 0 L 36.7599983215332 0 L 36.7599983215332 36.7599983215332 L 0 36.7599983215332 L 0 0 Z" />

						</svg>
					</div>
					<div id="aha">
						<svg className="ahb" viewBox="0 0 21.448 15.317">
							<path id="ahb" d="M 1.532000064849854 15.3169994354248 L 6.131999969482422 15.3169994354248 L 9.189999580383301 9.190000534057617 L 9.189999580383301 0 L 0 0 L 0 9.189998626708984 L 4.600000381469727 9.189998626708984 L 1.532000064849854 15.3169994354248 Z M 13.78499984741211 15.3169994354248 L 18.38500022888184 15.3169994354248 L 21.44799995422363 9.189998626708984 L 21.44799995422363 0 L 12.25799942016602 0 L 12.25799942016602 9.189998626708984 L 16.85799980163574 9.189998626708984 L 13.78499984741211 15.3169994354248 Z" />

						</svg>
						<svg className="ahc" viewBox="0 0 36.76 36.76">
							<path id="ahc" d="M 0 0 L 36.7599983215332 -1.275368641304633e-16 L 36.7599983215332 36.7599983215332 L -2.550737282609267e-16 36.7599983215332 L 0 0 Z" />

						</svg>
					</div>
					<div id="ahd">
						<span>ROBERT DILTS</span>
					</div>
					<div id="ahe">
						<img id="ahf" src={getAssetUrl("/images/nlp/ahf.png")} srcSet={`${getAssetUrl("/images/nlp/ahf.png")} 1x, ${getAssetUrl("/images/nlp/ahf@2x.png")} 2x`} />

					</div>
					<div id="ahg">
						<span>Nhà nghiên cứu và phát triển đa tài</span>
					</div>
				</div>
				<div id="ahh">
					<div id="ahi">
						<svg className="ahj" viewBox="5 7 21.448 15.317">
							<path id="ahj" d="M 6.532000064849854 22.3169994354248 L 11.13199996948242 22.3169994354248 L 14.1899995803833 16.19000053405762 L 14.1899995803833 7 L 5 7 L 5 16.18999862670898 L 9.600000381469727 16.18999862670898 L 6.532000064849854 22.3169994354248 Z M 18.78499984741211 22.3169994354248 L 23.38500022888184 22.3169994354248 L 26.44799995422363 16.18999862670898 L 26.44799995422363 7 L 17.25799942016602 7 L 17.25799942016602 16.18999862670898 L 21.85799980163574 16.18999862670898 L 18.78499984741211 22.3169994354248 Z" />

						</svg>
						<svg className="ahk" viewBox="0 0 36.76 36.76">
							<path id="ahk" d="M 0 0 L 36.7599983215332 0 L 36.7599983215332 36.7599983215332 L 0 36.7599983215332 L 0 0 Z" />

						</svg>
					</div>
					<div id="ahl">
						<svg className="ahm" viewBox="0 0 21.448 15.317">
							<path id="ahm" d="M 1.532000064849854 15.3169994354248 L 6.131999969482422 15.3169994354248 L 9.189999580383301 9.190000534057617 L 9.189999580383301 0 L 0 0 L 0 9.189998626708984 L 4.600000381469727 9.189998626708984 L 1.532000064849854 15.3169994354248 Z M 13.78499984741211 15.3169994354248 L 18.38500022888184 15.3169994354248 L 21.44799995422363 9.189998626708984 L 21.44799995422363 0 L 12.25799942016602 0 L 12.25799942016602 9.189998626708984 L 16.85799980163574 9.189998626708984 L 13.78499984741211 15.3169994354248 Z" />

						</svg>
						<svg className="ahn" viewBox="0 0 36.76 36.76">
							<path id="ahn" d="M 0 0 L 36.7599983215332 -1.275368641304633e-16 L 36.7599983215332 36.7599983215332 L -2.550737282609267e-16 36.7599983215332 L 0 0 Z" />

						</svg>
					</div>
					<div id="aho">
						<span>ANTHONY ROBBINS</span>
					</div>
					<div id="ahp">
						<img id="ahq" src={getAssetUrl("/images/nlp/ahq.png")} srcSet={`${getAssetUrl("/images/nlp/ahq.png")} 1x, ${getAssetUrl("/images/nlp/ahq@2x.png")} 2x`} />

					</div>
					<div id="ahr">
						<span>Gương mặt đại diện” cho NLP</span>
					</div>
				</div>
				<div id="ahs">
					<span>NHỮNG NGƯỜI TIẾP NỐI VÀ PHÁT TRIỂN NLP</span>
				</div>
				<div id="aht">
					<span>Chắp cánh cho một lĩnh vực mang tầm ảnh hưởng to lớn</span>
				</div>
				<img id="ahu" src={getAssetUrl("/images/nlp/ahu.png")} srcSet={`${getAssetUrl("/images/nlp/ahu.png")} 1x, ${getAssetUrl("/images/nlp/ahu@2x.png")} 2x`} />

				<img id="ahv" src={getAssetUrl("/images/nlp/ahv.png")} srcSet={`${getAssetUrl("/images/nlp/ahv.png")} 1x, ${getAssetUrl("/images/nlp/ahv@2x.png")} 2x`} />
				<div id="ahw">
					<span>NLP</span>
				</div>
				<div id="ahx">
					<span>Lập trình ngôn ngữ tư duy</span>
				</div>
				<div id="ahy">
					<span>Khai phá sức mạnh tiềm ẩn bên trong bạn và trở thành phiên bản xuất sắc nhất của chính mình</span>
				</div>
				<div id="ahz">
					<svg className="aia">
						<rect id="aia" rx="40" ry="40" x="0" y="0" width="342" height="80" />

					</svg>
					<div id="aib">
						<span>Khám phá ngay</span>
					</div>
					<svg className="aic" viewBox="3346.403 792.382 23.039 11.519">
						<path id="aic" d="M 3346.402587890625 792.381591796875 L 3357.921875 803.9010620117188 L 3369.44140625 792.381591796875" />

					</svg>
				</div>
				<img id="aid" className="reveal-hidden" src={getAssetUrl("/images/nlp/aid.png")} srcSet={`${getAssetUrl("/images/nlp/aid.png")} 1x, ${getAssetUrl("/images/nlp/aid@2x.png")} 2x`} />
				<svg className="aie">
					<rect id="aie" rx="13" ry="13" x="0" y="0" width="311" height="135" />

				</svg>
				<div id="aif" className="reveal-hidden" style={{ transitionDelay: "0.2s" }}>
					<div id="aig">
						<span>Hiểu rõ bản thân</span>
					</div>
					<div id="aih">
						<span>Nhận thức sâu sắc về chính mình, phá vỡ những rào cản nội tại và khai phá tiềm lực bên trong.</span>
					</div>
				</div>
				<img id="aii" className="reveal-hidden" src={getAssetUrl("/images/nlp/aii.png")} srcSet={`${getAssetUrl("/images/nlp/aii.png")} 1x, ${getAssetUrl("/images/nlp/aii@2x.png")} 2x`} />
				<div id="aij" className="reveal-hidden" style={{ transitionDelay: "0.2s" }}>
					<svg className="aik">
						<rect id="aik" rx="13" ry="13" x="0" y="0" width="311" height="135" />

					</svg>
					<div id="ail">
						<span>Hiểu rõ người khác</span>
					</div>
					<div id="aim">
						<span>Nâng cao khả năng giao tiếp, hài hòa các mối quan hệ và giúp người khác giải phóng rào cản, khơi thông nguồn lực để tiến về phía trước.</span>
					</div>
				</div>
				<img id="ain" className="reveal-hidden" src={getAssetUrl("/images/nlp/ain.png")} srcSet={`${getAssetUrl("/images/nlp/ain.png")} 1x, ${getAssetUrl("/images/nlp/ain@2x.png")} 2x`} />
				<div id="aio" className="reveal-hidden" style={{ transitionDelay: "0.2s" }}>
					<svg className="aip">
						<rect id="aip" rx="13" ry="13" x="0" y="0" width="584" height="69" />

					</svg>
					<div id="aiq">
						<div id="air">
							<span>Thay đổi tư duy, hành vi và đạt được mục tiêu một cách hiệu quả.</span>
						</div>
						<div id="ais">
							<span>Làm chủ cuộc sống</span>
						</div>
					</div>
				</div>
				<div id="ait" className="reveal-hidden" style={{ transitionDelay: "0.4s" }}>
					<svg className="aiu">
						<rect id="aiu" rx="13" ry="13" x="0" y="0" width="578" height="150" />

					</svg>
					<div id="aiv">
						<span>Cung cấp cho Bạn các mô hình, quy trình và kỹ thuật để khai vấn, thoát khỏi sự kiềm cặp của những giới hạn bởi năng lực bên trong và áp lực bên ngoài cho chính bản thân và những người xung quanh nhằm gia tăng chất lượng cuộc sống.</span>
					</div>
					<div id="aiw">
						<span>Khai vấn - Coaching</span>
					</div>
				</div>
				<div id="aix" className="reveal-hidden">
					<svg className="aiy">
						<rect id="aiy" rx="30" ry="30" x="0" y="0" width="683" height="490" />

					</svg>
					<div id="aiz">
						<div id="aja">
							<span>Hiệp hội TLTA <br />Time Line Therapy® Association </span>
						</div>
						<div id="ajb">
							<span>Hiệp Hội Chuyên gia Trị liệu Dòng Thời Gian Quốc tế.</span>
						</div>
						<svg className="ajc" viewBox="2581 13572.402 592.185 3">
							<path id="ajc" d="M 2581 13572.40234375 L 3173.1845703125 13572.40234375" />

						</svg>
					</div>
					<div id="ajd">
						<svg className="aje">
							<ellipse id="aje" rx="123.5" ry="124" cx="123.5" cy="124" />

						</svg>
						<img id="ajf" src={getAssetUrl("/images/nlp/ajf.png")} srcSet={`${getAssetUrl("/images/nlp/ajf.png")} 1x, ${getAssetUrl("/images/nlp/ajf@2x.png")} 2x`} />

					</div>
				</div>
				<div id="ajg" className="reveal-hidden" style={{ transitionDelay: "0.2s" }}>
					<svg className="ajh">
						<rect id="ajh" rx="29" ry="29" x="0" y="0" width="683" height="490" />

					</svg>
					<div id="aji">
						<span>Hiệp hội ABNLP American<br />Board of NLP</span>
					</div>
					<div id="ajj">
						<span>ABNLP là hiệp hội lớn và lâu đời nhất trên thế giới, được thành lập vào năm 1982 bởi Tiến sĩ A. M. Krasner. Cho đến nay, hiệp hội ABNLP đã có hàng trăm nghìn nhàn đào tạo NLP trên khắp thế giới.</span>
					</div>
					<svg className="ajk" viewBox="2581 13572.402 592.185 3">
						<path id="ajk" d="M 2581 13572.40234375 L 3173.1845703125 13572.40234375" />

					</svg>
					<div id="ajl">
						<svg className="ajm">
							<ellipse id="ajm" rx="123.5" ry="124" cx="123.5" cy="124" />

						</svg>
						<img id="ajn" src={getAssetUrl("/images/nlp/ajn.png")} srcSet={`${getAssetUrl("/images/nlp/ajn.png")} 1x, ${getAssetUrl("/images/nlp/ajn@2x.png")} 2x`} />

					</div>
				</div>
				<div id="ajo">
					<svg className="ajp" viewBox="0 0 1920 772.539">
						<path id="ajp" d="M 0 0 L 1920 0 L 1920 772.5390625 L 0 772.5390625 L 0 0 Z" />

					</svg>
					<div id="ajq">
						<span>HÀNH TRÌNH PHÁT TRIỂN</span><br /><span style={{ fontStyle: 'normal', fontWeight: 'lighter', fontSize: '91px' }}>NĂNG LỰC</span>
					</div>
					<div id="ajr">
						<span>CÙNG HỆ THỐNG ABNLP</span>
					</div>
					<div id="ajs">
						<svg className="ajt">
							<rect id="ajt" rx="0" ry="0" x="0" y="0" width="668" height="123" />

						</svg>
						<svg className="aju">
							<rect id="aju" rx="0" ry="0" x="0" y="0" width="668" height="82" />

						</svg>
						<svg className="ajv">
							<rect id="ajv" rx="0" ry="0" x="0" y="0" width="668" height="83" />

						</svg>
						<svg className="ajw">
							<rect id="ajw" rx="0" ry="0" x="0" y="0" width="668" height="110" />

						</svg>
						<svg className="ajx">
							<rect id="ajx" rx="0" ry="0" x="0" y="0" width="668" height="83" />

						</svg>
						<svg className="ajy">
							<rect id="ajy" rx="0" ry="0" x="0" y="0" width="668" height="83" />

						</svg>
						<svg className="ajz" viewBox="0 0 692 599">
							<path id="ajz" d="M 345.9999694824219 0 L 692 599 L 0 599 Z" />

						</svg>
						<svg className="aka" viewBox="0 0 600 516">
							<path id="aka" d="M 299.9999694824219 0 L 600 516 L 0 516 Z" />

						</svg>
						<svg className="akb" viewBox="0 0 588 509">
							<path id="akb" d="M 293.9999694824219 0 L 588 509 L 0 509 Z" />

						</svg>
						<svg className="akc" viewBox="0 0 492 425">
							<path id="akc" d="M 245.9999847412109 0 L 492 425 L 0 425 Z" />

						</svg>
						<svg className="akd" viewBox="0 0 485 419">
							<path id="akd" d="M 242.4999847412109 0 L 485 419 L 0 419 Z" />

						</svg>
						<svg className="ake" viewBox="0 0 390 336">
							<path id="ake" d="M 194.9999847412109 0 L 390 336 L 0 336 Z" />

						</svg>
						<svg className="akf" viewBox="0 0 382 329">
							<path id="akf" d="M 190.9999847412109 0 L 382 329 L 0 329 Z" />

						</svg>
						<svg className="akg" viewBox="0 0 284 247">
							<path id="akg" d="M 142 0 L 284 247 L 0 247 Z" />

						</svg>
						<svg className="akh" viewBox="0 0 276 240">
							<path id="akh" d="M 137.9999847412109 0 L 276 240 L 0 240 Z" />

						</svg>
						<svg className="aki" viewBox="0 0 151 130">
							<path id="aki" d="M 75.49999237060547 0 L 151 130 L 0 130 Z" />

						</svg>
						<svg className="akj" viewBox="0 0 141 123">
							<path id="akj" d="M 70.49999237060547 0 L 141 123 L 0 123 Z" />

						</svg>
						<div id="akk">
							<span>NLP<br />Master<br />Trainer</span>
						</div>
						<div id="akl">
							<span>NLP<br />Master Coach<br />Trainer</span>
						</div>
						<div id="akm">
							<span>NLP Master Practitioner <br />Time Line Therapy® Master Practitioner</span>
						</div>
						<div id="akn">
							<span>NLP Practitioner</span>
						</div>
						<div id="ako">
							<span>NLP Trainer</span>
						</div>
						<div id="akp">
							<span>NLP Master Coach</span>
						</div>
						<div id="akq">
							<span>Time Line Therapy®<br />Trainer</span>
						</div>
						<svg className="akr">
							<rect id="akr" rx="0" ry="0" x="0" y="0" width="6" height="87" />

						</svg>
						<div id="aks">
							<span>Cấp độ năng lực cao nhất trong NLP - Đào tạo các nhà đào tạo, Khai vấn, thực hành NLP</span>
						</div>
						<div id="akt">
							<div id="aku">
								<span>Nhà đào tạo chuyên gia khai vấn bạn NLP</span>
							</div>
							<div id="akv">
								<span>Học tại Tab James Co,</span>
							</div>
						</div>
						<div id="akw">
							<div id="akx">
								<span>Nhà đào tạo phương pháp trị liệu dòng thời gian</span>
							</div>
							<div id="aky">
								<span>Học tại Tab James Co,</span>
							</div>
						</div>
						<div id="akz">
							<div id="ala">
								<span>InnerPOWER -</span><span style={{ color: 'rgba(0,0,0,0.871)' }}> Đánh Thức Nội Lực Lãnh Đạo Cuộc Đời</span>
							</div>
							<div id="alb">
								<span>NLP Master Practitioner </span><span style={{ fontStyle: 'normal', fontWeight: 'lighter' }}>- </span><span style={{ fontStyle: 'normal', fontWeight: 'lighter' }}>Chuyên Gia Thực Hành NLP Level 2</span><br /><span style={{ fontStyle: 'normal', fontWeight: 'lighter' }}>Chứng chỉ: NLP Practitioner &amp; Time Line Therapy Master Practitioner<br />100 Giờ đào tạo Online &amp; 3 phiên mentoring</span>
							</div>
						</div>
						<div id="alc">
							<div id="ald">
								<span>InnerMIND -</span><span style={{ color: 'rgba(0,0,0,0.871)' }}> Làm Chủ Tâm Trí Nâng Tầm Lãnh Đạo</span>
							</div>
							<div id="ale">
								<span>NLP Practitioner </span><span style={{ fontStyle: 'normal', fontWeight: 'lighter' }}>- </span><span style={{ fontStyle: 'normal', fontWeight: 'lighter' }}>Chuyên Gia Thực Hành NLP Level 1</span><br /><span style={{ fontStyle: 'normal', fontWeight: 'lighter' }}>Chứng chỉ: NLP Practitioner (ABNLP) &amp; Time Line Therapy Practitioner<br />65 Giờ đào tạo Online &amp; 3 phiên mentoring</span>
							</div>
						</div>
						<div id="alf">
							<div id="alg">
								<div id="alh">
									<span>NLP TRAINER</span>
								</div>
								<div id="ali">
									<span>Chứng chỉ: NLP Trainer<br />18 ngày</span>
								</div>
							</div>
							<div id="alj">
								<div id="alk">
									<span>InnerFIRE - Người Thắp Lửa</span>
								</div>
								<div id="all">
									<span>NLP MASTER COACH</span>
								</div>
								<div id="alm">
									<span>Chứng chỉ: NLP Master Coach<br />3 tháng</span>
								</div>
							</div>
							<svg className="aln" viewBox="3806.353 12785.937 2 66.541">
								<path id="aln" d="M 3806.3525390625 12785.9365234375 L 3806.3525390625 12852.4775390625" />

							</svg>
						</div>
						<div id="alo">
							<svg className="alp">
								<ellipse id="alp" rx="19" ry="19" cx="19" cy="19" />

							</svg>
							<div id="alq">
								<span>1</span>
							</div>
						</div>
						<div id="alr">
							<svg className="als">
								<ellipse id="als" rx="19" ry="19" cx="19" cy="19" />

							</svg>
							<div id="alt">
								<span>2</span>
							</div>
						</div>
						<div id="alu">
							<svg className="alv">
								<ellipse id="alv" rx="18.5" ry="18.5" cx="18.5" cy="18.5" />

							</svg>
							<div id="alw">
								<span>3</span>
							</div>
						</div>
						<div id="alx">
							<svg className="aly">
								<ellipse id="aly" rx="19" ry="19" cx="19" cy="19" />

							</svg>
							<div id="alz">
								<span>4</span>
							</div>
						</div>
						<div id="ama">
							<svg className="amb">
								<ellipse id="amb" rx="18.5" ry="19" cx="18.5" cy="19" />

							</svg>
							<div id="amc">
								<span>5</span>
							</div>
						</div>
						<div id="amd">
							<svg className="ame">
								<ellipse id="ame" rx="18.5" ry="19" cx="18.5" cy="19" />

							</svg>
							<div id="amf">
								<span>6</span>
							</div>
						</div>
					</div>
					<div id="amg">
						<span>Các chương trình đào tạo NLP tại InnerBright được bảo chứng bởi các hiệp hội uy tín quốc tế về chứng nhận và chất lượng.</span>
					</div>
				</div>
			</div>

		</ScaleWrapper>
	);
}
