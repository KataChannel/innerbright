"use client"
import React, { useState } from 'react';

interface Slide {
    id: number;
    content: React.ReactNode;
    backgroundImage?: string;
    info?: string;
    shopUrl?: string;
}

interface SwipeProps {
    slides: Slide[];
    darkMode?: boolean;
}

const transitionDuration = 300; // in ms

const Swipe: React.FC<SwipeProps> = ({ slides, darkMode = false }) => {
    const [currentSlide, setCurrentSlide] = useState(0);
    const [fading, setFading] = useState(false);

    const containerStyle: React.CSSProperties = {
        backgroundColor: darkMode ? '#1a1a1a' : '#f0f0f0',
        color: darkMode ? '#f0f0f0' : '#1a1a1a',
        padding: '20px',
        borderRadius: '8px',
        textAlign: 'center',
        position: 'relative',
        width: '100%',
    };

    const baseSlideStyle: React.CSSProperties = {
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        height: '250px',
        border: darkMode ? '1px solid #333' : '1px solid #ccc',
        backgroundColor: darkMode ? '#2a2a2a' : '#fff',
        boxShadow: darkMode ? '0 2px 4px rgba(0,0,0,0.6)' : '0 2px 4px rgba(0,0,0,0.1)',
        borderRadius: '4px',
        opacity: fading ? 0 : 1,
        transition: `opacity ${transitionDuration}ms ease-in-out`,
        position: 'relative',
    };

    // Get current slide data
    const currentSlideData = slides[currentSlide];

    // Update slide style with dynamic background image nếu có
    const slideStyle: React.CSSProperties = {
        ...baseSlideStyle,
        ...(currentSlideData.backgroundImage && {
            backgroundImage: `url(${currentSlideData.backgroundImage})`,
            backgroundSize: 'cover',
            backgroundPosition: 'center',
        }),
    };

    const arrowStyle: React.CSSProperties = {
        position: 'absolute',
        top: '50%',
        transform: 'translateY(-50%)',
        backgroundColor: darkMode ? '#333' : '#ccc',
        color: darkMode ? '#f0f0f0' : '#1a1a1a',
        border: 'none',
        borderRadius: '50%',
        width: '40px',
        height: '40px',
        cursor: 'pointer',
        outline: 'none',
    };

    const paginationStyle: React.CSSProperties = {
        display: 'flex',
        justifyContent: 'center',
        marginTop: '10px',
    };

    const dotStyle = (active: boolean): React.CSSProperties => ({
        height: '12px',
        width: '12px',
        margin: '0 5px',
        backgroundColor: active ? (darkMode ? '#f0f0f0' : '#1a1a1a') : (darkMode ? '#555' : '#ccc'),
        borderRadius: '50%',
        cursor: 'pointer',
        border: 'none',
    });

    const changeSlide = (newIndex: number) => {
        setFading(true);
        setTimeout(() => {
            setCurrentSlide(newIndex);
            setFading(false);
        }, transitionDuration);
    };

    const goToPrevious = () => {
        const newIndex = currentSlide === 0 ? slides.length - 1 : currentSlide - 1;
        changeSlide(newIndex);
    };

    const goToNext = () => {
        const newIndex = currentSlide === slides.length - 1 ? 0 : currentSlide + 1;
        changeSlide(newIndex);
    };

    // Style cho overlay hiển thị info và nút Shop Now
    const overlayStyle: React.CSSProperties = {
        position: 'absolute',
        bottom: '20px',
        left: '20px',
        backgroundColor: 'rgba(0, 0, 0, 0.5)',
        padding: '10px 15px',
        borderRadius: '4px',
        color: '#fff',
    };

    const shopButtonStyle: React.CSSProperties = {
        marginTop: '10px',
        padding: '8px 12px',
        backgroundColor: '#ff6600',
        color: '#fff',
        border: 'none',
        borderRadius: '4px',
        cursor: 'pointer',
        textDecoration: 'none',
    };

    return (
        <div style={containerStyle}>
            <div style={{ position: 'relative' }}>
                <button onClick={goToPrevious} style={{ ...arrowStyle, left: '10px' }}>
                    &lt;
                </button>
                <div style={slideStyle}>
                    {currentSlideData.content}
                    {currentSlideData.info && (
                        <div style={overlayStyle}>
                            <div>{currentSlideData.info}</div>
                            {currentSlideData.shopUrl && (
                                <a href={currentSlideData.shopUrl} style={shopButtonStyle}>
                                    Shop Now
                                </a>
                            )}
                        </div>
                    )}
                </div>
                <button onClick={goToNext} style={{ ...arrowStyle, right: '10px' }}>
                    &gt;
                </button>
            </div>
            <div style={paginationStyle}>
                {slides.map((_, index) => (
                    <button
                        key={index}
                        onClick={() => changeSlide(index)}
                        style={dotStyle(currentSlide === index)}
                    />
                ))}
            </div>
        </div>
    );
};

export default Swipe;