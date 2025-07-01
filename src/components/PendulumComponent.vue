<template>
    <div class="pendulum-container">
        <svg :width="width" :height="height">
            <!-- Rod -->
            <line :x1="width / 2" y1="0" :x2="width / 2 + xOffset" :y2="height - ballRadius" stroke="grey" stroke-width="2" />
            <!-- Ball -->
            <circle :cx="width / 2 + xOffset" :cy="height - ballRadius" :r="ballRadius" fill="#3498db" />
        </svg>
    </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue';

const width = 100;
const height = 150;
const ballRadius = 15;
const amplitude = 30; // Max swing to left/right
const period = 2000; // Milliseconds for one full swing

const xOffset = ref(0);
let animationFrameId = null;
let startTime = null;

const animatePendulum = (timestamp) => {
    if (!startTime) startTime = timestamp;
    const elapsed = timestamp - startTime;

    // Simple sinusoidal motion for pendulum swing
    xOffset.value = amplitude * Math.sin((2 * Math.PI * elapsed) / period);

    animationFrameId = requestAnimationFrame(animatePendulum);
};

onMounted(() => {
    animationFrameId = requestAnimationFrame(animatePendulum);
});

onUnmounted(() => {
    if (animationFrameId) {
        cancelAnimationFrame(animationFrameId);
    }
});
</script>

<style scoped>
.pendulum-container {
    position: fixed;
    bottom: 20px;
    left: 20px;
    z-index: 999;
}
</style>