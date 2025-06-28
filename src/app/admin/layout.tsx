import React from 'react';

export default function Layout({ children }: { children: React.ReactNode }) {
    return (
        <div className="admin-layout">
            <header className="admin-header">Admin Header</header>
            <nav className="admin-nav">Sidebar or menu items go here</nav>
            <main className="admin-content">{children}</main>
            <footer className="admin-footer">Admin Footer</footer>
        </div>
    );
}