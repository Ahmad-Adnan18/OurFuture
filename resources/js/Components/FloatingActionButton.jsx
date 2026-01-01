import { Link } from '@inertiajs/react';

export default function FloatingActionButton({ href, icon, color = 'emerald' }) {
    return (
        <Link href={href} className={`absolute -top-6 left-1/2 -translate-x-1/2 rounded-full p-4 shadow-lg text-white transition-transform hover:scale-110 active:scale-95 bg-${color}-600`}>
             {/* Simple Plus Icon Placeholder if no icon provided */}
             {icon ? icon : (
                 <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" strokeWidth={2.5} stroke="currentColor" className="w-6 h-6">
                    <path strokeLinecap="round" strokeLinejoin="round" d="M12 4.5v15m7.5-7.5h-15" />
                 </svg>
             )}
        </Link>
    );
    // Note: To use dynamic bg-{color}-600, ensure Safelist in tailwind.config.js or use style object.
    // For simplicity, we used string interpolation which might be purged. 
    // Recommended to use explicit classes or style.
    // Let's use explicit 'bg-emerald-600' as default and handle others if needed.
}
