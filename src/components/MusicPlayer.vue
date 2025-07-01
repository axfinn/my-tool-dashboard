<template>
    <div class="music-player" 
        v-if="isVisible"
        :style="{ transform: `translate(${playerX}px, ${playerY}px)`, cursor: isMovable ? 'grab' : 'default' }"
        @mousedown="startDrag"
        @mouseenter="showVolume = true"
        @mouseleave="showVolume = false">
        <audio id="background-music" loop>
            <source src="/audio/background_music.mp3" type="audio/mpeg"> <!-- 请替换为您的音乐文件路径 -->
            您的浏览器不支持音频播放。
        </audio>
        <button class="play-pause-btn" @click="toggleMusic">
            {{ isPlaying ? '&#10074;&#10074;' : '&#9658;' }} <!-- Play/Pause icons -->
        </button>
        <input type="range" min="0" max="1" step="0.01" v-model="volume" @input="setVolume" v-if="showVolume">
    </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted, defineProps } from 'vue';

const STORAGE_KEY_MUSIC_PLAYER_POSITION = 'music-player-position';

const props = defineProps({
    isVisible: { type: Boolean, default: true },
    isMovable: { type: Boolean, default: true }
});

const isPlaying = ref(false);
const volume = ref(0.5);
let audioPlayer = null;

const playerX = ref(0); // Initial X offset for transform
const playerY = ref(0); // Initial Y offset for transform
const isDragging = ref(false);
let startMouseX = 0;
let startMouseY = 0;
let startPlayerX = 0;
let startPlayerY = 0;

const showVolume = ref(false);

let animationFrameId = null;

const throttledDrag = (e) => {
    if (animationFrameId) {
        cancelAnimationFrame(animationFrameId);
    }
    animationFrameId = requestAnimationFrame(() => {
        if (!isDragging.value) return;
        const dx = e.clientX - startMouseX;
        const dy = e.clientY - startMouseY;
        playerX.value = startPlayerX + dx;
        playerY.value = startPlayerY + dy;
    });
};

onMounted(() => {
    audioPlayer = document.getElementById('background-music');
    audioPlayer.volume = volume.value;

    const savedPosition = JSON.parse(localStorage.getItem(STORAGE_KEY_MUSIC_PLAYER_POSITION));
    if (savedPosition) {
        playerX.value = savedPosition.x;
        playerY.value = savedPosition.y;
    }

    document.addEventListener('mousemove', throttledDrag);
    document.addEventListener('mouseup', stopDrag);
});

onUnmounted(() => {
    document.removeEventListener('mousemove', throttledDrag);
    document.removeEventListener('mouseup', stopDrag);
    if (animationFrameId) {
        cancelAnimationFrame(animationFrameId);
    }
});

const toggleMusic = () => {
    if (audioPlayer.paused) {
        audioPlayer.play();
        isPlaying.value = true;
    } else {
        audioPlayer.pause();
        isPlaying.value = false;
    }
};

const setVolume = () => {
    if (audioPlayer) {
        audioPlayer.volume = volume.value;
    }
};

const startDrag = (e) => {
    if (!props.isMovable) return;
    isDragging.value = true;
    startMouseX = e.clientX;
    startMouseY = e.clientY;
    startPlayerX = playerX.value;
    startPlayerY = playerY.value;
    e.preventDefault(); // Prevent default drag behavior
};

const stopDrag = () => {
    isDragging.value = false;
    localStorage.setItem(STORAGE_KEY_MUSIC_PLAYER_POSITION, JSON.stringify({ x: playerX.value, y: playerY.value }));
};
</script>

<style scoped>
/* Music player specific styles */
.music-player {
    position: fixed;
    bottom: 20px;
    right: 20px; /* Position in bottom right */
    background: rgba(255, 255, 255, 0.8);
    backdrop-filter: blur(5px);
    border-radius: 10px;
    box-shadow: 0 5px 15px rgba(0,0,0,0.1);
    display: flex;
    align-items: center;
    padding: 3px; /* Minimal padding */
    gap: 0; /* No gap by default */
    z-index: 1000;
    cursor: grab; /* Indicate draggable */
    transition: all 0.3s ease; /* Smooth transition for all properties */
    overflow: hidden; /* Hide overflow content */
    width: 36px; /* Default width for just the button */
}

.music-player:active {
    cursor: grabbing;
}

.music-player:hover {
    width: 100px; /* Expanded width to show slider */
    padding: 3px 8px; /* Slightly more padding on hover */
    gap: 3px; /* Add gap on hover */
}

.music-player .play-pause-btn {
    width: 30px; /* Fixed width for circular button */
    height: 30px; /* Fixed height for circular button */
    border-radius: 50%; /* Make it circular */
    background-color: #007bff; /* Blue background */
    color: white;
    display: flex;
    justify-content: center;
    align-items: center;
    border: none;
    cursor: pointer;
    flex-shrink: 0;
    font-size: 0.8rem; /* Adjust font size for icons */
    line-height: 1; /* Ensure icon is centered vertically */
}

.music-player .play-pause-btn:hover {
    background-color: #0056b3; /* Darker blue on hover */
}

.music-player input[type="range"] {
    width: 60px; /* Slider width when visible */
    flex-grow: 1; /* Allow slider to take available space */
    margin-left: 5px; /* Space between button and slider */
}
</style>
