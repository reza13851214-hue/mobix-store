import './globals.css';
import type { Metadata } from 'next';
export const metadata: Metadata={title:'MOBIX | فروشگاه لوازم جانبی موبایل',description:'فروشگاه اینترنتی موبیکس'};
export default function RootLayout({children}:{children:React.ReactNode}){return <html lang="fa" dir="rtl"><body>{children}</body></html>}
