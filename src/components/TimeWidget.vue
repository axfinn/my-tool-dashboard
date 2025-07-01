<template>
    <div v-if="isVisible" class="time-widget"
        :style="{ transform: `translate(${timeX}px, ${timeY}px)`, cursor: isMovable ? 'grab' : 'default' }"
        @mousedown="startDrag">
        {{ currentTime }}
    </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted, defineProps } from 'vue';

const STORAGE_KEY_TIME_WIDGET_POSITION = 'time-widget-position';

const props = defineProps({
    isVisible: { type: Boolean, default: true },
    isMovable: { type: Boolean, default: true }
});

const currentTime = ref('');
let intervalId = null;

const timeX = ref(0); // Initial X offset for transform
const timeY = ref(0); // Initial Y offset for transform
const isDragging = ref(false);
let startMouseX = 0;
let startMouseY = 0;
let startTimeX = 0;
let startTimeY = 0;

let animationFrameId = null;

const updateTime = () => {
    const now = new Date();
    currentTime.value = now.toLocaleTimeString();
};

const throttledDrag = (e) => {
    if (animationFrameId) {
        cancelAnimationFrame(animationFrameId);
    }
    animationFrameId = requestAnimationFrame(() => {
        if (!isDragging.value) return;
        const dx = e.clientX - startMouseX;
        const dy = e.clientY - startMouseY;
        timeX.value = startTimeX + dx;
        timeY.value = startTimeY + dy;
    });
};

onMounted(() => {
    updateTime();
    intervalId = setInterval(updateTime, 1000);

    const savedPosition = JSON.parse(localStorage.getItem(STORAGE_KEY_TIME_WIDGET_POSITION));
    if (savedPosition) {
        timeX.value = savedPosition.x;
        timeY.value = savedPosition.y;
    }

    document.addEventListener('mousemove', throttledDrag);
    document.addEventListener('mouseup', stopDrag);
});

onUnmounted(() => {
    clearInterval(intervalId);
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
    startTimeX = timeX.value;
    startTimeY = timeY.value;
    e.preventDefault(); // Prevent default drag behavior
};

const stopDrag = () => {
    isDragging.value = false;
    localStorage.setItem(STORAGE_KEY_TIME_WIDGET_POSITION, JSON.stringify({ x: timeX.value, y: timeY.value }));
};
</script>

<style scoped>
.time-widget {
    position: fixed;
    top: 100px;
    left: 20px;
    background: rgba(0, 0, 0, 0.7);
    color: white;
    padding: 10px 15px;
    border-radius: 8px;
    font-size: 1.2rem;
    font-weight: bold;
    z-index: 1000;
    transition: transform 0.1s ease-out;
}

.time-widget:active {
    cursor: grabbing;
}
</style>