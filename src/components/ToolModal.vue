<template>
    <div class="modal fade" id="toolModal" tabindex="-1" aria-labelledby="toolModalLabel" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="toolModalLabel">{{ isEditMode ? '编辑工具' : '添加新工具' }}</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <form @submit.prevent="submitForm">
                        <input type="hidden" v-model="localTool.id">
                        <div class="mb-3">
                            <label for="tool-category" class="form-label">分类</label>
                            <input type="text" class="form-control" id="tool-category" v-model="localTool.category" required list="category-list" placeholder="例如：开发工具">
                            <datalist id="category-list">
                                <option v-for="cat in uniqueCategoryNames" :key="cat" :value="cat"></option>
                            </datalist>
                        </div>
                        <div class="mb-3">
                            <label for="tool-name" class="form-label">名称</label>
                            <input type="text" class="form-control" id="tool-name" v-model="localTool.name" required placeholder="例如：JSON 格式化">
                        </div>
                        <div class="mb-3">
                            <label for="tool-url" class="form-label">URL</label>
                            <input type="url" class="form-control" id="tool-url" v-model="localTool.url" required placeholder="https://example.com">
                        </div>
                        <div class="mb-3">
                            <label for="tool-description" class="form-label">描述</label>
                            <textarea class="form-control" id="tool-description" v-model="localTool.description" rows="3" placeholder="工具的简短描述"></textarea>
                        </div>
                        
                        <div class="modal-footer">
                            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal" @click="emits('close')">关闭</button>
                            <button type="submit" class="btn btn-primary">保存</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</template>

<script setup>
import { ref, watch, defineProps, defineEmits, onMounted, onUnmounted, defineExpose } from 'vue';
import { Modal } from 'bootstrap';

const props = defineProps({
    tool: Object,
    isEditMode: Boolean,
    uniqueCategoryNames: Array
});

const emits = defineEmits(['save', 'close']);

const localTool = ref({});
let modalInstance = null; // Internal modal instance

onMounted(() => {
    const modalElement = document.getElementById('toolModal');
    if (modalElement) {
        modalInstance = new Modal(modalElement);
    }
});

onUnmounted(() => {
    if (modalInstance) {
        modalInstance.dispose();
        modalInstance = null;
    }
});

watch(() => props.tool, (newVal) => {
    localTool.value = newVal ? { ...newVal } : { id: null, name: '', url: '', category: '', description: '' };
}, { immediate: true });

const submitForm = () => {
    emits('save', localTool.value);
    emits('close'); // Emit close event on successful save
};

// Expose show and hide methods to parent component
const show = () => {
    if (modalInstance) modalInstance.show();
};

const hide = () => {
    if (modalInstance) modalInstance.hide();
};

defineExpose({ show, hide });
</script>

<style scoped>
/* Modal specific styles can go here */
</style>
