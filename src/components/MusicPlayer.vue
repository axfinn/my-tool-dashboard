<template>
    <div class="music-player" 
        v-if="isVisible"
        :class="{ 'no-transition': isDragging }"
        :style="{ transform: `translate(${playerX}px, ${playerY}px)`, cursor: isMovable ? 'grab' : 'default' }"
        @mousedown="startDrag"
        @touchstart.prevent="startDrag">
        <audio id="background-music" loop></audio>
        <button class="play-pause-btn" @click="toggleMusic" :aria-label="isPlaying ? '暂停音乐' : '播放音乐'">
            {{ isPlaying ? '&#10074;&#10074;' : '&#9658;' }} <!-- Play/Pause icons -->
        </button>
        <button class="next-btn" @click="playNextMusic" aria-label="下一首">&#9654;&#9654;</button>
        <input type="range" min="0" max="1" step="0.01" v-model="volume" @input="setVolume">
    </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted, defineProps } from 'vue';

const STORAGE_KEY_MUSIC_PLAYER_POSITION = 'music-player-position';

const props = defineProps({
    isVisible: { type: Boolean, default: true },
    isMovable: { type: Boolean, default: true },
    musicUrls: { type: Array, default: () => [] }
});

const isPlaying = ref(false);
const volume = ref(0.5);
const currentMusicIndex = ref(0); // New ref for current music index
let audioPlayer = null;

const playerX = ref(0); // Initial X offset for transform
const playerY = ref(0); // Initial Y offset for transform
const isDragging = ref(false);
let startMouseX = 0;
let startMouseY = 0;
let startPlayerX = 0;
let startPlayerY = 0;
const longPressTimer = ref(null);
const initialTouchX = ref(0);
const initialTouchY = ref(0);

let animationFrameId = null;

const playCurrentMusic = () => {
    if (audioPlayer && props.musicUrls.length > 0) {
        audioPlayer.src = props.musicUrls[currentMusicIndex.value];
        audioPlayer.load();
        audioPlayer.play().then(() => {
            isPlaying.value = true;
        }).catch(error => {
            console.error("Error playing music:", error);
            isPlaying.value = false;
        });
    }
};

const playNextMusic = () => {
    currentMusicIndex.value = (currentMusicIndex.value + 1) % props.musicUrls.length;
    playCurrentMusic();
};

const throttledDrag = (e) => {
    if (animationFrameId) {
        cancelAnimationFrame(animationFrameId);
    }
    animationFrameId = requestAnimationFrame(() => {
        if (!isDragging.value) {
            if (e.type === 'touchmove') {
                const clientX = e.touches[0].clientX;
                const clientY = e.touches[0].clientY;
                if (Math.abs(clientX - initialTouchX.value) > 10 || Math.abs(clientY - initialTouchY.value) > 10) {
                    clearTimeout(longPressTimer.value);
                }
            }
            return;
        }
        const clientX = e.touches ? e.touches[0].clientX : e.clientX;
        const clientY = e.touches ? e.touches[0].clientY : e.clientY;
        const dx = clientX - startMouseX;
        const dy = clientY - startMouseY;
        playerX.value = startPlayerX + dx;
        playerY.value = startPlayerY + dy;
    });
};

onMounted(() => {
    audioPlayer = document.getElementById('background-music');
    audioPlayer.volume = volume.value;

    // Add event listener for when current music ends
    audioPlayer.addEventListener('ended', playNextMusic);

    const savedPosition = JSON.parse(localStorage.getItem(STORAGE_KEY_MUSIC_PLAYER_POSITION));
    if (savedPosition) {
        playerX.value = savedPosition.x;
        playerY.value = savedPosition.y;
    }

    // If there are music URLs, start playing the first one
    // Removed automatic playback due to browser restrictions

    document.addEventListener('mousemove', throttledDrag);
    document.addEventListener('mouseup', stopDrag);
    document.addEventListener('touchmove', throttledDrag);
    document.addEventListener('touchend', stopDrag);
});

onUnmounted(() => {
    document.removeEventListener('mousemove', throttledDrag);
    document.removeEventListener('mouseup', stopDrag);
    document.removeEventListener('touchmove', throttledDrag);
    document.removeEventListener('touchend', stopDrag);
    if (animationFrameId) {
        cancelAnimationFrame(animationFrameId);
    }
    if (audioPlayer) {
        audioPlayer.removeEventListener('ended', playNextMusic);
        audioPlayer.pause();
        audioPlayer.src = '';
        audioPlayer.load();
    }
});

const toggleMusic = () => {
    if (audioPlayer.paused) {
        playCurrentMusic();
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

    const clientX = e.touches ? e.touches[0].clientX : e.clientX;
    const clientY = e.touches ? e.touches[0].clientY : e.clientY;

    if (e.type === 'touchstart') {
        initialTouchX.value = clientX;
        initialTouchY.value = clientY;

        longPressTimer.value = setTimeout(() => {
            isDragging.value = true;
            startMouseX = clientX;
            startMouseY = clientY;
            startPlayerX = playerX.value;
            startPlayerY = playerY.value;
        }, 500); // 500ms for long press
    } else { // mousedown
        isDragging.value = true;
        startMouseX = clientX;
        startMouseY = clientY;
        startPlayerX = playerX.value;
        startPlayerY = playerY.value;
    }
};

const stopDrag = () => {
    clearTimeout(longPressTimer.value);
    if (isDragging.value) {
        isDragging.value = false;
        localStorage.setItem(STORAGE_KEY_MUSIC_PLAYER_POSITION, JSON.stringify({ x: playerX.value, y: playerY.value }));
    }
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
    padding: 5px 10px; /* Slightly more padding on hover */
    gap: 5px; /* Add gap on hover */
    z-index: 1000;
    cursor: grab; /* Indicate draggable */
    transition: all 0.3s ease; /* Smooth transition for all properties */
    overflow: hidden; /* Hide overflow content */
    width: 180px; /* Expanded width to show slider and next button */
}

.music-player .play-pause-btn,
.music-player .next-btn {
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

.music-player .play-pause-btn:hover,
.music-player .next-btn:hover {
    background-color: #0056b3; /* Darker blue on hover */
}

.music-player input[type="range"] {
    width: 70px; /* Slider width when visible */
    flex-grow: 1; /* Allow slider to take available space */
    margin-left: 5px; /* Space between button and slider */
}
</style>
