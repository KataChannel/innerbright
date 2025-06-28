import Footer from "@/app/components/common/Footer";
import Header from "@/app/components/common/Header";
export const metadata = {
  title: "Innerbright",
};
export default function Layout({ children }: { children: React.ReactNode }) {
  return (
    <div className="root-layout space-y-4">
      <Header />
      <main>{children}</main>
      <Footer />
    </div>
  );
}
