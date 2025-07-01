<template>
    <div class="col">
        <div class="card h-100 tool-card">
            <a :href="tool.url" target="_blank" rel="noopener noreferrer">
                <div class="card-body">
                    <h5 class="card-title">{{ tool.name }}</h5>
                    <p class="card-text">{{ tool.description }}</p>
                </div>
            </a>
            <button class="btn-action btn-edit" @click.stop="$emit('edit', tool)">✏️</button>
            <button class="btn-action btn-delete" @click.stop="$emit('delete', tool.id)">🗑️</button>
        </div>
    </div>
</template>

<script setup>
import { defineProps, defineEmits } from 'vue';

defineProps({
    tool: {
        type: Object,
        required: true
    }
});

defineEmits(['edit', 'delete']);
</script>

<style scoped>
/* Styles for tool-card are mostly in global style.css, but you can add component-specific styles here if needed */
</style>
