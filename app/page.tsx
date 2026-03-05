import './Home.css';
import Header from '@/components/sections/Header';
import Hero from '@/components/sections/Hero';
import Philosophy from '@/components/sections/Philosophy';
import SelfDevelopment from '@/components/sections/SelfDevelopment';
import Certification from '@/components/sections/Certification';
import FiveFoundations from '@/components/sections/FiveFoundations';
import InnerValues from '@/components/sections/InnerValues';
import ExpertChloe from '@/components/sections/ExpertChloe';
import Partners from '@/components/sections/Partners';
import BottomGraphics from '@/components/sections/BottomGraphics';
import PaginationDots from '@/components/sections/PaginationDots';
import BackToTop from '@/components/sections/BackToTop';
import ScaleWrapper from '@/components/sections/ScaleWrapper';

export default function HomePage() {
  return (
    <ScaleWrapper>
      <div id="Home">
        {/* Universal Background / Decorative elements */}
        <svg className="aaa">
          <rect id="aaa" rx="0" ry="0" x="0" y="0" width="1920" height="258">
          </rect>
        </svg>

        {/* Main Sections - Ordered by Z-Index (later is higher) */}
        <Philosophy />
        <SelfDevelopment />
        <Certification />
        <FiveFoundations />
        <InnerValues />
        <ExpertChloe />
        <Partners />
        <BottomGraphics />
        <Hero />

        {/* Overlays / Global Components */}
        <Header />
        <BackToTop />
        <PaginationDots />
      </div>
    </ScaleWrapper>
  );
}
