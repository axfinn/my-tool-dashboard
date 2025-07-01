<template>
    <div class="pet-container" 
        v-if="isVisible"
        :style="{ transform: `translate(${petX}px, ${petY}px)`, cursor: isMovable ? 'grab' : 'default' }"
        @mousedown="startDrag"
        @mouseover="handleMouseOver" @mouseleave="handleMouseLeave">
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
        if (!isDragging.value) return;
        const dx = e.clientX - startMouseX;
        const dy = e.clientY - startMouseY;
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
});

onUnmounted(() => {
    document.removeEventListener('mousemove', throttledDrag);
    document.removeEventListener('mouseup', stopDrag);
    if (animationFrameId) {
        cancelAnimationFrame(animationFrameId);
    }
});

const startDrag = (e) => {
    if (!props.isMovable) return;
    isDragging.value = true;
    startMouseX = e.clientX;
    startMouseY = e.clientY;
    startPetX = petX.value;
    startPetY = petY.value;
    e.preventDefault(); // Prevent default drag behavior
};

const stopDrag = () => {
    isDragging.value = false;
    localStorage.setItem(STORAGE_KEY_PET_CARD_POSITION, JSON.stringify({ x: petX.value, y: petY.value }));
};

const handleMouseOver = () => {
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
