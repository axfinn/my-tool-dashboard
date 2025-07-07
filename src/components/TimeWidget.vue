<template>
    <div v-if="isVisible" class="time-widget"
        :class="{ 'no-transition': isDragging }"
        :style="{ transform: `translate(${timeX}px, ${timeY}px)`, cursor: isMovable ? 'grab' : 'default' }"
        @mousedown="startDrag"
        @touchstart.prevent="startDrag">
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
const longPressTimer = ref(null);
const initialTouchX = ref(0);
const initialTouchY = ref(0);

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
    document.addEventListener('touchmove', throttledDrag);
    document.addEventListener('touchend', stopDrag);
});

onUnmounted(() => {
    clearInterval(intervalId);
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
            startTimeX = timeX.value;
            startTimeY = timeY.value;
        }, 500); // 500ms for long press
    } else { // mousedown
        isDragging.value = true;
        startMouseX = clientX;
        startMouseY = clientY;
        startTimeX = timeX.value;
        startTimeY = timeY.value;
    }
};

const stopDrag = () => {
    clearTimeout(longPressTimer.value);
    if (isDragging.value) {
        isDragging.value = false;
        localStorage.setItem(STORAGE_KEY_TIME_WIDGET_POSITION, JSON.stringify({ x: timeX.value, y: timeY.value }));
    }
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

.time-widget.no-transition {
    transition: none !important;
}

.time-widget:active {
    cursor: grabbing;
}
</style>