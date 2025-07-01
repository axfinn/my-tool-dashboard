<template>
    <div class="music-player" 
        :style="{ left: playerX + 'px', top: playerY + 'px' }"
        @mousedown="startDrag">
        <audio id="background-music" loop>
            <source src="/audio/background_music.mp3" type="audio/mpeg"> <!-- 请替换为您的音乐文件路径 -->
            您的浏览器不支持音频播放。
        </audio>
        <button class="btn btn-sm btn-primary" @click="toggleMusic">
            {{ isPlaying ? '暂停音乐' : '播放音乐' }}
        </button>
        <input type="range" min="0" max="1" step="0.01" v-model="volume" @input="setVolume">
    </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue';

const isPlaying = ref(false);
const volume = ref(0.5);
let audioPlayer = null;

const playerX = ref(20); // Initial X position
const playerY = ref(20); // Initial Y position
const isDragging = ref(false);
let offsetX = 0;
let offsetY = 0;

onMounted(() => {
    audioPlayer = document.getElementById('background-music');
    audioPlayer.volume = volume.value;

    document.addEventListener('mousemove', drag);
    document.addEventListener('mouseup', stopDrag);
});

onUnmounted(() => {
    document.removeEventListener('mousemove', drag);
    document.removeEventListener('mouseup', stopDrag);
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
    isDragging.value = true;
    offsetX = e.clientX - playerX.value;
    offsetY = e.clientY - playerY.value;
    e.preventDefault(); // Prevent default drag behavior
};

const drag = (e) => {
    if (!isDragging.value) return;
    playerX.value = e.clientX - offsetX;
    playerY.value = e.clientY - offsetY;
};

const stopDrag = () => {
    isDragging.value = false;
};
</script>

<style scoped>
/* Music player specific styles */
.music-player {
    position: fixed;
    background: rgba(255, 255, 255, 0.8);
    backdrop-filter: blur(5px);
    padding: 5px 10px; /* Smaller padding */
    border-radius: 10px;
    box-shadow: 0 5px 15px rgba(0,0,0,0.1);
    display: flex;
    align-items: center;
    gap: 5px; /* Smaller gap */
    z-index: 1000;
    cursor: grab; /* Indicate draggable */
}

.music-player:active {
    cursor: grabbing;
}

.music-player .btn {
    padding: 5px 10px; /* Smaller button */
    font-size: 0.8rem;
}

.music-player input[type="range"] {
    width: 80px; /* Smaller slider */
}
</style>
