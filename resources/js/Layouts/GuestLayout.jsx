import { Link } from '@inertiajs/react';

export default function Guest({ children }) {
    return (
        <div className="min-h-screen grid grid-cols-1 md:grid-cols-2">
            {/* Left Side - Brand/Hero */}
            <div className="relative hidden md:flex flex-col justify-center items-center bg-emerald-900 text-white overflow-hidden">
                <div className="absolute inset-0 bg-gradient-to-br from-emerald-800 to-slate-900 opacity-90"></div>
                <div className="relative z-10 flex flex-col items-center">
                    <img 
                        src="/images/logo.png" 
                        alt="OurFuture Logo" 
                        className="w-32 h-32 mb-8 drop-shadow-2xl"
                    />
                    <h1 className="text-4xl font-bold tracking-tight mb-2">OurFuture</h1>
                    <p className="text-emerald-100 text-lg">Building your SaaS dreams.</p>
                </div>
                {/* Decorative circles */}
                <div className="absolute -top-24 -left-24 w-96 h-96 bg-emerald-600 rounded-full mix-blend-multiply filter blur-3xl opacity-20 animate-blob"></div>
                <div className="absolute -bottom-24 -right-24 w-96 h-96 bg-purple-600 rounded-full mix-blend-multiply filter blur-3xl opacity-20 animate-blob animation-delay-2000"></div>
            </div>

            {/* Right Side - Form */}
            <div className="flex flex-col justify-center items-center p-6 bg-slate-50 dark:bg-slate-900 sm:px-12 md:px-24">
                <div className="w-full max-w-md">
                    <div className="flex justify-center md:hidden mb-8">
                        <Link href="/">
                             <img 
                                src="/images/logo.png" 
                                alt="OurFuture Logo" 
                                className="w-20 h-20"
                            />
                        </Link>
                    </div>

                    <div className="bg-white dark:bg-slate-800 shadow-xl rounded-2xl p-8 border border-slate-100 dark:border-slate-700">
                        {children}
                    </div>
                </div>
                
                <div className="mt-8 text-center text-sm text-slate-500 dark:text-slate-400">
                    &copy; {new Date().getFullYear()} OurFuture. All rights reserved.
                </div>
            </div>
        </div>
    );
}
