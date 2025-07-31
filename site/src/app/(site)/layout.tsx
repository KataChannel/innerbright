export const metadata = {
  title: 'Innerbright Offical',
};
export default function Layout({ children }: { children: React.ReactNode }) {
  return (
    <div>
      <main>{children}</main>
    </div>
  );
}
