<template>
    <div class="pet-container" 
        v-if="isVisible"
        :class="{ 'no-transition': isDragging }"
        :style="{ transform: `translate(${petX}px, ${petY}px)`, cursor: isMovable ? 'grab' : 'default' }"
        @mousedown="startDrag"
        @touchstart.prevent="startDrag"
        @mouseover="handleInteraction" 
        @mouseleave="handleMouseLeave"
        @click="handleInteraction">
        <img src="../assets/pet.svg" alt="可爱的小宠物" :class="{ 'wagging': isWagging }">
        <div v-if="showMessage" class="pet-message">{{ currentMessage }}</div>
    </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted, defineProps } from 'vue';

const STORAGE_KEY_PET_CARD_POSITION = 'pet-card-position';

const isWagging = ref(false);
const showMessage = ref(false);
const currentMessage = ref('');
let messageTimeout = null;

const petX = ref(0); // Initial X offset for transform
const petY = ref(0); // Initial Y offset for transform
const isDragging = ref(false);
let startMouseX = 0;
let startMouseY = 0;
let startPetX = 0;
let startPetY = 0;
const longPressTimer = ref(null);
const initialTouchX = ref(0);
const initialTouchY = ref(0);

let animationFrameId = null;

const props = defineProps({
    isVisible: { type: Boolean, default: true },
    isMovable: { type: Boolean, default: true }
});

const messages = [
    '喵呜~ 你好呀！',
    '摸摸头，今天过得怎么样？',
    '想我了吗？',
    '有什么好玩的事情告诉我吗？',
    '我在这里陪着你哦！',
    '别忘了给我点赞哦！',
    '你真是个好主人！',
    '我饿了，有小鱼干吗？',
    '今天天气真好，适合睡觉。',
    '嘿，别走开，再陪我玩一会儿嘛！'
];

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
        petX.value = startPetX + dx;
        petY.value = startPetY + dy;
    });
};

onMounted(() => {
    const savedPosition = JSON.parse(localStorage.getItem(STORAGE_KEY_PET_CARD_POSITION));
    if (savedPosition) {
        petX.value = savedPosition.x;
        petY.value = savedPosition.y;
    }
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
});

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
            startPetX = petX.value;
            startPetY = petY.value;
        }, 500); // 500ms for long press
    } else { // mousedown
        isDragging.value = true;
        startMouseX = clientX;
        startMouseY = clientY;
        startPetX = petX.value;
        startPetY = petY.value;
    }
};

const stopDrag = () => {
    clearTimeout(longPressTimer.value);
    if (isDragging.value) {
        isDragging.value = false;
        localStorage.setItem(STORAGE_KEY_PET_CARD_POSITION, JSON.stringify({ x: petX.value, y: petY.value }));
    }
};

const handleInteraction = () => {
    isWagging.value = true;
    if (!showMessage.value) { // Only show message if not already showing
        const randomIndex = Math.floor(Math.random() * messages.length);
        currentMessage.value = messages[randomIndex];
        showMessage.value = true;
        // Hide message after a few seconds
        if (messageTimeout) clearTimeout(messageTimeout);
        messageTimeout = setTimeout(() => {
            showMessage.value = false;
        }, 3000); // Message disappears after 3 seconds
    }
};

const handleMouseLeave = () => {
    isWagging.value = false;
    // Optionally hide message immediately on mouse leave, or let timeout handle it
    // showMessage.value = false;
    // if (messageTimeout) clearTimeout(messageTimeout);
};
</script>

<style scoped>
/* Pet specific styles */
.pet-container {
    position: fixed;
    bottom: 20px;
    right: 20px;
    z-index: 1000;
    cursor: pointer;
    transition: transform 0.2s ease-in-out;
}

.pet-container.no-transition {
    transition: none !important;
}
.pet-container:hover {
    transform: scale(1.1);
}
.pet-container img {
    width: 80px; /* Adjust size as needed */
    height: 80px;
    object-fit: contain;
}

.wagging {
    animation: wag 0.5s infinite;
}

@keyframes wag {
    0% { transform: rotate(0deg); }
    25% { transform: rotate(10deg); }
    75% { transform: rotate(-10deg); }
    100% { transform: rotate(0deg); }
}

.pet-message {
    position: absolute;
    bottom: 90px; /* Position above the pet */
    right: 0; /* Align to the right of the pet container */
    max-width: 150px; /* Limit width to prevent overflow */
    background-color: rgba(0, 0, 0, 0.7);
    color: white;
    padding: 5px 10px;
    border-radius: 5px;
    white-space: normal; /* Allow text to wrap */
    font-size: 14px;
    opacity: 0;
    animation: fadeInOut 3s forwards; /* Fade in and out */
}

@keyframes fadeInOut {
    0% { opacity: 0; }
    10% { opacity: 1; }
    90% { opacity: 1; }
    100% { opacity: 0; }
}
</style>
