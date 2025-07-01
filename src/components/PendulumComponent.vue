<template>
    <div v-if="props.isVisible" class="pendulum-container"
        :class="{ 'movable': props.isMovable }"
        :style="{ left: pendulumX + 'px', top: pendulumY + 'px' }"
        @mousedown="startDrag">
        <svg :width="width" :height="height">
            <!-- Rod -->
            <line :x1="width / 2" y1="0" :x2="width / 2 + xOffset" :y2="height - ballRadius" stroke="grey" stroke-width="2" />
            <!-- Ball -->
            <circle :cx="width / 2 + xOffset" :cy="height - ballRadius" :r="ballRadius" fill="#3498db" />
        </svg>
    </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted, defineProps } from 'vue';

const props = defineProps({
    isVisible: Boolean,
    isMovable: { type: Boolean, default: true }
});

const STORAGE_KEY_PENDULUM_POSITION = 'pendulum-position';

const width = 100;
const height = 150;
const ballRadius = 15;
const amplitude = 30; // Max swing to left/right
const period = 2000; // Milliseconds for one full swing

const xOffset = ref(0);
let animationFrameId = null;
let startTime = null;

const pendulumX = ref(20); // Initial X position
const pendulumY = ref(200); // Initial Y position
const isDragging = ref(false);
let offsetX = 0;
let offsetY = 0;

const animatePendulum = (timestamp) => {
    if (!startTime) startTime = timestamp;
    const elapsed = timestamp - startTime;

    // Simple sinusoidal motion for pendulum swing
    xOffset.value = amplitude * Math.sin((2 * Math.PI * elapsed) / period);

    animationFrameId = requestAnimationFrame(animatePendulum);
};

let dragAnimationFrameId = null;
const throttledDrag = (e) => {
    if (dragAnimationFrameId) {
        cancelAnimationFrame(dragAnimationFrameId);
    }
    dragAnimationFrameId = requestAnimationFrame(() => {
        if (!isDragging.value) return;
        pendulumX.value = e.clientX - offsetX;
        pendulumY.value = e.clientY - offsetY;
    });
};

onMounted(() => {
    animationFrameId = requestAnimationFrame(animatePendulum);
    const savedPosition = JSON.parse(localStorage.getItem(STORAGE_KEY_PENDULUM_POSITION));
    if (savedPosition) {
        pendulumX.value = savedPosition.x;
        pendulumY.value = savedPosition.y;
    }
    document.addEventListener('mousemove', throttledDrag);
    document.addEventListener('mouseup', stopDrag);
});

onUnmounted(() => {
    if (animationFrameId) {
        cancelAnimationFrame(animationFrameId);
    }
    document.removeEventListener('mousemove', throttledDrag);
    document.removeEventListener('mouseup', stopDrag);
    if (dragAnimationFrameId) {
        cancelAnimationFrame(dragAnimationFrameId);
    }
});

const startDrag = (e) => {
    if (!props.isMovable) return;
    isDragging.value = true;
    offsetX = e.clientX - pendulumX.value;
    offsetY = e.clientY - pendulumY.value;
    e.preventDefault(); // Prevent default drag behavior
};

const stopDrag = () => {
    isDragging.value = false;
    localStorage.setItem(STORAGE_KEY_PENDULUM_POSITION, JSON.stringify({ x: pendulumX.value, y: pendulumY.value }));
};
</script>

<style scoped>
.pendulum-container {
    position: fixed;
    z-index: 999;
}

.pendulum-container.movable {
    cursor: grab;
}

.pendulum-container.movable:active {
    cursor: grabbing;
}
</style>